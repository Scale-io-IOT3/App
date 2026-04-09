import Foundation

struct FoodQualityData {
    struct NutrientInsight: Equatable {
        let item: NutrientItem
        let priority: Int
        let advice: String
    }

    let foodName: String
    let brandName: String
    let grade: FoodQualityGrade?
    let nutrientInsights: [NutrientInsight]
    let requestKey: String

    init(food: Food) {
        self.foodName = food.name.normalizedInlineText
        self.brandName = food.brands.normalizedInlineText
        self.grade = FoodQualityGrade(rawGrade: food.grade)
        self.nutrientInsights = Self.parseNutrients(from: food.levels)
        self.requestKey = Self.makeRequestKey(
            foodName: foodName,
            brandName: brandName,
            grade: grade,
            nutrientInsights: nutrientInsights
        )
    }

    var nutrientItems: [NutrientItem] {
        nutrientInsights.map(\.item)
    }

    var nutrientLevelsDescription: String {
        guard !nutrientInsights.isEmpty else { return "Unavailable" }

        return nutrientInsights.map {
            "\($0.item.label): \($0.item.level.displayLabel)"
        }.joined(separator: ", ")
    }

    var topConcern: NutrientInsight? {
        nutrientInsights
            .filter { $0.priority > 0 }
            .sorted { lhs, rhs in
                if lhs.priority != rhs.priority {
                    return lhs.priority > rhs.priority
                }
                return lhs.item.id < rhs.item.id
            }
            .first
    }

    var topConcernLabel: String? {
        topConcern?.item.label
    }

    var hasNutrients: Bool {
        !nutrientInsights.isEmpty
    }
}

extension FoodQualityData {
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

    fileprivate static func parseNutrients(from levels: NutrientLevels?) -> [NutrientInsight] {
        guard let levels else { return [] }

        return NutrientKind.allCases.compactMap { kind in
            guard let level = NutrientLevel(rawValue: kind.rawLevel(from: levels))
            else { return nil }

            return NutrientInsight(
                item: NutrientItem(
                    id: kind.label,
                    label: kind.label,
                    level: level
                ),
                priority: Self.priority(for: level),
                advice: kind.advice(for: level)
            )
        }
    }

    fileprivate static func priority(for level: NutrientLevel) -> Int {
        switch level {
        case .high: return 2
        case .moderate: return 1
        case .low: return 0
        }
    }

    fileprivate static func makeRequestKey(
        foodName: String,
        brandName: String,
        grade: FoodQualityGrade?,
        nutrientInsights: [NutrientInsight]
    ) -> String {
        let nutrientLevelsByLabel = Dictionary(
            uniqueKeysWithValues: nutrientInsights.map { insight in
                (insight.item.label, insight.item.level.rawValue)
            }
        )

        let gradeComponent = grade?.rawValue.normalizedInlineText.lowercased() ?? "nil"

        return [
            foodName.lowercased(),
            brandName.lowercased(),
            gradeComponent,
            nutrientLevelsByLabel[NutrientKind.fat.label] ?? "nil",
            nutrientLevelsByLabel[NutrientKind.saturatedFat.label] ?? "nil",
            nutrientLevelsByLabel[NutrientKind.sugars.label] ?? "nil",
            nutrientLevelsByLabel[NutrientKind.salt.label] ?? "nil",
        ].joined(separator: "|")
    }
}

extension String {
    nonisolated var normalizedInlineText: String {
        replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Optional where Wrapped == String {
    nonisolated var normalizedInlineText: String {
        guard let text = self else { return "" }
        return text.normalizedInlineText
    }
}
