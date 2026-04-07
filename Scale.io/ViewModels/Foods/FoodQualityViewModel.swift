import Foundation

struct FoodQualityViewModel {
    enum Grade: String {
        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
        case e = "E"

        init?(rawGrade: String?) {
            guard let rawGrade = rawGrade?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .uppercased(),
                !rawGrade.isEmpty
            else {
                return nil
            }

            self.init(rawValue: String(rawGrade.prefix(1)))
        }
    }

    enum NutrientLevel: String {
        case low
        case moderate
        case high

        init?(rawValue: String?) {
            guard let normalized = rawValue?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            else {
                return nil
            }

            self.init(rawValue: normalized)
        }

        var displayLabel: String {
            rawValue.capitalized
        }
    }

    struct NutrientItem: Identifiable, Equatable {
        let id: String
        let label: String
        let level: NutrientLevel

        var levelLabel: String {
            level.displayLabel
        }
    }

    let grade: Grade?
    let summary: String?
    let nutrientItems: [NutrientItem]

    var hasContent: Bool {
        grade != nil || summary != nil || !nutrientItems.isEmpty
    }

    init(food: Food) {
        let parsedGrade = Grade(rawGrade: food.grade)
        let parsedNutrients = Self.parseNutrients(from: food.levels)

        self.grade = parsedGrade
        self.nutrientItems = parsedNutrients.map(\.item)
        self.summary = Self.makeSummary(
            grade: parsedGrade,
            topConcern: Self.topConcern(from: parsedNutrients),
            hasNutrients: !parsedNutrients.isEmpty
        )
    }
}

private extension FoodQualityViewModel {
    struct ParsedNutrient {
        let item: NutrientItem
        let priority: Int
        let advice: String
    }

    enum NutrientKind: Int, CaseIterable {
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
                    return "Tip: keep portions moderate and pair with protein or fiber to reduce sugar spikes."
                case .moderate:
                    return "Tip: avoid extra sweet add-ons and pair with protein or fiber."
                case .low:
                    return "Tip: sugar level looks manageable."
                }
            case .saturatedFat:
                switch level {
                case .high:
                    return "Tip: balance this with lean protein and unsaturated fats like nuts, seeds, or olive oil."
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

    static func parseNutrients(from levels: NutrientLevels?) -> [ParsedNutrient] {
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

    static func topConcern(from nutrients: [ParsedNutrient]) -> ParsedNutrient? {
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

    static func baseSummary(for grade: Grade?) -> String? {
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

    static func fallbackAdvice(for grade: Grade?) -> String? {
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

    static func makeSummary(grade: Grade?, topConcern: ParsedNutrient?, hasNutrients: Bool) -> String? {
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
            return "No overall grade available. Use nutrient levels to guide portions and meal pairings."
        }

        return nil
    }
}
