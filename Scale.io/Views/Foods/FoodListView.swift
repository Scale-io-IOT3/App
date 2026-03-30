import SwiftUI

struct FoodListView: View {
    @EnvironmentObject var foodVm: FoodViewModel
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool

    var body: some View {
        List {
            ForEach(foods) { food in
                Button {
                    foodVm.selected = food
                    presentSheet = true
                } label: {
                    FoodRowView(food: food)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.automatic)
                .listRowBackground(Color.clear)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .listStyle(.plain)
        .animation(.easeIn, value: foods)
    }
}

struct FoodRowView: View {
    let food: Food

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(food.brands)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(food.macros.calories) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
