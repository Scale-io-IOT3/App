internal import Combine
import CoreBluetooth
import Foundation

@MainActor
class BluetoothViewModel: ObservableObject {
  @Published var availableScales: [CBPeripheral] = []
  @Published var connectedScale: CBPeripheral?
  @Published var isBluetoothEnabled = false

  private var manager: BluetoothManager

  init() {
    self.manager = BluetoothManager.shared
    bind()
  }

  private func bind() {
    manager.$availableScales
      .receive(on: DispatchQueue.main)
      .assign(to: &$availableScales)

    manager.$connectedScale
      .receive(on: DispatchQueue.main)
      .assign(to: &$connectedScale)
  }

  func connect(to scale: CBPeripheral) {
    if let current = connectedScale {
      manager.disconnect(from: current)
    }
    manager.connect(to: scale)
  }

  func disconnect() {
    guard let current = connectedScale else { return }
    manager.disconnect(from: current)
  }
}
