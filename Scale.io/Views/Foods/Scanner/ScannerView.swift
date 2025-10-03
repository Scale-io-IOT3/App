import SwiftUI

struct ScannerView: View {
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool
    @Binding var startScanning: Bool
    var fetch: (_ query: String) async -> [Food]

    var body: some View {
        ScannerRepresentable(startScanning: $startScanning, onCodeFound: { code in
            foods = await fetch(code)
            presentSheet = true
        })
        .navigationTitle("Scanner")
    }
}
