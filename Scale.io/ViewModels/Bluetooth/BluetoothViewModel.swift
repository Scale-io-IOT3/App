internal import Combine
import CoreBluetooth
import Foundation

@MainActor
final class BluetoothViewModel: ObservableObject {
  @Published var availableScales: [CBPeripheral] = []
  @Published var connectedScale: CBPeripheral?
  @Published var characteristics: [CBCharacteristic] = []
  @Published var isBluetoothEnabled = false
  @Published var weightOnScale : Double = 0
  @Published var state: ConnectionState = .idle

  private let manager: BluetoothManager = BluetoothManager.shared
  init() { bind() }

  private func bind() {
    manager.$availableScales
      .assign(to: &$availableScales)

    manager.$connectedScale
      .assign(to: &$connectedScale)

    manager.$characteristics
      .assign(to: &$characteristics)

    manager.$isBluetoothEnabled
      .assign(to: &$isBluetoothEnabled)

    manager.$weightOnScale
      .assign(to: &$weightOnScale)

    manager.$state
      .assign(to: &$state)
  }

  func connect(to scale: CBPeripheral) {
    if let current = connectedScale {
      guard scale.identifier != current.identifier else { return }
      manager.disconnect(from: current)
    }
    manager.connect(to: scale)
  }
}
