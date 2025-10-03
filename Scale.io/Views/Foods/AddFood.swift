import SwiftUI

struct AddFood: View {
    @State private var selectedMode: EntryMode = .search
    @StateObject private var foodVm = FoodViewModel()
    @State private var foods: [Food] = []
    @State private var search: String = ""
    @State private var isLoading: Bool = false
    @State private var presentSheet: Bool = false
    @State private var startScanning: Bool = true
    private let searchDelay: UInt64 = 700000000 // 0.7s

    enum EntryMode: String, CaseIterable {
        case search = "Search"
        case scan = "Scan"
    }

    var body: some View {
        NavigationStack {
            VStack {
                modePicker
                    .padding()

                contentView
            }
        }
        .sheet(isPresented: $presentSheet, onDismiss: {
            startScanning = true
        }) {
            Text("Test")
        }
    }

    // MARK: - Picker

    private var modePicker: some View {
        Picker("Mode", selection: $selectedMode) {
            ForEach(EntryMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch selectedMode {
        case .search:
            searchView
        case .scan:
            scanView
        }
    }

    private var searchView: some View {
        FoodListView(foods: $foods)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.regular)
                } else if foods.isEmpty && !search.isEmpty {
                    ContentUnavailableView.search(text: search)
                }
            }
            .searchable(text: $search)
            .task(id: search) { await searchTask() }
    }

    private var scanView: some View {
        ScannerRepresentable(startScanning: $startScanning, onCodeFound: { code in
            print(code)
            presentSheet = true
            startScanning = false
        })
        .navigationTitle("Scanner")
    }

    // MARK: - Search

    private func searchTask() async {
        guard !search.isEmpty else {
            isLoading = false
            foods = []
            return
        }

        try? await Task.sleep(nanoseconds: searchDelay)
        guard !Task.isCancelled else { return }

        await fetchFoods()
    }

    private func fetchFoods() async {
        isLoading = true
        defer { isLoading = false }
        foods = await foodVm.getFreshFood(food: search)
    }
}
