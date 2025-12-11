import Foundation
internal import HealthKit

class HKService {
    private let health = HKUtils()

    public func fetchDailyCalories(for date: Date) async -> Int {
        if let calories = await health.fetchDailyCalories(for: date) {
            let daily = await MainActor.run {
                return Int(calories)
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
