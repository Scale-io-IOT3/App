import SwiftUI

extension View {
    func resize(to size: Set<PresentationDetent> = [.fraction(0.48)]) -> some View {
        return self.presentationDetents(size)
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
