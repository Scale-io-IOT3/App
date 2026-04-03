import Charts
import SwiftUI

struct FoodHeaderView: View {
    let food: Food

    var body: some View {
        HStack(spacing: 24) {
            MacrosChartView(food: food, size: 110)
            VStack(alignment: .leading, spacing: 8) {
                Text(food.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                if !food.brands.isEmpty {
                    Text(food.brands)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Text("Serving: \(food.quantity.formatted(.number.precision(.fractionLength(0)))) g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .appCard(cornerRadius: 18, padding: 16)
    }
}

struct MacrosChartView: View {
    var size: CGFloat
    var calories: Int
    var carbs: Double
    var proteins: Double
    var fat: Double
    var macros: [(m: MacrosColor, value: Double)] = []
    var showCalories: Bool

    init(food: Food, size: CGFloat = 100, show: Bool = true) {
        self.size = size
        self.calories = food.macros.calories
        self.carbs = food.macros.percentages.carbs
        self.proteins = food.macros.percentages.proteins
        self.fat = food.macros.percentages.fat
        self.showCalories = show
        self.macros = [
            (.carbs, carbs),
            (.fat, fat),
            (.proteins, proteins),
        ]
    }

    init(
        calories: Int, carbs: Double, proteins: Double, fat: Double, size: CGFloat = 100,
        show: Bool = false
    ) {
        self.size = size
        self.calories = calories
        self.carbs = carbs
        self.proteins = proteins
        self.fat = fat
        self.showCalories = show
        self.macros = [
            (.carbs, carbs),
            (.fat, fat),
            (.proteins, proteins),
        ]
    }

    private var chartData: [(m: MacrosColor, value: Double)] {
        macros.map { macro in
            let safeValue = macro.value.isFinite ? max(macro.value, 0) : 0
            return (macro.m, safeValue)
        }
    }

    private var hasRenderableData: Bool {
        chartData.contains(where: { $0.value > 0 })
    }

    var body: some View {
        ZStack {
            MacrosChart()
            if showCalories {
                VStack(spacing: 2) {
                    Text("\(self.calories)")
                        .font(.system(size: size * 0.25, weight: .bold))
                    Text("kcal")
                        .font(.system(size: size * 0.1))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func MacrosChart() -> some View {
        if hasRenderableData {
            Chart(chartData, id: \.m.rawValue) { m in
                SectorMark(
                    angle: .value("Percentage", m.value),
                    innerRadius: .ratio(0.7),
                    angularInset: 1
                )
                .foregroundStyle(by: .value("Macro", m.m.rawValue))
            }
            .chartForegroundStyleScale([
                "Carbs": MacrosColor.carbs.color,
                "Fat": MacrosColor.fat.color,
                "Protein": MacrosColor.proteins.color,
            ])
            .chartLegend(.hidden)
        } else {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: size * 0.15)

                if !showCalories {
                    Text("No data")
                        .font(.system(size: max(size * 0.11, 10), weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
