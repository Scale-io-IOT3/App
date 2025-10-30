import SwiftUI

struct SearchView: View {
  @EnvironmentObject private var foodVm: FoodViewModel
  @Binding var foods: [Food]
  @Binding var presentSheet: Bool
  @Binding var isLoading: Bool
  @Binding var search: String

  var fetch: (_ query: String) async -> [Food]
  private let searchDelay: UInt64 = 700_000_000  // 0.7 seconds

  var body: some View {
    FoodListView(foods: $foods, presentSheet: $presentSheet)
      .overlay(overlayView)
      .searchable(text: $search)
      .task(id: search) { await searchTask() }
  }

  @ViewBuilder
  private var overlayView: some View {
    if isLoading {
      ProgressView().controlSize(.extraLarge)
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
      "Search for foods",
      systemImage: "leaf.fill",
      description: Text("Start typing to find food items.")
    )
  }
}

#Preview {
  StartSearch()
}
