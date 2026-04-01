import SwiftUI

struct ScannerView: View {
    @EnvironmentObject private var foodVm: FoodViewModel
    @EnvironmentObject private var toast: ToastViewModel
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool
    @Binding var startScanning: Bool
    var key: String = ToastKey.global
    var fetch: (_ query: String) async -> [Food]

    @State private var lastFailedCode: String?
    @State private var lastFailedAt: Date?
    @State private var rescanTask: Task<Void, Never>?
    private let retryCooldown: TimeInterval = 2
    private let failedRescanDelay: TimeInterval = 1.5

    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerRepresentable(
                startScanning: $startScanning,
                onCodeFound: { code in
                    await fetchFromScan(code: code)
                }
            )
            .ignoresSafeArea()
        }
        .onDisappear {
            rescanTask?.cancel()
            toast.clear(key)
        }
    }

    private func fetchFromScan(code: String) async {
        var shouldSkip = false

        await MainActor.run {
            if let lastFailedCode,
                let lastFailedAt,
                lastFailedCode == code,
                Date().timeIntervalSince(lastFailedAt) < retryCooldown
            {
                toast.show(
                    .info("Already tried this barcode. Move away and retry in a few seconds."),
                    key
                )
                scheduleRescan()
                shouldSkip = true
                return
            }

            toast.show(
                .loading("Fetching food details..."),
                key,
                persist: true
            )
        }
        guard !shouldSkip else { return }

        let results = await fetch(code)

        await MainActor.run {
            foods = results

            if let selectedFood = results.first {
                toast.clear(key)
                lastFailedCode = nil
                lastFailedAt = nil
                foodVm.selected = selectedFood
                presentSheet = true
                return
            }

            let fallbackMessage = "No food matched this barcode. Try another item."
            if let error = foodVm.lastFetchError, !error.isEmpty {
                toast.show(
                    .error("Couldn't fetch this barcode. \(error)"),
                    key
                )
            } else {
                toast.show(.info(fallbackMessage), key)
            }

            lastFailedCode = code
            lastFailedAt = Date()
            scheduleRescan()
        }
    }

    private func scheduleRescan(after delay: TimeInterval? = nil) {
        let delaySeconds = delay ?? failedRescanDelay
        rescanTask?.cancel()
        rescanTask = Task {
            let nanoseconds = UInt64(max(delaySeconds, 0) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                startScanning = true
            }
        }
    }
}

#Preview {
    @Previewable @State var foods: [Food] = []
    @Previewable @State var present: Bool = false
    @Previewable @State var start: Bool = false

    ScannerView(
        foods: $foods,
        presentSheet: $present,
        startScanning: $start,
        key: ToastKey.add,
        fetch: { query in
            return []
        },
    )
    .environmentObject(FoodViewModel())
    .environmentObject(ToastViewModel())
}
