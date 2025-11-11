import SwiftUI

struct MacrosGrid: View {
  let food: Food

  var body: some View {
    let macros: [(macro: MacrosColor, grams: Double, percent: Double)] = [
      (.carbs, food.macros.carbohydrates, food.macros.percentages.carbs),
      (.proteins, food.macros.proteins, food.macros.percentages.proteins),
      (.fats, food.macros.fat, food.macros.percentages.fat),
    ]

    Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 10) {
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
    .padding(.bottom, 30)
  }
}

struct MacroCell: View {
  let title: String
  let value: Double
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.headline)
        .foregroundStyle(color)
      Text("\(value, specifier: "%.1f")g")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(alignment: .leading)
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

