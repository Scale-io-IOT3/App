import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                CalorieBar(calories: health.calories ?? 0, goal: health.BMR ?? 1200)

                VStack(spacing: 16) {
                    NavigationLink {
                        TodayFoodsView()
                            .environmentObject(meal)
                    } label: {
                        TodayCardView(foods: meal.today)
                    }
                    .buttonStyle(.plain)
                }

                if let calories = health.calories, calories > 0 {
                    HStack{
                        MacrosBreakdown(calories: calories)
                            .environmentObject(health)
                        
                        Spacer()
                    }
                }

                Spacer()

            }
            .padding(.horizontal)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
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

private struct TodayCardView: View {
    let foods: [Food]
    private let color: Color = .accentColor
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text("Today’s foods")
                        .font(.headline)

                    Spacer()

                    Text(
                        foods.isEmpty
                            ? "No foods yet"
                            : "\(foods.count) food\(foods.count > 1 ? "s" : "")"
                    )
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .clipShape(Capsule())
                }

                Text("View all foods registered today")
                    .font(.subheadline)
                    .foregroundStyle(foods.isEmpty ? .tertiary : .secondary)

            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
