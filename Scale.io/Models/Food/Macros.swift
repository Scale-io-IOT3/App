import Foundation

struct Macros: Codable {
    let calories: Int
    let carbohydrates, fat, proteins: Double
    let percentages: Percentages
}

struct Percentages: Codable {
    let carbs, fat, proteins: Double
}
