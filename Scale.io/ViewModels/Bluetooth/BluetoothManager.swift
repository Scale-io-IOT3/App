//
//  BluetoothManager.swift
//  Scale.io
//
//  Created by hater__ on 2025-11-01.
//

internal import Combine
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
  @Published var enabled = true
  @Published var scales: [CBPeripheral] = []
  static let shared = BluetoothManager()

  private var centralManager: CBCentralManager!

  private override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if centralManager.state == .poweredOn {
      enabled = true
      centralManager.scanForPeripherals(withServices: nil)
      return
    }

    enabled = false
  }

  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    guard isScale(peripheral: peripheral) else { return }

    if !scales.contains(where: { $0.identifier == peripheral.identifier }) {
      scales.append(peripheral)
      print("Discovered scale:", peripheral.name ?? "Unknown")
    }
  }

  private func isScale(peripheral: CBPeripheral) -> Bool {
    if let name = peripheral.name {
      return name.lowercased().contains("scale")
    }

    return false

  }
}
