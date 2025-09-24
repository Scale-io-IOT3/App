import SwiftUI
import UIKit

struct ScannerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScannerViewController
    var onCodeFound: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onCodeFound = onCodeFound
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}
