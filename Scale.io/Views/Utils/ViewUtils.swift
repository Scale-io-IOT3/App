import SwiftUI

extension View {
    func resize(to size: Set<PresentationDetent> = [.fraction(0.48)]) -> some View {
        return self.presentationDetents(size)
    }
}
