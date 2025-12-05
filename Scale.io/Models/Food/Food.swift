import Foundation

struct Food: Codable, Identifiable, Equatable {
    let id: UUID = .init()
    let name, brands: String
    let calories: Int
    let quantity: Double
    let macros: Macros

    enum CodingKeys: String, CodingKey {
        case name, brands, calories, quantity, macros
    }
}

struct FoodDto: Codable {
    let quantity: Double
    let calories: Int
    let productName, brands: String
    let nutriments: Nutriments
}

struct Nutriments: Codable {
    let energyKcalValueComputed, carbohydrates: Int
    let fat, proteins: Double
}

extension Food {
    func toDto() -> FoodDto {
        FoodDto(
            quantity: self.quantity,
            calories: self.calories,
            productName: self.name,
            brands: self.brands,
            nutriments: Nutriments(
                energyKcalValueComputed: self.calories,
                carbohydrates: Int(self.macros.carbohydrates),
                fat: self.macros.fat,
                proteins: self.macros.proteins
            )
        )
    }
}
