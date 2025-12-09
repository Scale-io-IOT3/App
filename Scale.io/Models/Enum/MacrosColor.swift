import SwiftUI

enum MacrosColor: String, CaseIterable, Identifiable {
    case carbs = "Carbs"
    case proteins = "Protein"
    case fat = "Fat"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .carbs: return .cyan
        case .proteins: return .pink
        case .fat: return .yellow
        }
    }
}
