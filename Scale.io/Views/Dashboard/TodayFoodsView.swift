import SwiftUI

struct TodayFoodsView: View {
    @EnvironmentObject var meal: MealsViewModel
    @State private var search = ""
    @State private var sort: SortOption = .time
    @State private var direction: SortDirection = .descending

    enum SortOption: String, CaseIterable, Identifiable {
        case time = "Time"
        case calories = "Calories"
        case name = "Name"

        var id: String { rawValue }
    }

    enum SortDirection: String, CaseIterable, Identifiable {
        case ascending = "Ascending"
        case descending = "Descending"

        var id: String { rawValue }
    }

    private var filteredFoods: [Food] {
        guard !search.isEmpty else { return meal.today }

        return meal.today.filter {
            $0.name.localizedCaseInsensitiveContains(search)
                || $0.brands.localizedCaseInsensitiveContains(search)
        }
    }

    private var sortedFoods: [Food] {
        func compare<T: Comparable>(_ a: T, _ b: T) -> Bool {
            direction == .ascending ? (a < b) : (a > b)
        }

        switch sort {
        case .time:
            return filteredFoods.sorted { foodA, foodB in
                compare(meal.loggedOrder[foodA.id] ?? 0, meal.loggedOrder[foodB.id] ?? 0)
            }
        case .calories:
            return filteredFoods.sorted(by: { compare($0.macros.calories, $1.macros.calories) })
        case .name:
            return filteredFoods.sorted {
                let cmp = $0.name.localizedCaseInsensitiveCompare($1.name)
                return direction == .ascending
                    ? (cmp == .orderedAscending) : (cmp == .orderedDescending)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if sortedFoods.isEmpty {
                    ContentUnavailableView(
                        "Looks a little quiet here today.",
                        systemImage: "carrot.fill",
                        description: Text(
                            search.isEmpty
                                ? "Add a little something when you’re ready."
                                : "Try a different search term."
                        )
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(sortedFoods, id: \.id) { food in
                        FoodCard(
                            food: food,
                            tags: meal.insights(for: food)
                        )
                    }
                }
            }
            .padding()
            .navigationTitle("Today’s foods")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Sort By") {
                            Picker("Sort By", selection: $sort) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        }

                        Section("Order") {
                            Picker("Order", selection: $direction) {
                                ForEach(SortDirection.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "slider.horizontal.3")
                    }
                }
            }
        }
        .searchable(text: $search, prompt: "Search foods")
        .scrollDismissesKeyboard(.immediately)
    }
}
