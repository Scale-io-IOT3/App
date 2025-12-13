import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                CalorieBar(calories: health.calories ?? 0, goal: health.BMR ?? 1200)

                VStack(spacing: 16) {
                    NavigationLink {
                        TodayFoodsView()
                    } label: {
                        TodayCardView(foods: meal.today)
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    MacrosBreakdown(calories: health.calories ?? 0)
                    Spacer()
                }

                HStack {
                    CaloriesLeft(consumed: health.calories ?? 0, goal: Int(health.BMR ?? 1200))
                    if !meal.today.isEmpty {
                        FoodCard(food: meal.today.last!)
                    }
                }

                Spacer()

            }
            .environmentObject(meal)
            .padding(.horizontal)
            .navigationTitle("Dashboard")
            .task { await load() }
        }
    }

    private func load() async {
        await meal.getTodayFoods()
        await health.getUserBMR()
        await health.getDailyMacros()
    }

}

#Preview {
    Dashboard()
        .environmentObject(MealsViewModel())
        .environmentObject(HealthViewModel())
}
