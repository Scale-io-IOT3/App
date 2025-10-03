import Foundation
import SwiftUI

enum Tab: String, CaseIterable, Hashable {
    case foods
    case add
    case scale
    case dashboard
    
    var systemImage: String {
        switch self {
        case .foods: return "fork.knife"
        case .add: return "barcode.viewfinder"
        case .scale: return "scalemass"
        case .dashboard: return "chart.bar"
        }
    }
    
    
    @ViewBuilder
    private var content: some View {
        switch self {
        case .foods:
            Text("Recent Foods")
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


