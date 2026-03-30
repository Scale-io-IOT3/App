import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    @EnvironmentObject var food: FoodViewModel
    @EnvironmentObject var bluetooth: BluetoothViewModel

    private var goal: Int {
        max(Int(health.BMR ?? 1200), 1)
    }

    private var consumed: Int {
        max(health.calories ?? 0, 0)
    }

    private var intakeScore: Double {
        let value = Double(consumed) / Double(goal)
        return min(max(value, 0), 1)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 12) {
                    DashboardHeroCard(
                        score: intakeScore,
                        consumed: consumed,
                        goal: goal,
                        foodsCount: meal.today.count
                    )
                    CaloriesLeft(consumed: consumed, goal: goal)
                }

                WeeklyCaloriesCard(meals: meal.meals, goal: goal)

                MacrosBreakdown(calories: consumed)

                NavigationLink {
                    TodayFoodsView()
                } label: {
                    TodayCardView(foods: meal.today)
                }
                .buttonStyle(.plain)

                LastLoggedFoodView()
                    .environmentObject(health)
                    .environmentObject(food)
                    .environmentObject(bluetooth)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .environmentObject(meal)
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await load() }
        .task { await load() }
    }

    private func load() async {
        await meal.getTodayFoods()
        await health.getUserBMR()
        await health.getDailyMacros()
    }

}

private struct DashboardHeroCard: View {
    let score: Double
    let consumed: Int
    let goal: Int
    let foodsCount: Int

    private var progress: Double {
        Double(consumed) / Double(max(goal, 1))
    }

    private var scoreText: String {
        switch score {
        case ..<0.5: return "Warm-up"
        case ..<0.9: return "On Track"
        case 0.9...1.1: return "Goal Zone"
        default: return "Above Goal"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today at a glance")
                .font(.headline)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(consumed)")
                    .font(.title.bold())

                Text("/ \(goal) kcal")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int((min(max(progress, 0), 1)) * 100))%")
                    .font(.headline.bold())
                    .foregroundStyle(.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.accentColor, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: {
                                let raw = progress
                                let finite = raw.isFinite ? raw : 0
                                let clamped = min(max(finite, 0), 1)
                                let w = geo.size.width * clamped
                                return w.isFinite && w >= 0 ? w : 0
                            }(),
                            height: 20
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: progress)
                }
            }
            .frame(height: 20)

            HStack(spacing: 8) {
                HeroPill(title: scoreText, icon: "sparkles")
                HeroPill(
                    title: "\(foodsCount) food\(foodsCount == 1 ? "" : "s")", icon: "fork.knife")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct HeroPill: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.accentColor.opacity(0.18))
            )
            .foregroundStyle(.accent)
    }
}

#Preview {
    Dashboard()
        .environmentObject(MealsViewModel())
        .environmentObject(HealthViewModel())
        .environmentObject(FoodViewModel())
        .environmentObject(BluetoothViewModel())
}
