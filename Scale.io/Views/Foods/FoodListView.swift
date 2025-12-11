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
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowSeparator(.automatic)
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(food.brands)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }
}
