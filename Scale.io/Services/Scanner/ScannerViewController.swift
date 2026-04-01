internal import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeFound: ((String) async -> Void)?

    private(set) var session: AVCaptureSession?
    public let sessionQueue = DispatchQueue(label: "Scale.grp.Scale-io")
    var preview: AVCaptureVideoPreviewLayer!
    private var scannerFrameView: UIView!
    private var scanningLine: UIView!
    private var permissionOverlayView: UIView?
    private var isHandlingCode: Bool = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        handleCameraAuthorizationStatus()
    }

    private func handleCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hidePermissionOverlay()
            setupScannerSessionIfNeeded()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.hidePermissionOverlay()
                        self.setupScannerSessionIfNeeded()
                    } else {
                        self.showPermissionOverlay(
                            title: "Camera access needed",
                            message: "Allow camera access in Settings to scan barcodes.",
                            showSettingsButton: true
                        )
                    }
                }
            }

        case .denied, .restricted:
            sessionQueue.async { [weak self] in
                guard let session = self?.session, session.isRunning else { return }
                session.stopRunning()
            }
            showPermissionOverlay(
                title: "Camera Access Needed",
                message: "Allow camera access in Settings to scan barcodes.",
                showSettingsButton: true
            )

        @unknown default:
            showPermissionOverlay(
                title: "Camera Unavailable",
                message: "The camera is unavailable on this device right now.",
                showSettingsButton: false
            )
        }
    }

    private func setupScannerSessionIfNeeded() {
        guard session == nil else { return }

        session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            let session = session
        else {
            failed(message: "Could not access the camera.")
            return
        }

        guard session.canAddInput(input) else {
            failed(message: "Could not connect camera input.")
            return
        }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            failed(message: "Could not read barcode metadata from the camera.")
            return
        }
        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce]

        _preview()

        sessionQueue.async { session.startRunning() }
    }

    func restartScanning() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
        isHandlingCode = false
        sessionQueue.async { [weak self] in
            guard let session = self?.session, !session.isRunning else { return }
            session.startRunning()
        }
    }

    private func failed(message: String) {
        showPermissionOverlay(
            title: "Scanner Unavailable",
            message: message,
            showSettingsButton: false
        )
        session = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleCameraAuthorizationStatus()

        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
        sessionQueue.async { [weak self] in
            guard let session = self?.session, !session.isRunning else { return }
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            guard let session = self?.session, session.isRunning else { return }
            session.stopRunning()
        }
    }

    // MARK: - Delegate
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !isHandlingCode else { return }
        guard let metadataObject = metadataObjects.first,
            let code = (metadataObject as? AVMetadataMachineReadableCodeObject)?.stringValue
        else { return }

        isHandlingCode = true

        sessionQueue.async { [weak self] in
            self?.session?.stopRunning()
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        Task { [weak self] in
            await self?.onCodeFound?(code)
        }
    }

    private func _preview() {
        guard let session else { return }
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(preview, at: 0)

        let size: CGFloat = 160
        let lineLength: CGFloat = 30
        let lineWidth: CGFloat = 4
        let color = UIColor.systemMint

        let frameView = UIView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.backgroundColor = .clear
        view.addSubview(frameView)

        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            frameView.widthAnchor.constraint(equalToConstant: size),
            frameView.heightAnchor.constraint(equalToConstant: size),
        ])

        func addLine(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
            let line = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            line.backgroundColor = color
            frameView.addSubview(line)
        }

        // Top-left corner
        addLine(x: 0, y: 0, width: lineLength, height: lineWidth)
        addLine(x: 0, y: 0, width: lineWidth, height: lineLength)

        // Top-right corner
        addLine(x: size - lineLength, y: 0, width: lineLength, height: lineWidth)
        addLine(x: size - lineWidth, y: 0, width: lineWidth, height: lineLength)

        // Bottom-left corner
        addLine(x: 0, y: size - lineWidth, width: lineLength, height: lineWidth)
        addLine(x: 0, y: size - lineLength, width: lineWidth, height: lineLength)

        // Bottom-right corner
        addLine(x: size - lineLength, y: size - lineWidth, width: lineLength, height: lineWidth)
        addLine(x: size - lineWidth, y: size - lineLength, width: lineWidth, height: lineLength)

        scannerFrameView = frameView
    }

    private func showPermissionOverlay(title: String, message: String, showSettingsButton: Bool) {
        permissionOverlayView?.removeFromSuperview()

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.95)
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        container.addSubview(stack)

        if showSettingsButton {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Open Settings", for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
            button.addTarget(self, action: #selector(openAppSettings), for: .touchUpInside)
            container.addSubview(button)

            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                button.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10),
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            ])
        }

        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])

        permissionOverlayView = container
    }

    private func hidePermissionOverlay() {
        permissionOverlayView?.removeFromSuperview()
        permissionOverlayView = nil
    }

    @objc
    private func openAppSettings() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
    }
}
