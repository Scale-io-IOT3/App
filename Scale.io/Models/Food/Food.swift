import Foundation

struct Food: Codable, Identifiable{
    var id : UUID = .init()
    let name, brands: String
    let calories: Int
    let quantity: Double
    let macros: Macros
    
    enum CodingKeys: CodingKey {
        case name
        case brands
        case macros
        case calories
        case quantity
    }
}
