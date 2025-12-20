import SwiftUI

struct LastLoggedFoodView: View {
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var meal: MealsViewModel
    @EnvironmentObject var food: FoodViewModel
    @EnvironmentObject var bluetooth: BluetoothViewModel

    var body: some View {
        if !meal.today.isEmpty {
            FoodCard(food: meal.today.last!)
        } else {
            NavigationLink(
                destination: {
                    AddFood()
                },
                label: {
                    NoLoogedFoodCard()
                        .environmentObject(health)
                        .environmentObject(food)
                        .environmentObject(bluetooth)
                }
            )
            .buttonStyle(.plain)
        }
    }
}

private struct NoLoogedFoodCard: View {
    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("No foods logged yet")
                    .font(.subheadline.bold())

                Text("The last logged food of the day will appear here")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)

        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
