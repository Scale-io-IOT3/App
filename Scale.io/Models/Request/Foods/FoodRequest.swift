import Foundation

protocol FoodRequest: Request {
    var endpoint: String { get }
    var query: String { get }
    var grams: Double { get }
}

struct FreshFoodRequest: FoodRequest {
    let endpoint: String
    let query: String
    let grams: Double

    init(query: String, grams: Double) {
        endpoint = "freshfoods"
        self.query = query
        self.grams = grams
    }
}

struct ProductRequest: FoodRequest {
    let endpoint: String
    let query: String
    let grams: Double

    init(query: String, grams: Double) {
        endpoint = "barcodes"
        self.query = query
        self.grams = grams
    }
}
