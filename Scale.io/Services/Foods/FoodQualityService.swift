import Foundation

struct FoodQualityService: QualitySummaryProvider, QualitySummaryResolver {
    static let shared = FoodQualityService()

    private let runtime: any QualitySummaryResolver

    init(runtime: any QualitySummaryResolver = FoodQualityAIRuntime()) {
        self.runtime = runtime
    }

    func makeAIRequest(
        for _: Food,
        data: FoodQualityData,
        fallbackSummary: String?
    ) -> QualitySummaryRequest? {
        guard fallbackSummary != nil else { return nil }

        return QualitySummaryRequest(
            key: data.requestKey,
            prompt: FoodQualityPromptTemplate.requestPrompt(
                foodName: data.foodName,
                grade: data.grade,
                nutrientLevelsDescription: data.nutrientLevelsDescription,
                topConcernLabel: data.topConcernLabel
            )
        )
    }

    func resolve(_ request: QualitySummaryRequest) async -> String? {
        await runtime.resolve(request)
    }
}

private struct FoodQualityPromptTemplate {
    static func requestPrompt(
        foodName: String,
        grade: FoodQualityGrade?,
        nutrientLevelsDescription: String,
        topConcernLabel: String?
    ) -> String {
        """
        Write a summary for this food item.

        Food name: \(foodName)
        Internal quality grade: \(grade?.rawValue ?? "Unavailable")
        Internal nutrient profile: \(nutrientLevelsDescription)
        Internal main concern: \(topConcernLabel ?? "None")
        """
    }
}
