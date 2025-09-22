import SwiftUI
import UIKit


struct ScannerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        
        controller.onCodeFound = onCodeFound
        return controller
    }

    typealias UIViewControllerType = ScannerViewController
    var onCodeFound: (String) -> Void

    func updateUIViewController(_ uiViewController: ScannerViewController,context: Context){
        
    }
}
