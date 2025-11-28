import Foundation
import HealthKit

class FoodService {
    private let client = FoodsClient.shared
    private let store = HKHealthStore()

    public func fetchFoods(request: FoodRequest) async throws -> [Food] {
        let response = try await client.fetch(request)
        return response.foods
    }

    private func requestAuth() {
        let dataTypesToRead: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        ]
        let dataTypesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        ]

        self.store.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { (succes, error) in
            if !succes {
                print(error!)
                return
            }
        }
    }

    public func fetchDailyCalories(for date: Date) async -> Double? {
        let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let total = result?.sumQuantity()?.doubleValue(for: .kilocalorie())
                continuation.resume(returning: total)
            }
            store.execute(query)
        }
    }

    public func getAge() -> Int? {
        guard let dob = try? store.dateOfBirthComponents() else { return nil }
        return Calendar.current.dateComponents([.year], from: dob.date!, to: Date()).year
    }

    public func getSex() -> HKBiologicalSex? {
        return try? store.biologicalSex().biologicalSex
    }

    public func fetchLatestHeight() async -> Double? {
        let type = HKQuantityType.quantityType(forIdentifier: .height)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard
                    let sample = samples?.first as? HKQuantitySample
                else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: .meter()))
            }
            store.execute(query)
        }
    }

    public func fetchLatestWeight() async -> Double? {
        let type = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let kg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)) / 1000
                continuation.resume(returning: kg)
            }
            
            store.execute(query)
        }
    }

    public func calculateBMR(weight: Double, height: Double, age: Int, sex: HKBiologicalSex) -> Double {
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
