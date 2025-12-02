struct MealRequest : Request{
    var endpoint: String = "meals"
    var foods: [Food]
}
