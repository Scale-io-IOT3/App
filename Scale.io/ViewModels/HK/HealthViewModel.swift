internal import Combine
import Foundation

class HealthViewModel: ObservableObject {
    @Published public var calories: Int? = nil
    @Published public var proteins: Double? = nil
    @Published public var carbs: Double? = nil
    @Published public var fat: Double? = nil
    @Published public var BMR: Double? = nil
    let service = HKService()

    public func getUserBMR() async {
        self.BMR = await service.calculateBMR()
    }

    public func getDailyCalories(for date: Date = .init()) async {
        self.calories = await service.fetchDailyCalories(for: date)
    }

    public func log(_ food: Food?) async -> Bool {
        guard let f = food else { return false }
        return await service.log(f)
    }

    public func getDailyMacros(for date: Date = .init()) async {
        proteins = await service.fetchDailyProteins(at: date)
        fat = await service.fetchDailyFat(at: date)
        carbs = await service.fetchDailyCarbs(at: date)
    }
}
