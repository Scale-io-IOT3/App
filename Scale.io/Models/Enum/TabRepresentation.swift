import Foundation
import SwiftUI

enum TabRepresentation: String, CaseIterable, Hashable {
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
  var content: some View {
    switch self {
    case .add:
      AddFood()
    case .scale:
      ScaleManager()
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
