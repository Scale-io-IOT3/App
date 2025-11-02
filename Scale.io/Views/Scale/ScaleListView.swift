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
    view
      .environmentObject(vm)
  }
}

#Preview {
  ScaleListView()
    .environmentObject(BluetoothViewModel())
}

private struct ScaleRow: View {
  @EnvironmentObject var vm: BluetoothViewModel
  let scale: CBPeripheral
  var body: some View {
    Text(scale.name!)
      .swipeActions(edge: .trailing) {
        Button(role: .confirm) {
          vm.connect(to: scale)
        } label: {
          Image(systemName: "link")
        }
        .tint(.accent)
      }

  }
}
