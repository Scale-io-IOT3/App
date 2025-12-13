import Foundation
internal import HealthKit

class HKService {
    private let health = HKUtils.shared

    private(set) lazy var age: Int = health.getAge() ?? 0
    private(set) lazy var sex: HKBiologicalSex = health.getSex() ?? .notSet

    public func fetchDailyCalories(for date: Date = .init()) async -> Int {
        let value = await query(.dietaryEnergyConsumed, at: date, unit: .kilocalorie())
        return Int(value)
    }

    public func fetchDailyCarbs(at date: Date) async -> Double {
        await query(.dietaryCarbohydrates, at: date, unit: .gram())
    }

    public func fetchDailyProteins(at date: Date) async -> Double {
        await query(.dietaryProtein, at: date, unit: .gram())
    }

    public func fetchDailyFat(at date: Date) async -> Double {
        await query(.dietaryFatTotal, at: date, unit: .gram())
    }

    private func query(_ id: HKQuantityTypeIdentifier, at date: Date, unit: HKUnit) async -> Double {
        await health.query(for: id, at: date, using: unit) ?? 0
    }

    public func calculateBMR() async -> Double {
        guard
            let weight = await health.fetchLatestWeight(),
            let height = await health.fetchLatestHeight()
        else { return 0 }
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
        guard health.canWriteNutrition() else {
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
