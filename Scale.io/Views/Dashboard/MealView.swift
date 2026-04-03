import SwiftUI

struct FoodCard: View {
    let food: Food
    @State private var selected: Food? = nil
    var last: Bool = false

    var body: some View {
        Button {
            selected = food
        } label: {
            FoodCardContentView(food: food, last: last)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
        .sheet(item: $selected) { food in
            FoodDetailsView(food: food, action: false)
                .resize()
        }
    }
}

private struct FoodCardContentView: View {
    let food: Food
    let last: Bool

    var body: some View {
        HStack(spacing: 12) {
            MacrosChartView(food: food, size: 80)
            VStack(alignment: .leading, spacing: 4) {
                if last {
                    Label("Last Logged", systemImage: "clock.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.accent)
                }

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
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
    }
}

#Preview {
    FoodCard(food: M_foods[0])
}
