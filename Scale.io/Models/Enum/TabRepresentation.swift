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

    private var toastKey: String {
        switch self {
        case .dashboard: return ToastKey.dashboard
        case .add: return ToastKey.add
        case .scale: return ToastKey.scale
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
            ZStack(alignment: .bottom) {
                content
                ToastStack(key: toastKey)
            }
        }
    }
}
