import Foundation
internal import HealthKit

class HKService {
    private let health = HKUtils()

    public func fetchDailyCalories(for date: Date = .init()) async -> Int {
        return await self.query(for: .dietaryEnergyConsumed, at: date)
    }

    public func fetchDailyCarbs(at date: Date) async -> Double {
        return await self.query(for: .dietaryCarbohydrates, at: date)
    }

    public func fetchDailyProteins(at date: Date) async -> Double {
        return await self.query(for: .dietaryProtein, at: date)
    }

    public func fetchDailyFat(at date: Date) async -> Double {
        return await self.query(for: .dietaryFatTotal, at: date)
    }

    private func query(for macro: HKQuantityTypeIdentifier, at date: Date) async -> Double {
        return await health.query(for: macro, at: date) ?? 0
    }

    private func query(for macro: HKQuantityTypeIdentifier, at date: Date) async -> Int {
        let value = await health.query(for: macro, at: date) ?? 0
        return Int(value)
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

    public func log(_ food: Food) async -> Bool {
        if !health.canWriteNutrition() {
            print("Cannot save — HealthKit permission not granted yet.")
            return false
        }

        return await health.saveNutrition(
            carbs: food.macros.carbohydrates,
            fat: food.macros.fat,
            protein: food.macros.proteins,
            calories: food.macros.calories
        )
    }

}
