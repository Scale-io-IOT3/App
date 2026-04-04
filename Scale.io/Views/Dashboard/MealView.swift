import SwiftUI

struct FoodCard: View {
    let food: Food
    @State private var selected: Food? = nil
    var tags: [FoodTagKind]? = nil

    var body: some View {
        Button {
            selected = food
        } label: {
            FoodCardContentView(
                food: food,
                tags: tags ?? food.tags
            )
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .sheet(item: $selected) { food in
            FoodDetailsView(food: food)
                .resizeWithoutAction()
        }
    }
}

private struct FoodCardContentView: View {
    let food: Food
    let tags: [FoodTagKind]

    var body: some View {
        HStack(spacing: 12) {
            MacrosChartView(food: food, size: 80)
            VStack(alignment: .leading, spacing: 6) {
                if !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(tags.prefix(2)), id: \.self) { kind in
                            FoodTag(kind: kind)
                        }
                    }
                }

                Text(food.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                if !food.brands.isEmpty {
                    Text(food.brands)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
    }
}

#Preview {
    FoodCard(food: M_foods[0], tags: [.lastLogged, .mostCalories])
}
