import SwiftUI

struct MainScreen: View {
  @State private var selected: TabRepresentation = .dashboard
  @StateObject var bluetooth: BluetoothViewModel = .init()
  var body: some View {
    TabView(selection: $selected) {
      ForEach(TabRepresentation.allCases, id: \.self) { tab in
        tab.view
      }
    }
    .environmentObject(bluetooth)
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview {
  MainScreen()
}
