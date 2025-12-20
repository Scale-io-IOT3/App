import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    @EnvironmentObject var food: FoodViewModel
    @EnvironmentObject var bluetooth: BluetoothViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            CalorieBar(calories: health.calories ?? 0, goal: health.BMR ?? 1200)
            
            NavigationLink {
                TodayFoodsView()
            } label: {
                TodayCardView(foods: meal.today)
            }
            .buttonStyle(.plain)
            
            MacrosBreakdown(calories: health.calories ?? 0)
            
            HStack {
                CaloriesLeft(consumed: health.calories ?? 0, goal: Int(health.BMR ?? 1200))
                
                LastLoggedFoodView()
                    .environmentObject(health)
                    .environmentObject(food)
                    .environmentObject(bluetooth)
            }
            
            Spacer()
            
        }
        .environmentObject(meal)
        .padding(.horizontal)
        .navigationTitle("Dashboard")
        .task { await load() }
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
        .environmentObject(FoodViewModel())
        .environmentObject(BluetoothViewModel())
}
