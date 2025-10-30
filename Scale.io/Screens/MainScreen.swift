import SwiftUI

struct MainScreen: View {
  @State private var selected: Tab = .dashboard
  var body: some View {
    TabView(selection: $selected) {
      ForEach(Tab.allCases, id: \.self) { tab in
        tab.view
      }
    }
  }
}

#Preview {
  MainScreen()
}
