internal import AVFoundation
import SwiftUI
import UIKit

struct ScannerRepresentable: UIViewControllerRepresentable {
    @Binding var startScanning: Bool
    var onCodeFound: (String) async -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.onCodeFound = { code in
            await MainActor.run { startScanning = false }
            await onCodeFound(code)
        }
        return scanner
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if startScanning {
            uiViewController.restartScanning()
        }
    }
}
