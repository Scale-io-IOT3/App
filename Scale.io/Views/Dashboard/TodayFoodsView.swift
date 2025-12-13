import SwiftUI

struct TodayFoodsView: View {
    @EnvironmentObject var meal: MealsViewModel
    @State private var search = ""

    private var filteredFoods: [Food] {
        guard !search.isEmpty else { return meal.today }

        return meal.today.filter {
            $0.name.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if filteredFoods.isEmpty {
                    ContentUnavailableView(
                        search.isEmpty
                            ? "Looks a little quiet here today."
                            : "No results",
                        systemImage: "carrot.fill",
                        description: Text(
                            search.isEmpty
                                ? "Add a little something when you’re ready."
                                : "Try a different search term."
                        )
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(filteredFoods, id: \.id) { food in
                        FoodCard(food: food)
                    }
                }
            }
            .padding()
            .navigationTitle("Today’s foods")
        }
        .searchable(text: $search, prompt: "Search foods")
        .scrollDismissesKeyboard(.immediately)
    }
}
