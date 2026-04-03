import SwiftUI

struct AddFood: View {
    var key: String = ToastKey.add
    @State private var selectedMode: EntryMode = .search
    @EnvironmentObject var food: FoodViewModel
    @EnvironmentObject var bluetooth: BluetoothViewModel
    @EnvironmentObject var meals: MealsViewModel
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var toast: ToastViewModel
    @State private var foods: [Food] = []
    @State private var isLoading: Bool = false
    @State private var presentSheet: Bool = false
    @State private var startScanning: Bool = true
    @State private var searchText: String = ""
    @State private var redirect = false
    private enum EntryMode: String, CaseIterable {
        case search
        case scan
    }

    var body: some View {
        contentView
            .environmentObject(food)
            .environmentObject(bluetooth)
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                if foods.isEmpty {
                    modePickerCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
            }
            .navigationDestination(isPresented: $redirect) {
                TodayFoodsView()
            }
            .sheet(isPresented: $presentSheet, onDismiss: scannerReset) {
                FoodDetailsView(food: food.selected) {
                    guard await health.log(food.selected) else {
                        toast.show(.error("Unable to log food"), key)
                        print("Food added successfully", key)
                        return
                    }

                    await register()
                    toast.show(.success("Food added successfully"), key)
                    await meals.getTodayFoods()
                    resetState(for: selectedMode)
                }
                .resize()
            }
            .onDisappear {
                toast.clear(key)
            }
    }

    private var modePickerCard: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $selectedMode) {
                ForEach(EntryMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedMode) {
                resetState(for: selectedMode, true)
            }
        }
        .padding(10)
    }

    private func resetState(for mode: EntryMode, _ resetFoods: Bool = false) {
        startScanning = (mode == .scan)
        if resetFoods {
            foods = []
            searchText = ""
        }

        isLoading = false
    }

    private func register() async {
        if let selected = food.selected {
            await meals.create(using: selected)
        }
    }

    private func scannerReset() {
        guard selectedMode == .scan else { return }
        resetState(for: selectedMode, true)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedMode {
        case .search:
            SearchView(
                foods: $foods,
                presentSheet: $presentSheet,
                isLoading: $isLoading,
                search: $searchText,
                key: key
            ) { query in
                await food.getFreshFood(food: query, quantity: bluetooth.weight)
            }

        case .scan:
            ScannerView(
                foods: $foods,
                presentSheet: $presentSheet,
                startScanning: $startScanning,
                key: key
            ) { query in
                await food.getProduct(food: query, quantity: bluetooth.weight)
            }
            .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    NavigationStack {
        AddFood()
    }
    .environmentObject(FoodViewModel())
    .environmentObject(BluetoothViewModel())
    .environmentObject(MealsViewModel())
    .environmentObject(HealthViewModel())
    .environmentObject(ToastViewModel())
}
