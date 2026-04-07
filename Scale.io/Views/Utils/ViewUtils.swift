import SwiftUI

extension View {

    /// This is used to make sheets have the custom size adapted to the app
    /// - Parameter size: The array that gives the sizes of the sheet from the smaller to the bigger size
    /// - Returns: the actual View
    private func resize(_ size: Set<PresentationDetent>) -> some View {
        self.presentationDetents(size)
    }

    func resizeWithAction(
        _ size: Set<PresentationDetent> = [.large]
    ) -> some View {
        resize(size)
            .presentationContentInteraction(.resizes)
    }

    func resizeWithoutAction(
        _ size: Set<PresentationDetent> = [.fraction(0.45), .large]
    ) -> some View {
        resize(size)
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
