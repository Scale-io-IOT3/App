import Foundation

struct Food: Codable, Identifiable, Equatable {
    let id: UUID = .init()
    let name, brands: String
    let quantity: Double
    let macros: Macros
    var grade: String? = nil
    var levels: NutrientLevels? = nil
    var tags: [FoodTagKind] = []

    enum CodingKeys: String, CodingKey {
        case name, brands, quantity, macros, grade
        case levels = "nutrientLevels"
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

struct NutrientLevels: Codable, Equatable {
    let fat: String?
    let salt: String?
    let saturatedFat: String?
    let sugars: String?

    enum CodingKeys: String, CodingKey {
        case fat, salt, sugars
        case saturatedFat = "saturated-fat"
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

    func getPortion() -> String {
        return self.quantity.formatted(
            .number.precision(.fractionLength(0))
        )
    }

    func scaled(to quantityInGrams: Double) -> Food {
        let safeQuantity = max(quantityInGrams, 0)
        guard safeQuantity > 0 else { return self }

        let baseline = quantity > 0 ? quantity : 100
        let factor = safeQuantity / baseline

        let scaledMacros = Macros(
            calories: max(Int((Double(macros.calories) * factor).rounded()), 0),
            carbohydrates: max(macros.carbohydrates * factor, 0),
            fat: max(macros.fat * factor, 0),
            proteins: max(macros.proteins * factor, 0),
            percentages: macros.percentages
        )

        return Food(
            name: name,
            brands: brands,
            quantity: safeQuantity,
            macros: scaledMacros,
            grade: grade,
            levels: levels,
            tags: tags
        )
    }

    func withTags(_ tags: [FoodTagKind]) -> Food {
        var copy = self
        copy.tags = tags
        return copy
    }
}
