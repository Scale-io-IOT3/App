import SwiftUI
import UIKit
internal import AVFoundation

struct ScannerRepresentable: UIViewControllerRepresentable {
    @Binding var startScanning: Bool
    var onCodeFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.onCodeFound = { code in
            onCodeFound(code)
            startScanning = false
        }
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if startScanning {
            uiViewController.sessionQueue.async {
                uiViewController.session?.startRunning()
            }
        }
    }
}
