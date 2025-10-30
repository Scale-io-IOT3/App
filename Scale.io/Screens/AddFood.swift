import SwiftUI

struct AddFood: View {
  @State private var selectedMode: EntryMode = .search
  @ObservedObject private var foodVm = FoodViewModel()
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
      VStack {
        Picker("Mode", selection: $selectedMode) {
          ForEach(EntryMode.allCases, id: \.self) { mode in
            Text(mode.rawValue.capitalized).tag(mode)
          }
        }
        .pickerStyle(.segmented)
        .padding()
        .onChange(of: selectedMode) {
          resetState(for: selectedMode)
        }

        contentView
          .environmentObject(foodVm)
          .navigationTitle(selectedMode.rawValue.capitalized)
      }
    }
    .sheet(isPresented: $presentSheet, onDismiss: { startScanning = true }) {
      if let selected = foodVm.selected {
        FoodDetailsView(food: selected)
          .presentationDetents([.fraction(0.48)])
      }
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
        await foodVm.getFreshFood(food: query)
      }

    case .scan:
      ScannerView(
        foods: $foods,
        presentSheet: $presentSheet,
        startScanning: $startScanning
      ) { query in
        await foodVm.getProduct(food: query)
      }
    }
  }
}

#Preview {
  AddFood()
}
