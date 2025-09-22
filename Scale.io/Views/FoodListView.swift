import SwiftUI

struct FoodListView: View {
    @Binding var foods: [Food]
    var body: some View {
        List(foods) { food in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(food.name)
                        .font(.headline)

                    Spacer()

                    Text(food.brands)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                .truncationMode(.tail)

                HStack(spacing: 12) {
                    Text("Calories: \(food.macros.calories)")
                    Text("Carbs: \(format(food.macros.carbohydrates))g")
                    Text("Fat: \(format(food.macros.fat))g")
                    Text("Protein: \(format(food.macros.proteins))g")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Text("C \(format(food.macros.percentages.carbs))%")
                    Text("F \(format(food.macros.percentages.fat))%")
                    Text("P \(format(food.macros.percentages.proteins))%")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Foods")
    }

    private func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
