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
    private var content: some View {
        switch self {
        case .add:
            AddFood()
        case .scale:
            ScaleManager()
        case .dashboard:
            Dashboard()
        }
    }

    @ViewBuilder
    public var view: some View {
        NavigationStack {
            content
        }
        .tabItem {
            Label(rawValue.capitalized, systemImage: systemImage)
        }
        .tag(self)
    }

}
