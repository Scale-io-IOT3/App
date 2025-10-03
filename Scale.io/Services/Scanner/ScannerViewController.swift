internal import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeFound: ((String) -> Void)?
    private(set) var session: AVCaptureSession?
    private(set) var sessionQueue = DispatchQueue(label: "Scale.grp.Scale-io")
    var preview: AVCaptureVideoPreviewLayer!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        session = .init()
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        guard let session = session else { return }

        if !session.canAddInput(input) {
            failed()
            return
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()

        if !session.canAddOutput(output) {
            failed()
            return
        }

        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce]

        preview = .init(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(preview, at: 0)

        sessionQueue.async {
            session.startRunning()
        }
    }

    func failed() {
        let ac = UIAlertController(
            title: "Scanning not supported",
            message: "Your device does not support scanning a code from an item.",
            preferredStyle: .alert
        )
        ac.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        present(ac, animated: true)
        session = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sessionQueue.async { [weak self] in
            guard let session = self?.session, session.isRunning == false else { return }
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sessionQueue.async { [weak self] in
            guard let session = self?.session, session.isRunning == true else { return }
            session.stopRunning()
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        sessionQueue.async { [weak self] in
            self?.session?.stopRunning()
        }

        if let metadataObject = metadataObjects.first {
            guard let code = (metadataObject as? AVMetadataMachineReadableCodeObject)?.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(
                SystemSoundID(kSystemSoundID_Vibrate)
            )

            found(code)
        }
    }

    func found(_ code: String) {
        onCodeFound?(code)
        dismiss(animated: true)
    }
}
