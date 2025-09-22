import SwiftData
import SwiftUI

struct ContentView: View {
    @ObservedObject private var foodVm = FoodViewModel()
    var body: some View {
        VStack{
            Text("View")
        }
        .onAppear {
            Task {
                let f = await foodVm.getFreshFood(food: "banana")
                print(f)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataManager.shared.container)
}
