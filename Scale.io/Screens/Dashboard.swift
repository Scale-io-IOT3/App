import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    @State var todayFoods: [Food] = []
    var todayCalories: Int { todayFoods.compactMap { $0.calories }.reduce(0, +) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                let bmrGoal = health.BMR ?? 1200
                CalorieBar(progress: Double(todayCalories) / Double(bmrGoal), calories: todayCalories, goal: bmrGoal)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Today's Food").font(.title2.bold())
                        Spacer()
                    }

                    if !todayFoods.isEmpty {
                        ForEach(todayFoods, id: \.id) { food in
                            FoodCard(food: food)
                        }
                    } else {
                        Spacer()
                        ContentUnavailableView("No food logged today", systemImage: "leaf.fill")
                    }

                }
                .padding(.horizontal)
            }
        }
        .task {
            todayFoods = (await meal.getTodayFoods()).flatMap { $0.foods }
        }
        .padding(.top)
    }

}

#Preview {
    Dashboard()
        .environmentObject(MealsViewModel())
        .environmentObject(HealthViewModel())
}
