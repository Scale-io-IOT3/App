enum Measurement: String, CaseIterable {
    case grams = "g"
    case milligrams = "mg"
    case pounds = "lbs"
    case ounces = "oz"
    case kilos = "kg"

    var toGramsFactor: Double {
        switch self {
        case .grams: return 1
        case .kilos: return 1000
        case .ounces: return 28.3495
        case .pounds: return 453.592
        case .milligrams: return 0.001
        }
    }
    
    var next: Measurement {
        let all = Self.allCases
        let index = all.firstIndex(of: self)!
        let nextIndex = all.index(after: index)
        return nextIndex < all.endIndex ? all[nextIndex] : all.first!
    }

    func convert(_ value: Double, from: Measurement = .grams, to: Measurement = .grams) -> Double {
        let grams = value * from.toGramsFactor
        return grams / to.toGramsFactor
    }

}
