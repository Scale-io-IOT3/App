import Foundation

final class FallBackQualityService {
    struct Result {
        let grade: FoodQualityGrade?
        let summary: String?
        let nutrientItems: [NutrientItem]
        let nutrientLevelsDescription: String
        let topConcernLabel: String?
    }

    static let shared = FallBackQualityService()

    func makeResult(for food: Food) -> Result {
        let parsedGrade = FoodQualityGrade(rawGrade: food.grade)
        let parsedNutrients = parseNutrients(from: food.levels)
        let parsedTopConcern = topConcern(from: parsedNutrients)
        let fallbackSummary = makeSummary(
            grade: parsedGrade,
            topConcern: parsedTopConcern,
            hasNutrients: !parsedNutrients.isEmpty
        )

        return Result(
            grade: parsedGrade,
            summary: fallbackSummary,
            nutrientItems: parsedNutrients.map(\.item),
            nutrientLevelsDescription: nutrientLevelsDescription(from: parsedNutrients),
            topConcernLabel: parsedTopConcern?.item.label
        )
    }
}

extension FallBackQualityService {
    fileprivate struct ParsedNutrient {
        let item: NutrientItem
        let priority: Int
        let advice: String
    }

    fileprivate enum NutrientKind: Int, CaseIterable {
        case sugars = 0
        case saturatedFat = 1
        case salt = 2
        case fat = 3

        var label: String {
            switch self {
            case .fat: return "Fat"
            case .saturatedFat: return "Saturated Fat"
            case .sugars: return "Sugars"
            case .salt: return "Salt"
            }
        }

        func rawLevel(from levels: NutrientLevels) -> String? {
            switch self {
            case .fat: return levels.fat
            case .saturatedFat: return levels.saturatedFat
            case .sugars: return levels.sugars
            case .salt: return levels.salt
            }
        }

        func advice(for level: NutrientLevel) -> String {
            switch self {
            case .sugars:
                switch level {
                case .high:
                    return
                        "Tip: keep portions moderate and pair with protein or fiber to reduce sugar spikes."
                case .moderate:
                    return "Tip: avoid extra sweet add-ons and pair with protein or fiber."
                case .low:
                    return "Tip: sugar level looks manageable."
                }
            case .saturatedFat:
                switch level {
                case .high:
                    return
                        "Tip: balance this with lean protein and unsaturated fats like nuts, seeds, or olive oil."
                case .moderate:
                    return "Tip: keep the rest of the meal lighter in saturated fat."
                case .low:
                    return "Tip: saturated fat level looks manageable."
                }
            case .salt:
                switch level {
                case .high:
                    return "Tip: keep your next meals lower in sodium and hydrate well."
                case .moderate:
                    return "Tip: watch salty sauces and sides in the same meal."
                case .low:
                    return "Tip: sodium level looks manageable."
                }
            case .fat:
                switch level {
                case .high:
                    return "Tip: use a smaller portion and pair with vegetables or lean protein."
                case .moderate:
                    return "Tip: pair with high-fiber foods to improve fullness and balance."
                case .low:
                    return "Tip: fat level looks manageable."
                }
            }
        }
    }

    fileprivate func parseNutrients(from levels: NutrientLevels?) -> [ParsedNutrient] {
        guard let levels else { return [] }

        return NutrientKind.allCases.compactMap { kind in
            guard let level = NutrientLevel(rawValue: kind.rawLevel(from: levels))
            else { return nil }

            let priority: Int
            switch level {
            case .high: priority = 2
            case .moderate: priority = 1
            case .low: priority = 0
            }

            return ParsedNutrient(
                item: NutrientItem(
                    id: kind.label,
                    label: kind.label,
                    level: level
                ),
                priority: priority,
                advice: kind.advice(for: level)
            )
        }
    }

    fileprivate func topConcern(from nutrients: [ParsedNutrient]) -> ParsedNutrient? {
        nutrients
            .filter { $0.priority > 0 }
            .sorted { lhs, rhs in
                if lhs.priority != rhs.priority {
                    return lhs.priority > rhs.priority
                }
                return lhs.item.id < rhs.item.id
            }
            .first
    }

    fileprivate func nutrientLevelsDescription(from nutrients: [ParsedNutrient]) -> String {
        guard !nutrients.isEmpty else { return "Unavailable" }

        return nutrients.map {
            "\($0.item.label): \($0.item.level.displayLabel)"
        }.joined(separator: ", ")
    }

    fileprivate func baseSummary(for grade: FoodQualityGrade?) -> String? {
        switch grade {
        case .a:
            return "Excellent nutrition profile."
        case .b:
            return "Good everyday option."
        case .c:
            return "Moderate nutrition quality."
        case .d:
            return "Below-average nutrition quality."
        case .e:
            return "Lower nutrition quality option."
        case nil:
            return nil
        }
    }

    fileprivate func fallbackAdvice(for grade: FoodQualityGrade?) -> String? {
        switch grade {
        case .a:
            return "Keep foods like this in regular rotation and maintain variety across your week."
        case .b:
            return "Pair with vegetables, fruit, or whole grains for better overall balance."
        case .c:
            return "Improve this meal by adding lean protein and fiber-rich sides."
        case .d:
            return "Use smaller portions and pair with nutrient-dense whole foods."
        case .e:
            return "Keep portions small and balance the day with higher-quality foods."
        case nil:
            return nil
        }
    }

    fileprivate func makeSummary(
        grade: FoodQualityGrade?,
        topConcern: ParsedNutrient?,
        hasNutrients: Bool
    ) -> String? {
        if let topConcern {
            if let base = baseSummary(for: grade) {
                return "\(base) \(topConcern.advice)"
            }
            return "No overall grade available. \(topConcern.advice)"
        }

        if let base = baseSummary(for: grade), let fallback = fallbackAdvice(for: grade) {
            return "\(base) Tip: \(fallback)"
        }

        if hasNutrients {
            return
                "No overall grade available. Use nutrient levels to guide portions and meal pairings."
        }

        return nil
    }
}
