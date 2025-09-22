import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeFound: ((String) -> Void)?
    var session: AVCaptureSession!
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

        if !session.canAddInput(input) {
            failed()
            return
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce]

        if !session.canAddOutput(output) {
            failed()
            return
        }

        session.addOutput(output)

        preview = .init(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(preview, at: 0)
        
        session.startRunning()
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

        if session.isRunning == false {
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if session.isRunning == true {
            session.stopRunning()
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        session.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let code = (metadataObject as? AVMetadataMachineReadableCodeObject)?.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(
                SystemSoundID(kSystemSoundID_Vibrate)
            )

            found(code)
        }
        
        dismiss(animated: true)
    }

    func found(_ code: String) {
        onCodeFound?(code)
    }
}
