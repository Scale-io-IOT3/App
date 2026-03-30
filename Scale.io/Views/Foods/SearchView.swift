import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var foodVm: FoodViewModel
    @EnvironmentObject private var bluetooth: BluetoothViewModel
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool
    @Binding var isLoading: Bool
    @Binding var search: String

    var fetch: (_ query: String) async -> [Food]
    private let searchDelay: UInt64 = 700_000_000

    var body: some View {
        FoodListView(foods: $foods, presentSheet: $presentSheet)
            .overlay(overlayView)
            .searchable(text: $search, prompt: "Search foods or brands")
            .task(id: search) { await searchTask() }
            .task(id: bluetooth.weight) {
                guard !search.isEmpty else { return }
                await fetchFoods()
            }

    }

    @ViewBuilder
    private var overlayView: some View {
        if isLoading {
            VStack(spacing: 10) {
                ProgressView().controlSize(.large)
                Text("Searching...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .appCard(cornerRadius: 14, padding: 18)
        } else if foods.isEmpty {
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
            return
        }

        try? await Task.sleep(nanoseconds: searchDelay)
        guard !Task.isCancelled else { return }

        await fetchFoods()
    }

    private func fetchFoods() async {
        isLoading = true
        defer { isLoading = false }

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

#Preview {
    StartSearch()
}
