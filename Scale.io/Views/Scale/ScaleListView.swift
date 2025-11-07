import CoreBluetooth
import SwiftUI

struct ScaleListView: View {
  @EnvironmentObject var vm: BluetoothViewModel
  @ViewBuilder private var view: some View {
    if !vm.availableScales.isEmpty {
      List(vm.availableScales, id: \.identifier) { scale in
        ScaleRow(scale: scale)
      }
    } else {
      ContentUnavailableView("No scale around", systemImage: "antenna.radiowaves.left.and.right.slash")
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
      Text(scale.name ?? "Unknown")
      Spacer()
      Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(Color(.accent))
        .opacity(scale.identifier == vm.connectedScale?.identifier ? 1 : 0)
        .scaleEffect(scale.identifier == vm.connectedScale?.identifier ? 1 : 0.5)
        .animation(.spring(), value: vm.connectedScale)
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
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .allowsHitTesting(true)

      ProgressView()
        .controlSize(.large)
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    .transition(.opacity)
    .animation(.easeInOut, value: vm.state)
  }
}
