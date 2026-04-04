import SwiftUI

struct LastLoggedFoodView: View {
    @EnvironmentObject var meal: MealsViewModel
    var body: some View {
        content()
    }

    @ViewBuilder
    private func content() -> some View {
        if let lastFood = meal.today.last {
            FoodCard(food: lastFood)
        } else {
            NoLoggedFoodCard()
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
