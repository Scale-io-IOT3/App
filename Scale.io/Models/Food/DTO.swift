import Foundation

// MARK: - Food
struct FoodDto: Codable {
    let name, brands: String
    let macros: MacrosDto
}

// MARK: - Macros
struct MacrosDto: Codable {
    let calories: Int
    let carbohydrates, fat, proteins: Double
    let percentages: PercentagesDto
}

// MARK: - Percentages
struct PercentagesDto: Codable {
    let carbs, fat, proteins: Double
}

