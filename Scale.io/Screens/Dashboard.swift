import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    @State var todayFoods: [Food] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    CalorieBar(calories: health.daily ?? 0, goal: health.BMR ?? 1200)
                        .padding(.top)

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
                            ContentUnavailableView(
                                "Looks a little quiet here today.",
                                systemImage: "carrot.fill",
                                description: Text("Add a little something when you’re ready.")
                            )
                            .padding(.top, 50)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Dashboard")
            .task { await load() }
        }
    }

    private func load() async {
        self.todayFoods = (await meal.getTodayFoods()).flatMap { $0.foods }
        await health.getUserBMR()
        await health.getDailyCalories()
    }

}

#Preview {
    Dashboard()
        .environmentObject(MealsViewModel())
        .environmentObject(HealthViewModel())
}
