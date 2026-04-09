import Foundation

struct FoodQualityResult {
    let grade: FoodQualityGrade?
    let summary: String?
    let nutrientItems: [NutrientItem]
    let nutrientLevelsDescription: String
    let topConcernLabel: String?
}

struct QualitySummaryRequest {
    let key: String
    let prompt: String
}

protocol FoodQualityResultProvider {
    func makeResult(from data: FoodQualityData) -> FoodQualityResult
}

protocol QualitySummaryProvider {
    func makeFallbackSummary(from data: FoodQualityData) -> String?
    func makeAIRequest(
        for food: Food,
        data: FoodQualityData,
        fallbackSummary: String?
    ) -> QualitySummaryRequest?
}

extension QualitySummaryProvider {
    func makeFallbackSummary(from _: FoodQualityData) -> String? {
        nil
    }

    func makeAIRequest(
        for _: Food,
        data _: FoodQualityData,
        fallbackSummary _: String?
    ) -> QualitySummaryRequest? {
        nil
    }
}

protocol QualitySummaryResolver {
    func resolve(_ request: QualitySummaryRequest) async -> String?
}
