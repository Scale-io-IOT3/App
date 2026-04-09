import Foundation

final class FallBackQualityService: FoodQualityResultProvider, QualitySummaryProvider {
    static let shared = FallBackQualityService()

    func makeResult(for food: Food) -> FoodQualityResult {
        makeResult(from: FoodQualityData(food: food))
    }

    func makeResult(from data: FoodQualityData) -> FoodQualityResult {
        let fallbackSummary = makeFallbackSummary(from: data)

        return FoodQualityResult(
            grade: data.grade,
            summary: fallbackSummary,
            nutrientItems: data.nutrientItems,
            nutrientLevelsDescription: data.nutrientLevelsDescription,
            topConcernLabel: data.topConcernLabel
        )
    }
}

extension FallBackQualityService {
    func makeFallbackSummary(from data: FoodQualityData) -> String? {
        makeSummary(
            grade: data.grade,
            topConcern: data.topConcern,
            hasNutrients: data.hasNutrients
        )
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
        topConcern: FoodQualityData.NutrientInsight?,
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
