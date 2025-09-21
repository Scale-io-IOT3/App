import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject private var foodVm = FoodViewModel()
    var body: some View {
        VStack{
            Text("View")
        }
        .onAppear {
            Task {
                let f = await foodVm.getFreshFood(food: "banana",quantity: 10)
                print(f[0])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataManager.shared.container)
}
