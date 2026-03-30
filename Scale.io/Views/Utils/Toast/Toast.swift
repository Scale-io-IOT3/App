import SwiftUI

struct Toast: View {
    var state: ToastState
    var horizontalPadding: CGFloat = 16
    var bottomPadding: CGFloat = 10
    var cornerRadius: CGFloat = 14
    var cardPadding: CGFloat = 14
    var spacing: CGFloat = 10
    var persist: Bool = false
    var timeout: TimeInterval = 3
    var onDismiss: (() -> Void)? = nil

    @State private var isVisible: Bool = false
    @State private var dismissTask: Task<Void, Never>?
    private let animationDuration: TimeInterval = 0.24

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            leadingIndicator

            Text(state.message)
                .font(state.isLoading ? .footnote.weight(.semibold) : .footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(cornerRadius: cornerRadius, padding: cardPadding)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottomPadding)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 12)
        .animation(.easeInOut(duration: animationDuration), value: isVisible)
        .onAppear {
            present()
        }
        .onChange(of: state.signature) { _, _ in
            present()
        }
        .onDisappear {
            dismissTask?.cancel()
        }
    }

    @ViewBuilder
    private var leadingIndicator: some View {
        if state.showsProgress {
            ProgressView()
                .controlSize(.regular)
                .padding(.top, 1)
        } else if let icon = state.icon {
            Image(systemName: icon)
                .foregroundStyle(state.tint)
                .font(.subheadline)
                .padding(.top, 1)
        }
    }

    private func present() {
        dismissTask?.cancel()
        withAnimation(.easeInOut(duration: animationDuration)) {
            isVisible = true
        }
        scheduleDismissIfNeeded()
    }

    private func scheduleDismissIfNeeded() {
        guard !persist, timeout > 0 else { return }
        let delayNanoseconds = UInt64(timeout * 1_000_000_000)

        dismissTask = Task {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                dismissNow()
            }
        }
    }

    private func dismissNow() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            isVisible = false
        }
        guard let onDismiss else { return }

        dismissTask = Task {
            let delayNanoseconds = UInt64(animationDuration * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                onDismiss()
            }
        }
    }
}

#Preview("Animated") {
    VStack(spacing: 10) {
        Toast(state: .error("Couldn't fetch this barcode."))
        Toast(state: .success("Food saved successfully."))
        Toast(state: .info("Move closer to scan the barcode."))
        Toast(state: .warning("Weight is unstable, try again."))
        Toast(
            state: .custom(
                message: "Custom feedback with your own icon and color.",
                icon: "sparkles",
                tint: .blue
            ),
        )
    }
    .padding(16)

}

#Preview {
    VStack(spacing: 10) {
        Toast(
            state: .error("Couldn't fetch this barcode."),
            persist: true
        )
        Toast(
            state: .success("Food saved successfully."),
            persist: true
        )
        Toast(
            state: .info("Move closer to scan the barcode."),
            persist: true
        )
        Toast(
            state: .warning("Weight is unstable, try again."),
            persist: true
        )
        Toast(
            state: .custom(
                message: "Custom feedback with your own icon and color.",
                icon: "sparkles",
                tint: .blue
            ),
            persist: true
        )
    }
    .padding(16)
}
