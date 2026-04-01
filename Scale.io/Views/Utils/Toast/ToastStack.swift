import SwiftUI

struct ToastStack: View {
    @EnvironmentObject private var vm: ToastViewModel
    var key: String
    var horizontalPadding: CGFloat = 16
    var bottomPadding: CGFloat = 10
    var cornerRadius: CGFloat = 14
    var cardPadding: CGFloat = 14
    var spacing: CGFloat = 10

    var body: some View {
        if let presentation = vm.toast(for: key) {
            Toast(
                state: presentation.state,
                horizontalPadding: horizontalPadding,
                bottomPadding: bottomPadding,
                cornerRadius: cornerRadius,
                cardPadding: cardPadding,
                spacing: spacing,
                persist: presentation.persist,
                timeout: presentation.timeout,
                onDismiss: {
                    vm.clear(key)
                }
            )
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(.systemBackground)
            .ignoresSafeArea()

        ToastStack(key: ToastKey.main)
    }
    .environmentObject(ToastViewModel())
}
