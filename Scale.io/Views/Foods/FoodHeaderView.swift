import Charts
import SwiftUI

struct FoodHeaderView: View {
    let food: Food
    var body: some View {
        HStack(spacing: 24) {
            MacrosChartView(food: food)
            VStack(alignment: .leading) {
                Text(food.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(food.brands)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
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

    init(calories: Int, carbs: Double, proteins: Double, fat: Double, size: CGFloat = 100, show: Bool = false) {
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

    var body: some View {
        ZStack {
            Chart(macros, id: \.m.rawValue) { m in
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
}
