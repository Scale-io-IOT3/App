import SwiftUI

struct MacrosBreakdown: View {
    @EnvironmentObject var health: HealthViewModel
    let calories: Int

    private var carbGrams: Double { health.carbs ?? 0 }
    private var proteinGrams: Double { health.proteins ?? 0 }
    private var fatGrams: Double { health.fat ?? 0 }

    private var carbEnergy: Double { carbGrams * 4 }
    private var proteinEnergy: Double { proteinGrams * 4 }
    private var fatEnergy: Double { fatGrams * 9 }

    private var totalMacroEnergy: Double {
        max(carbEnergy + proteinEnergy + fatEnergy, 1)
    }

    private func grams(for macro: MacrosColor) -> Double {
        switch macro {
        case .carbs:
            return carbGrams
        case .proteins:
            return proteinGrams
        case .fat:
            return fatGrams
        }
    }

    private func percentage(for macro: MacrosColor) -> Double {
        switch macro {
        case .carbs:
            return carbEnergy / totalMacroEnergy
        case .proteins:
            return proteinEnergy / totalMacroEnergy
        case .fat:
            return fatEnergy / totalMacroEnergy
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Macro Balance")
                    .font(.headline)
                Spacer()
                Text("\(calories) kcal")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                MacrosChartView(
                    calories: calories,
                    carbs: carbEnergy,
                    proteins: proteinEnergy,
                    fat: fatEnergy,
                    size: 120
                )

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(MacrosColor.allCases) { macro in
                        MacroRow(
                            title: macro.rawValue,
                            grams: grams(for: macro),
                            percentage: percentage(for: macro),
                            color: macro.color
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .animation(.easeInOut, value: health.calories)
    }

}

private struct MacroRow: View {
    let title: String
    let grams: Double
    let percentage: Double
    let color: Color

    var gramText: String { String(format: "%.1f", grams) }
    var percentText: String { "\(Int(percentage * 100))%" }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)

                Spacer()

                Text("\(gramText) g")
                    .font(.subheadline.bold())

                Text(percentText)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.18))
                    Capsule()
                        .fill(color.opacity(0.95))
                        .frame(width: geo.size.width * max(min(percentage, 1), 0))
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    MacrosBreakdown(calories: 1200)
        .environmentObject(HealthViewModel())
}
