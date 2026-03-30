import CoreBluetooth
import SwiftUI

struct ScaleListView: View {
    @EnvironmentObject var vm: BluetoothViewModel

    @ViewBuilder private var view: some View {
        if !vm.availableScales.isEmpty {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(vm.availableScales, id: \.identifier) { scale in
                        ScaleRow(scale: scale)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        } else {
            ContentUnavailableView(
                "No scale nearby",
                systemImage: "antenna.radiowaves.left.and.right.slash",
                description: Text("Turn your scale on and tap refresh in a few seconds.")
            )
        }
    }

    var body: some View {
        ZStack {
            view
                .environmentObject(vm)
            if vm.state == .connecting {
                Progress()
            }
        }
        .navigationTitle("Available Scales")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScaleListView()
        .environmentObject(BluetoothViewModel())
}

private struct ScaleRow: View {
    @EnvironmentObject var vm: BluetoothViewModel
    let scale: CBPeripheral

    private var isConnectedScale: Bool {
        vm.connectedScale?.identifier == scale.identifier
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scale.name ?? "Unknown Scale")
                    .font(.subheadline.bold())
                Text(scale.identifier.uuidString.prefix(8))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(.accent))
                .opacity(scale.identifier == vm.connectedScale?.identifier ? 1 : 0)
                .scaleEffect(scale.identifier == vm.connectedScale?.identifier ? 1 : 0.5)
                .animation(.spring(), value: vm.connectedScale)
        }
        .appCard(cornerRadius: 14, padding: 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isConnectedScale {
                vm.connect(to: scale)
            }
        }
        .swipeActions(edge: .trailing) {
            Button {
                vm.connect(to: scale)
            } label: {
                Image(systemName: "personalhotspot")
            }
            .tint(isConnectedScale ? .gray : .accent)
            .disabled(isConnectedScale)
        }
    }
}

private struct Progress: View {
    @EnvironmentObject var vm: BluetoothViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .allowsHitTesting(true)

            VStack(spacing: 10) {
                ProgressView()
                    .controlSize(.large)
                Text("Connecting...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .appCard(cornerRadius: 12, padding: 18)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: vm.state)
    }
}
