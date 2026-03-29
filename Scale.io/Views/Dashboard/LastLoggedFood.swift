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
                    NoLoggedFoodCard()
                        .environmentObject(health)
                        .environmentObject(food)
                        .environmentObject(bluetooth)
                }
            )
            .buttonStyle(.plain)
        }
    }
}

private struct NoLoggedFoodCard: View {
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Last Logged", systemImage: "clock.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.accent)

                Text("No food logged yet")
                    .font(.subheadline.bold())

                Text("The last logged food of the day will appear here")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .buttonStyle(.plain)
    }
}
