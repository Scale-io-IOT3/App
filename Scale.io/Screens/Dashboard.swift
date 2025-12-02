import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    var todayMeals: [Meal] {
        meal.meals
    }

    var todayCalories: Int {
        todayMeals
            .flatMap { $0.foods }
            .compactMap { $0.calories }
            .reduce(0, +)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CalorieBar(
                    progress: Double(todayCalories) / (health.BMR ?? 0),
                    calories: todayCalories,
                    goal: (health.BMR ?? 0)
                )

                VStack(alignment: .leading, spacing: 16) {
                    HStack{
                        Text("Today's Meals")
                            .font(.title2.bold())
                        
                        Spacer()
                    }

                    ForEach(meal.meals.enumerated(), id: \.element.createdAt) { index, meal in
                        MealCard(meal: meal, index: index)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            Task {
                await meal.fetch()
                await health.getUserBMR()
            }
        }
        .padding(.top)
    }

}

#Preview {
    Dashboard()
        .environmentObject(MealsViewModel())
        .environmentObject(HealthViewModel())
}
