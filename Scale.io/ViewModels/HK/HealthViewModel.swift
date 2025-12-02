internal import Combine
import Foundation

class HealthViewModel: ObservableObject {
    @Published public var daily: Double? = nil
    @Published public var BMR: Double? = nil
    let service = HKService()

    public func getUserBMR() async {
        self.BMR = await service.calculateBMR()
    }

    public func getDailyCalories(for date: Date = .init()) async {
        self.daily = await service.fetchDailyCalories(for: date)
    }
}
