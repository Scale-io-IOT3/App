import SwiftUI

struct MacrosGrid: View {
    let food: Food

    var body: some View {
        let macros: [(macro: MacrosColor, grams: Double, percent: Double)] = [
            (.carbs, food.macros.carbohydrates, food.macros.percentages.carbs),
            (.proteins, food.macros.proteins, food.macros.percentages.proteins),
            (.fat, food.macros.fat, food.macros.percentages.fat),
        ]

        VStack(alignment: .leading, spacing: 14) {
            Text("Nutritional Profile")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    ForEach(macros, id: \.macro) { item in
                        MacroCell(title: item.macro.rawValue, value: item.grams, color: item.macro.color)
                    }
                }

                GridRow {
                    ForEach(macros, id: \.macro) { item in
                        MacroProgress(value: item.percent, color: item.macro.color)
                    }
                }
            }
        }
        .appCard(cornerRadius: 18, padding: 16)
    }
}

struct MacroCell: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(color)
            Text("\(value, specifier: "%.1f")g")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MacroProgress: View {
    let value: Double
    let color: Color

    var body: some View {
        ProgressView(value: value / 100)
            .tint(color)
            .frame(maxWidth: .infinity)
    }
}
