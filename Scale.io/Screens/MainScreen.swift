import SwiftUI

struct MainScreen: View {
  @State private var selected: TabRepresentation = .dashboard
  var body: some View {
    TabView(selection: $selected) {
      ForEach(TabRepresentation.allCases, id: \.self) { tab in
        tab.view
      }
    }
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview {
  MainScreen()
}
