import Foundation

struct FreshFoodRequest: APIRequest {
    let endpoint: String
    let query: String
    let grams: Double

    init(query: String, grams: Double) {
        self.endpoint = "foods"
        self.query = query
        self.grams = grams
    }
}

struct ProductRequest: APIRequest {
    let endpoint: String
    let query: String
    let grams: Double

    init(query: String, grams: Double) {
        self.endpoint = "barcodes"
        self.query = query
        self.grams = grams
    }
}
