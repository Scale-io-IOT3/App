import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var foodVm: FoodViewModel
    @EnvironmentObject private var toastVm: ToastViewModel
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool
    @Binding var isLoading: Bool
    @Binding var search: String

    var key: String
    var fetch: (_ query: String) async -> [Food]
    private let searchDelay: UInt64 = 700_000_000

    var body: some View {
        FoodListView(foods: $foods, presentSheet: $presentSheet)
            .overlay(overlay)
            .searchable(
                text: $search,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search foods or brands"
            )
            .task(id: search) { await searchTask() }
            .onDisappear {
                toastVm.clear(key)
            }
    }

    @ViewBuilder
    private var overlay: some View {
        if !isLoading && foods.isEmpty {
            emptyStateView
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        if !search.isEmpty {
            ContentUnavailableView.search(text: search)
        } else {
            StartSearch()
        }
    }

    private func searchTask() async {
        guard !search.isEmpty else {
            isLoading = false
            foods = []
            toastVm.clear(key)
            return
        }

        try? await Task.sleep(nanoseconds: searchDelay)
        guard !Task.isCancelled else { return }

        await fetchFoods()
    }

    private func fetchFoods() async {
        isLoading = true
        toastVm.show(.loading("Searching..."), key, persist: true)
        let results = await fetch(search)
        guard !Task.isCancelled else { return }

        isLoading = false
        foods = results

        if let error = foodVm.lastFetchError, !error.isEmpty {
            toastVm.show(.error(error), key)
        } else {
            toastVm.clear(key)
        }
    }
}

fileprivate struct StartSearch: View {
    var body: some View {
        ContentUnavailableView(
            "Find a food",
            systemImage: "magnifyingglass",
            description: Text("Start typing to search products and fresh foods.")
        )
    }
}
