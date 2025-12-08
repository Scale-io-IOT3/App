import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    @State var todayFoods: [Food] = []
    var todayCalories: Int { todayFoods.compactMap { $0.calories }.reduce(0, +) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CalorieBar(calories: todayCalories, goal: health.BMR ?? 1200)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Today's Food").font(.title2.bold())
                        Spacer()
                    }

                    Group {
                        if !todayFoods.isEmpty {
                            ForEach(todayFoods, id: \.id) { food in
                                FoodCard(food: food)
                            }
                        } else {
                            ContentUnavailableView(
                                "Looks a little quiet here today.",
                                systemImage: "carrot.fill",
                                description: Text("Add a little something when you’re ready.")
                            )
                            .padding(.top, 50)
                        }
                    }

                }
                .padding(.horizontal)
            }
        }
        .task {
            todayFoods = (await meal.getTodayFoods()).flatMap { $0.foods }
            await health.getUserBMR()
        }
        .padding(.top)
    }

}

#Preview {
    Dashboard()
        .environmentObject(MealsViewModel())
        .environmentObject(HealthViewModel())
}
