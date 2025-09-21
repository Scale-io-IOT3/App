import Foundation

protocol Mappable {
    associatedtype Model
    func toDomain() -> Model
}

extension Array where Element: Mappable {
    func toDomain() -> [Element.Model] {
        map { $0.toDomain() }
    }
}

extension FoodDto: Mappable {
    typealias Model = Food

    func toDomain() -> Food {
        Food(
            name: name,
            brands: brands,
            macros: macros.toDomain()
        )
    }
}

extension MacrosDto: Mappable {
    func toDomain() -> Macros {
        Macros(
            calories: calories,
            carbs: carbohydrates,
            fat: fat,
            proteins: proteins,
            percentages: percentages.toDomain()
        )
    }
}

extension PercentagesDto: Mappable {
    func toDomain() -> Percentages {
        Percentages(carbs: carbs, fat: fat, proteins: proteins)
    }
}
