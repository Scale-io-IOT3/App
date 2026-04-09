import Foundation

struct FoodQualityViewModel {
    let grade: FoodQualityGrade?
    let summary: String?
    let nutrientItems: [NutrientItem]
    let aiSummaryRequest: FoodQualityService.Request?
    let summaryRequestID: String

    private let aiService: FoodQualityService

    var hasContent: Bool {
        grade != nil || summary != nil || !nutrientItems.isEmpty
    }

    init(
        food: Food,
        hardcodedService: FallBackQualityService = .shared,
        aiService: FoodQualityService = .shared
    ) {
        let hardcoded = hardcodedService.makeResult(for: food)
        let requestID = aiService.requestID(for: food)

        self.grade = hardcoded.grade
        self.summary = hardcoded.summary
        self.nutrientItems = hardcoded.nutrientItems
        self.summaryRequestID = requestID
        self.aiSummaryRequest = aiService.makeRequest(for: food, hardcoded: hardcoded)
        self.aiService = aiService
    }

    func resolveDisplaySummary() async -> String? {
        guard let fallback = summary else { return nil }
        guard let request = aiSummaryRequest else { return fallback }
        return await aiService.resolve(request) ?? fallback
    }
}
