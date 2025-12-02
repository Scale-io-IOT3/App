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
