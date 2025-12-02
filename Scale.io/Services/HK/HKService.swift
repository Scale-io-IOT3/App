import Foundation
internal import HealthKit

class HKService {
    private let health = HKUtils()

    public func fetchDailyCalories(for date: Date) async -> Double {
        if let calories = await health.fetchDailyCalories(for: date) {
            let daily = await MainActor.run {
                return calories
            }

            return daily
        }

        return 0
    }

    public func calculateBMR() async -> Double {
        guard
            let age = health.getAge(),
            let sex = health.getSex(),
            let weight = await health.fetchLatestWeight(),
            let height = await health.fetchLatestHeight()
        else {
            return 0
        }
        let h = height * 100

        switch sex {
        case .male:
            return 10 * weight + 6.25 * h - 5 * Double(age) + 5
        case .female:
            return 10 * weight + 6.25 * h - 5 * Double(age) - 161
        default:
            return 0
        }
    }
}
