import Foundation

// MARK: - Food
struct Food: Codable, Identifiable{
    var id : UUID = .init()
    let name, brands: String
    let macros: Macros
    
    enum CodingKeys: CodingKey {
        case name
        case brands
        case macros
    }
}

// MARK: - Macros
struct Macros: Codable {
    let calories: Int
    let carbohydrates, fat, proteins: Double
    let percentages: Percentages
}

// MARK: - Percentages
struct Percentages: Codable {
    let carbs, fat, proteins: Double
}

