import Foundation
import SwiftData

class DataManager {
    public static let shared = DataManager()
    let container: ModelContainer!

    private init() {
        let schema = Schema([Food.self])
        let config = ModelConfiguration(cloudKitDatabase: .automatic)
        container = DataManager.getContainer(configuration: config, schema: schema)

    }
    
    private static func getContainer(configuration: ModelConfiguration, schema: Schema)->ModelContainer{
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
