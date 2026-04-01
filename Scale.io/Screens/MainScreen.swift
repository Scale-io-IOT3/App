import SwiftUI

struct MainScreen: View {
    @State private var selected: TabRepresentation = .dashboard
    @StateObject var bluetooth: BluetoothViewModel = .init()
    @StateObject var food: FoodViewModel = .init()
    @StateObject var meals: MealsViewModel = .init()
    @StateObject var health: HealthViewModel = .init()
    @StateObject var toast: ToastViewModel = .init()

    var body: some View {
        TabView(selection: $selected) {
            ForEach(TabRepresentation.allCases, id: \.self) { tab in
                tab.view
                    .tabItem {
                        Label(tab.rawValue.capitalized, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
            .environmentObject(bluetooth)
            .environmentObject(food)
            .environmentObject(meals)
            .environmentObject(health)
            .environmentObject(toast)
            .tabViewStyle(.automatic)
        }
        .environmentObject(toast)
    }
}

#Preview {
    MainScreen()
        .environmentObject(ToastViewModel())
}
