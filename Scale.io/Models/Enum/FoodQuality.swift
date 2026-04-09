import Foundation

enum FoodQualityGrade: String {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"

    init?(rawGrade: String?) {
        guard
            let rawGrade = rawGrade?
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
        guard
            let normalized = rawValue?
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