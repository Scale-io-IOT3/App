import SwiftUI

enum MacrosColor: String, CaseIterable, Identifiable {
  case carbs = "Carbs"
  case proteins = "Protein"
  case fats = "Fat"

  var id: String { rawValue }

  var color: Color {
    switch self {
    case .carbs: return .cyan
    case .proteins: return .mint
    case .fats: return .yellow
    }
  }
}
