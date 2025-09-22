import Foundation

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
