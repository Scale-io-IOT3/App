import Foundation

struct Macros: Codable, Equatable {
    let calories: Int
    let carbohydrates, fat, proteins: Double
    let percentages: Percentages
}

struct Percentages: Codable, Equatable {
    let carbs, fat, proteins: Double
}
