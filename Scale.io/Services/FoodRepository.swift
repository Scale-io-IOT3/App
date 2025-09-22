import Foundation
import SwiftData

class FoodRepository {
    private let manager = DataManager.shared
    private let context: ModelContext

    init() {
        context = manager.container.mainContext
    }

    func loadAll() throws -> [Food] {
        let descriptor = FetchDescriptor<Food>()
        return try context.fetch(descriptor)
    }

    func save(_ food: Food) throws {
        context.insert(food)
        try context.save()
    }

    func delete(_ food: Food) throws {
        context.delete(food)
        try context.save()
    }
}
