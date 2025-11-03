internal import Combine
import CoreBluetooth
import Foundation

@MainActor
final class BluetoothViewModel: ObservableObject {
  @Published var availableScales: [CBPeripheral] = []
  @Published var connectedScale: CBPeripheral?
  @Published var characteristics: [CBCharacteristic] = []
  @Published var isBluetoothEnabled = false

  private let manager: BluetoothManager = BluetoothManager.shared
  private var cancellables = Set<AnyCancellable>()

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
