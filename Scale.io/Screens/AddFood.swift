import SwiftUI

struct AddFood: View {
    var key: String = ToastKey.add
    @State private var selectedMode: EntryMode = .search
    @EnvironmentObject var food: FoodViewModel
    @EnvironmentObject var meals: MealsViewModel
    @EnvironmentObject var health: HealthViewModel
    @EnvironmentObject var toast: ToastViewModel
    @State private var foods: [Food] = []
    @State private var isLoading: Bool = false
    @State private var presentSheet: Bool = false
    @State private var startScanning: Bool = true
    @State private var searchText: String = ""
    private let defaultServing: Double = 100

    private enum EntryMode: String, CaseIterable {
        case search
        case scan
    }

    var body: some View {
        contentView
            .environmentObject(food)
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                if foods.isEmpty {
                    modePickerHeader
                }
            }
            .sheet(isPresented: $presentSheet, onDismiss: scannerReset) {
                FoodDetailsView(food: food.selected) { selectedFood in
                    guard await health.log(selectedFood) else {
                        toast.show(.error("Unable to log food"), key)
                        return
                    }

                    await meals.create(using: selectedFood)
                    toast.show(.success("Food added successfully"), key)
                    await meals.getTodayFoods()
                    resetState(for: selectedMode)
                }
                .resizeWithAction()
            }
            .onDisappear {
                toast.clear(key)
            }
    }

    private var modePickerHeader: some View {
        Picker("Mode", selection: $selectedMode) {
            ForEach(EntryMode.allCases, id: \.self) { mode in
                Text(mode.rawValue.capitalized).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
        .onChange(of: selectedMode) {
            resetState(for: selectedMode, true)
        }
    }

    private func resetState(for mode: EntryMode, _ resetFoods: Bool = false) {
        startScanning = (mode == .scan)
        if resetFoods {
            foods = []
            searchText = ""
        }

        isLoading = false
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
                await food.getFreshFood(food: query, quantity: defaultServing)
            }

        case .scan:
            ScannerView(
                foods: $foods,
                presentSheet: $presentSheet,
                startScanning: $startScanning,
                key: key
            ) { query in
                await food.getProduct(food: query, quantity: defaultServing)
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
    .environmentObject(MealsViewModel())
    .environmentObject(HealthViewModel())
    .environmentObject(ToastViewModel())
}
