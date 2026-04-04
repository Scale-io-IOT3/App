import SwiftUI

extension View {

    /// This is used to make sheets have the custom size adapted to the app
    /// - Parameter size: The array that gives the sizes of the sheet from the smaller to the bigger size
    /// - Returns: the actual View
    private func resize(_ size: Set<PresentationDetent> = [.medium, .fraction(0.6)]) -> some View {
        return self.presentationDetents(size)
    }

    func resizeWithAction() -> some View {
        resize([.fraction(0.6)])
    }

    func resizeWithoutAction() -> some View {
        resize([.fraction(0.5)])
    }

    func appCard(cornerRadius: CGFloat = 18, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
    }
}
