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
            Image(systemName: "chevron.right")
              .font(.system(size: 13, weight: .semibold))
              .foregroundStyle(.tertiary)
          }
          .padding(.vertical, 10)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowSeparator(.automatic)
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(Color(.systemGroupedBackground))
    .animation(.smooth, value: foods)
  }
}
