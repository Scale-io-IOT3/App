import SwiftUI

struct AddFood: View {
  @State private var selectedMode: EntryMode = .search
  @ObservedObject private var foodVm = FoodViewModel()
  @EnvironmentObject var bluetooth: BluetoothViewModel
  @State private var foods: [Food] = []
  @State private var isLoading: Bool = false
  @State private var presentSheet: Bool = false
  @State private var startScanning: Bool = true
  @State private var searchText: String = ""
  private enum EntryMode: String, CaseIterable {
    case search
    case scan
  }

  var body: some View {
    NavigationStack {
      ZStack {
        contentView
          .environmentObject(foodVm)
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
            .padding(.vertical)
            .padding(.horizontal, 52)
            .onChange(of: selectedMode) {
              resetState(for: selectedMode)
            }
          }
          Spacer()
        }
      }
    }
    .sheet(
      isPresented: $presentSheet,
    ) {
      FoodDetailsView(food: foodVm.selected){
        resetState(for: selectedMode)
      }
        .presentationDetents([.fraction(0.48)])
    }
  }

  private func resetState(for mode: EntryMode) {
    foods = []
    isLoading = false
    searchText = ""
    startScanning = (mode == .scan)
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
        await foodVm.getFreshFood(food: query, quantity: bluetooth.weight)
      }

    case .scan:
      ScannerView(foods: $foods, presentSheet: $presentSheet, startScanning: $startScanning) {
        query in
        await foodVm.getProduct(food: query, quantity: bluetooth.weight)
      }
      .environment(\.colorScheme, .dark)
      .ignoresSafeArea()
    }
  }
}

#Preview {
  AddFood()
}
