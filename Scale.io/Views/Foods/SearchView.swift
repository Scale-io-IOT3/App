import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var foodVm: FoodViewModel
    @Binding var foods: [Food]
    @Binding var isLoading: Bool
    @State private var search: String = ""

    var fetch: (_ query: String) async -> [Food]

    private let searchDelay: UInt64 = 700000000 // 0.7s debounce

    var body: some View {
        FoodListView(foods: $foods)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                } else if foods.isEmpty && !search.isEmpty {
                    ContentUnavailableView.search(text: search)
                }
            }
            .searchable(text: $search)
            .task(id: search) { await searchTask() }
            .navigationTitle("Foods")
    }

    private func searchTask() async {
        guard !search.isEmpty else {
            isLoading = false
            foods = []
            return
        }

        try? await Task.sleep(nanoseconds: searchDelay)
        guard !Task.isCancelled else { return }

        await fetchFoods()
    }

    private func fetchFoods() async {
        isLoading = true
        defer { isLoading = false }

        foods = await fetch(search)
    }
}
