import SwiftData
import SwiftUI

struct ContentView: View {
    @StateObject private var foodVm = FoodViewModel()
    @State private var foods: [Food] = []
    @State private var search: String = ""
    var body: some View {
        NavigationStack {
            FoodListView(foods: $foods)
                .overlay {
                    if foods.isEmpty {
                        ContentUnavailableView("No Foods", systemImage: "leaf", description: Text("Fetching results…"))
                    }
                }
        }
        .searchable(text: $search)
        .task(id: search) {
            guard !search.isEmpty else {
                return
            }

            try? await Task.sleep(nanoseconds: 750_000_000)
            guard !Task.isCancelled else { return }

            self.foods = await foodVm.getFreshFood(food: search)
        }

    }
}

#Preview {
    ContentView()
}
