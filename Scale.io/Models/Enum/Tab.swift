import Foundation
import SwiftUI

enum Tab: String, CaseIterable, Hashable {
  case dashboard
  case add
  case scale

  var systemImage: String {
    switch self {
    case .scale: return "scalemass"
    case .add: return "plus"
    case .dashboard: return "chart.bar"
    }
  }

  @ViewBuilder
  private var content: some View {
    switch self {
    case .add:
      AddFood()
    case .scale:
      Text("Scale")
    case .dashboard:
      Text("Dash")
    }
  }

  @ViewBuilder
  public var view: some View {
    content
      .tabItem {
        Label(self.rawValue.capitalized, systemImage: systemImage)
      }
      .tag(self)
  }

}
