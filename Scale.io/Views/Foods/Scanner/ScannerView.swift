import SwiftUI

struct ScannerView: View {
    @EnvironmentObject private var foodVm: FoodViewModel
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool
    @Binding var startScanning: Bool
    var fetch: (_ query: String) async -> [Food]

    @State private var isFetching: Bool = false
    @State private var feedback: ScanFeedback?
    @State private var lastFailedCode: String?
    @State private var lastFailedAt: Date?
    @State private var rescanTask: Task<Void, Never>?
    private let retryCooldown: TimeInterval = 2
    private let failedRescanDelay: TimeInterval = 1.5

    private enum ScanFeedback {
        case info(String)
        case error(String)

        var state: ToastState {
            switch self {
            case .info(let message): return .info(message)
            case .error(let message): return .error(message)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerRepresentable(
                startScanning: $startScanning,
                onCodeFound: { code in
                    await fetchFromScan(code: code)
                }
            )
            .ignoresSafeArea()

            bottomOverlay
        }
        .animation(.easeInOut(duration: 0.2), value: isFetching)
        .animation(.easeInOut(duration: 0.2), value: feedback != nil)
        .onDisappear {
            rescanTask?.cancel()
        }
    }

    @ViewBuilder
    private var bottomOverlay: some View {
        VStack(spacing: 10) {
            if isFetching {
                Toast(
                    state: .loading("Fetching food details..."),
                    persist: true
                )
            }

            if let feedback {
                Toast(state: feedback.state) {
                    self.feedback = nil
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private func fetchFromScan(code: String) async {
        var shouldSkip = false

        await MainActor.run {
            if let lastFailedCode,
                let lastFailedAt,
                lastFailedCode == code,
                Date().timeIntervalSince(lastFailedAt) < retryCooldown
            {
                feedback = .info(
                    "Already tried this barcode. Move away and retry in a few seconds."
                )
                scheduleRescan()
                shouldSkip = true
                return
            }

            isFetching = true
            feedback = nil
        }
        guard !shouldSkip else { return }

        let results = await fetch(code)

        await MainActor.run {
            isFetching = false
            foods = results

            if let selectedFood = results.first {
                lastFailedCode = nil
                lastFailedAt = nil
                foodVm.selected = selectedFood
                presentSheet = true
                return
            }

            let fallbackMessage = "No food matched this barcode. Try another item."
            if let error = foodVm.lastFetchError, !error.isEmpty {
                feedback = .error("Couldn't fetch this barcode. \(error)")
            } else {
                feedback = .info(fallbackMessage)
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
        fetch: { query in
            return []
        },
    )
    .environmentObject(FoodViewModel())
}
