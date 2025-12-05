import SwiftUI

struct FoodCard: View {
    let food: Food
    @State private var selected: Food? = nil

    var body: some View {
        Button {
            selected = food
        } label: {
            FoodCardContentView(food: food)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .sheet(item: $selected) { food in
            FoodDetailsView(food: food)
                .presentationDetents([.fraction(0.48)])
        }
    }
}

private struct FoodCardContentView: View {
    let food: Food
    var body: some View {
        HStack(spacing: 12) {
            MacrosChartView(food: food, size: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if !food.brands.isEmpty {
                    Text(food.brands)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

#Preview {
    FoodCard(food: M_foods[0])
}
