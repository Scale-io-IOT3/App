import Foundation
internal import HealthKit

class HKUtils {
    private let store = HKHealthStore()

    init() { requestAuth() }

    private func requestAuth() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        var dataTypesToRead = Set<HKObjectType>()
        var dataTypesToWrite = Set<HKSampleType>()

        if let dob = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) {
            dataTypesToRead.insert(dob)
        }
        if let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) {
            dataTypesToRead.insert(sex)
        }
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            dataTypesToRead.insert(bodyMass)
        }
        if let height = HKObjectType.quantityType(forIdentifier: .height) {
            dataTypesToRead.insert(height)
        }
        
        if let carbs = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates) {
            dataTypesToRead.insert(carbs)
            dataTypesToWrite.insert(carbs)
        }
        if let satFat = HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated) {
            dataTypesToRead.insert(satFat)
            dataTypesToWrite.insert(satFat)
        }
        if let protein = HKObjectType.quantityType(forIdentifier: .dietaryProtein) {
            dataTypesToRead.insert(protein)
            dataTypesToWrite.insert(protein)
        }
        if let energy = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) {
            dataTypesToRead.insert(energy)
            dataTypesToWrite.insert(energy)
        }

        store.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error.localizedDescription)")
                return
            }
            print("HealthKit authorization \(success ? "granted" : "not granted")")
        }
    }

    public func fetchDailyCalories(for date: Date) async -> Double? {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            return nil
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)

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
        guard let dob = try? store.dateOfBirthComponents(), let date = dob.date else { return nil }
        return Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }

    public func getSex() -> HKBiologicalSex? {
        return try? store.biologicalSex().biologicalSex
    }

    public func fetchLatestHeight() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .height) else { return nil }
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
                continuation.resume(returning: sample.quantity.doubleValue(for: .meter()))
            }
            store.execute(query)
        }
    }

    public func fetchLatestWeight() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return nil }
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
                let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: kg)
            }
            store.execute(query)
        }
    }
}
