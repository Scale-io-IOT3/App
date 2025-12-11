import Foundation

struct Food: Codable, Identifiable, Equatable {
    let id: UUID = .init()
    let name, brands: String
    let quantity: Double
    let macros: Macros

    enum CodingKeys: String, CodingKey {
        case name, brands, quantity, macros
    }
}

struct FoodDto: Codable {
    let quantity: Double
    let productName, brands: String
    let nutriments: Nutriments
}

struct Nutriments: Codable {
    let energyKcalValueComputed, carbohydrates: Int
    let fat, proteins: Double
    
    enum CodingKeys: String, CodingKey {
        case energyKcalValueComputed = "energy-kcal_value_computed"
        case carbohydrates
        case fat
        case proteins
    }
}

extension Food {
    func toDto() -> FoodDto {
        FoodDto(
            quantity: self.quantity,
            productName: self.name,
            brands: self.brands,
            nutriments: Nutriments(
                energyKcalValueComputed: self.macros.calories,
                carbohydrates: Int(self.macros.carbohydrates),
                fat: self.macros.fat,
                proteins: self.macros.proteins
            )
        )
    }
}
