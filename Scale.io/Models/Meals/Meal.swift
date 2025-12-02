import Foundation

struct Meal: Codable {
    let createdAt: String
    let foods: [Food]
}
