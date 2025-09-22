import Foundation
import SwiftData

class FoodRepository {
    private let context = DataManager.shared.container.mainContext
    
    func load(_ name: String) throws -> Food? {
        let descriptor = FetchDescriptor<Food>(
            predicate: #Predicate { $0.name == name }
        )
        return try context.fetch(descriptor).first
    }
    
    func load() throws -> [Food] {
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
