import SwiftUI

struct ContentView: View {
    @StateObject private var foodVm = FoodViewModel()
    @State private var foods: [Food] = []
    @State private var search: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            FoodListView(foods: $foods)
                .overlay {
                    if isLoading {
                        ProgressView()
                            .controlSize(.regular)
                    } else if foods.isEmpty {
                        ContentUnavailableView.search(text: search)
                    }
                }
        }
        .searchable(text: $search)
        .task(id: search) {
            guard !search.isEmpty else {
                isLoading = false
                foods = []
                return
            }

            try? await Task.sleep(nanoseconds: 700000000)
            guard !Task.isCancelled else { return }

            await fetch()
        }
    }

    private func fetch() async {
        isLoading = true
        defer { isLoading = false }
        foods = await foodVm.getFreshFood(food: search)
    }
}

#Preview {
    ContentView()
}
