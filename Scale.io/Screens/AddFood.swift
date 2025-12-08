import SwiftUI

struct AddFood: View {
    @State private var selectedMode: EntryMode = .search
    @EnvironmentObject var food: FoodViewModel
    @EnvironmentObject var bluetooth: BluetoothViewModel
    @EnvironmentObject var meals: MealsViewModel
    @EnvironmentObject var health: HealthViewModel
    @State private var foods: [Food] = []
    @State private var isLoading: Bool = false
    @State private var presentSheet: Bool = false
    @State private var startScanning: Bool = true
    @State private var searchText: String = ""
    @State private var goToDashboard = false
    private enum EntryMode: String, CaseIterable {
        case search
        case scan
    }

    var body: some View {
        NavigationStack {
            ZStack {
                contentView
                    .environmentObject(food)
                    .environmentObject(bluetooth)
                    .navigationTitle(selectedMode.rawValue.capitalized)

                VStack {
                    if foods.isEmpty {
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(EntryMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue.capitalized).tag(mode)
                            }
                        }
                        .glassEffect(.regular)
                        .pickerStyle(.segmented)
                        .padding()
                        .onChange(of: selectedMode) {
                            resetState(for: selectedMode)
                        }
                    }
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $goToDashboard) {
                Dashboard()
            }
        }
        .sheet(isPresented: $presentSheet, onDismiss: scannerReset) {
            FoodDetailsView(food: food.selected) {
                resetState(for: selectedMode)
                if await health.log(food: food.selected) { await register() }
            }
            .presentationDetents([.fraction(0.48)])
        }
    }

    private func resetState(for mode: EntryMode) {
        startScanning = (mode == .scan)
        foods = []
        isLoading = false
        searchText = ""
    }

    private func register() async {
        if let selected = food.selected {
            await meals.create(using: selected)
            goToDashboard = true
        }
    }

    private func scannerReset() {
        if self.selectedMode == .scan {
            resetState(for: selectedMode)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedMode {
        case .search:
            SearchView(
                foods: $foods,
                presentSheet: $presentSheet,
                isLoading: $isLoading,
                search: $searchText
            ) { query in
                await food.getFreshFood(food: query, quantity: bluetooth.weight)
            }

        case .scan:
            ScannerView(foods: $foods, presentSheet: $presentSheet, startScanning: $startScanning) { query in
                await food.getProduct(food: query, quantity: bluetooth.weight)
            }
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AddFood()
}
