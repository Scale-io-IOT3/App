internal import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeFound: ((String) async -> Void)?
    
    private(set) var session: AVCaptureSession?
    public let sessionQueue = DispatchQueue(label: "Scale.grp.Scale-io")
    var preview: AVCaptureVideoPreviewLayer!
    private var scannerFrameView: UIView!
    private var scanningLine: UIView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              let session = session else { return }
        
        guard session.canAddInput(input) else { failed(); return }
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { failed(); return }
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce]
        
        _preview()
        
        sessionQueue.async { session.startRunning() }
    }
    
    private func failed() {
        let ac = UIAlertController(
            title: "Scanning not supported",
            message: "Your device does not support scanning.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        session = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        sessionQueue.async { [weak self] in
            self?.session?.stopRunning()
        }
        
        if let metadataObject = metadataObjects.first,
           let code = (metadataObject as? AVMetadataMachineReadableCodeObject)?.stringValue {
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            Task { [weak self] in
                await self?.onCodeFound?(code)
            }
        }
    }
    
    private func _preview() {
        preview = AVCaptureVideoPreviewLayer(session: session!)
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
            frameView.heightAnchor.constraint(equalToConstant: size)
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

}
