import Foundation

struct FoodQualityViewModel {
    let grade: FoodQualityGrade?
    let summary: String?
    let nutrientItems: [NutrientItem]
    let aiSummaryRequest: QualitySummaryRequest?
    let summaryRequestID: String

    private let aiSummaryResolver: any QualitySummaryResolver

    var hasContent: Bool {
        grade != nil || summary != nil || !nutrientItems.isEmpty
    }

    init(
        food: Food,
        hardcodedService: any FoodQualityResultProvider = FallBackQualityService.shared,
        aiSummaryProvider: any QualitySummaryProvider = FoodQualityService.shared,
        aiSummaryResolver: any QualitySummaryResolver = FoodQualityService.shared
    ) {
        let qualityData = FoodQualityData(food: food)
        let hardcoded = hardcodedService.makeResult(from: qualityData)
        let request = aiSummaryProvider.makeAIRequest(
            for: food,
            data: qualityData,
            fallbackSummary: hardcoded.summary
        )

        self.grade = hardcoded.grade
        self.summary = hardcoded.summary
        self.nutrientItems = hardcoded.nutrientItems
        self.aiSummaryRequest = request
        self.summaryRequestID = request?.key ?? qualityData.requestKey
        self.aiSummaryResolver = aiSummaryResolver
    }

    func resolveDisplaySummary() async -> String? {
        guard let fallback = summary else { return nil }
        guard let request = aiSummaryRequest else { return fallback }
        return await aiSummaryResolver.resolve(request) ?? fallback
    }
}
