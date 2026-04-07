import SwiftUI

struct FoodDetailsView: View {
    let food: Food?
    var onRegister: ((_ food: Food) async -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var quantity: Double
    @State private var measurement: Measurement = .grams

    init(food: Food?, onRegister: ((_ food: Food) async -> Void)? = nil) {
        self.food = food
        self.onRegister = onRegister
        _quantity = State(initialValue: max(food?.quantity ?? 100, 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let activeFood {
                FoodHeaderView(food: activeFood)
                if onRegister != nil {
                    servingEditor
                }
                MacrosGrid(food: activeFood)
                FoodQualityView(food: activeFood)

                if let onRegister {
                    Spacer(minLength: 0)

                    CustomButton("Add Food", icon: "plus") {
                        guard let foodForLogging else { return }
                        Task { await onRegister(foodForLogging) }
                        dismiss()
                    }
                    .disabled(foodForLogging == nil)
                }
            }
        }
        .padding(16)
    }

    private var activeFood: Food? {
        guard let food else { return nil }
        guard onRegister != nil else { return food }
        guard let grams = servingInGrams else { return food }
        return food.scaled(to: grams)
    }

    private var foodForLogging: Food? {
        guard let food else { return nil }
        guard onRegister != nil else { return food }
        guard let grams = servingInGrams else { return nil }
        return food.scaled(to: grams)
    }

    private var servingEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Serving Size")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                amountField
                unitPicker

                Spacer(minLength: 0)

                Stepper(
                    "", value: $quantity, in: 0...2500, step: measurement.servingStep
                )
                .labelsHidden()
            }
        }
    }

    private var amountField: some View {
        TextField(
            "Amount",
            value: $quantity,
            format: .number.precision(
                .fractionLength(0...1)
            )
        )
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .monospacedDigit()
        .frame(width: 90)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var unitPicker: some View {
        Menu {
            ForEach(Measurement.allCases, id: \.self) { unit in
                Button {
                    measurement = unit
                } label: {
                    if unit == measurement {
                        Label(unit.rawValue, systemImage: "checkmark")
                    } else {
                        Text(unit.rawValue)
                    }
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 6) {
                Spacer()
                
                Text(measurement.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 72)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .tint(.primary)
    }

    private var servingInGrams: Double? {
        let grams = quantity * measurement.toGramsFactor
        guard grams.isFinite, grams > 0 else { return nil }
        return grams
    }
}

private struct FoodQualityView: View {
    private let vm: FoodQualityViewModel

    init(food: Food) {
        self.vm = FoodQualityViewModel(food: food)
    }

    var body: some View {
        if vm.hasContent {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text("Food Quality")
                        .font(.headline)

                    Spacer()

                    if let grade = vm.grade {
                        gradeBadge(grade)
                    }
                }

                if let summary = vm.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                }

                if !vm.nutrientItems.isEmpty {
                    Text("Nutrient Levels")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                        ],
                        alignment: .leading,
                        spacing: 10
                    ) {
                        ForEach(vm.nutrientItems) { item in
                            NutrientLevelPill(item: item)
                        }
                    }
                }
            }
            .appCard(cornerRadius: 18, padding: 16)
        }
    }

    private func gradeBadge(_ grade: FoodQualityViewModel.Grade) -> some View {
        let color = gradeColor(for: grade)

        return ZStack {
            Circle()
                .fill(color.opacity(0.16))

            Circle()
                .stroke(color.opacity(0.4), lineWidth: 1)

            Text(grade.rawValue)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .textCase(.uppercase)
        }
        .frame(width: 30, height: 30)
        .accessibilityLabel("Grade \(grade.rawValue)")
    }

    private func gradeColor(for grade: FoodQualityViewModel.Grade) -> Color {
        switch grade {
        case .a: return .green
        case .b: return .teal
        case .c: return .orange
        case .d: return .red
        case .e: return .pink
        }
    }
}

private struct NutrientLevelPill: View {
    let item: FoodQualityViewModel.NutrientItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 6) {
                Circle()
                    .fill(levelColor(item.level))
                    .frame(width: 7, height: 7)
                Text(item.levelLabel)
                    .font(.caption.bold())
                    .foregroundStyle(levelColor(item.level))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(levelColor(item.level).opacity(0.12))
        )
    }

    private func levelColor(_ level: FoodQualityViewModel.NutrientLevel) -> Color {
        switch level {
        case .low: return .green
        case .moderate: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    FoodDetailsView(food: M_foods[0]) { food in
        _ = food
    }
}
