import Foundation
import SwiftData

@Model
class Food: CustomStringConvertible {
    var name: String
    var brands: String
    var macros: Macros

    init(name: String, brands: String, macros: Macros) {
        self.name = name
        self.brands = brands
        self.macros = macros
    }

    var description: String {
        "Food(name: \(name), brands: \(brands), macros: \(macros))"
    }
}

@Model
class Macros: CustomStringConvertible {
    var calories: Int
    var carbs: Double
    var fat: Double
    var proteins: Double
    var percentages: Percentages

    init(calories: Int, carbs: Double, fat: Double, proteins: Double, percentages: Percentages) {
        self.calories = calories
        self.carbs = carbs
        self.fat = fat
        self.proteins = proteins
        self.percentages = percentages
    }

    var description: String {
        "Macros(calories: \(calories), carbs: \(carbs), fat: \(fat), proteins: \(proteins), percentages: \(percentages))"
    }
}

@Model
class Percentages: CustomStringConvertible {
    var carbs: Double
    var fat: Double
    var proteins: Double

    init(carbs: Double, fat: Double, proteins: Double) {
        self.carbs = carbs
        self.fat = fat
        self.proteins = proteins
    }

    var description: String {
        "Percentages(carbs: \(carbs), fat: \(fat), proteins: \(proteins))"
    }
}
