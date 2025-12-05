struct MealRequest : Codable, Request{
    var endpoint: String = "meals"
    var foods: [FoodDto]
}
