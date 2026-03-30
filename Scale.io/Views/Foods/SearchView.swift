import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var foodVm: FoodViewModel
    @EnvironmentObject private var bluetooth: BluetoothViewModel
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
            .searchable(text: $search, prompt: "Search foods or brands")
            .task(id: search) { await searchTask() }
            .task(id: bluetooth.weight) {
                guard !search.isEmpty else { return }
                await fetchFoods()
            }
            .onDisappear {
                toastVm.clear(key: key)
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
            toastVm.clear(key: key)
            return
        }

        try? await Task.sleep(nanoseconds: searchDelay)
        guard !Task.isCancelled else { return }

        await fetchFoods()
    }

    private func fetchFoods() async {
        isLoading = true
        toastVm.show(.loading("Searching..."), key: key, persist: true)
        defer {
            isLoading = false
            toastVm.clear(key: key)
        }

        let results = await fetch(search)
        foods = results
    }
}

struct StartSearch: View {
    var body: some View {
        ContentUnavailableView(
            "Find a food",
            systemImage: "magnifyingglass",
            description: Text("Start typing to search products and fresh foods.")
        )
    }
}
