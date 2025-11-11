internal import Combine
import CoreBluetooth
import Foundation

final class BluetoothManager: NSObject, ObservableObject {
  static let shared = BluetoothManager()

  @Published private(set) var availableScales: [CBPeripheral] = []
  @Published private(set) var connectedScale: CBPeripheral?
  @Published private(set) var characteristics: [CBCharacteristic] = []
  @Published private(set) var isBluetoothEnabled = false
  @Published private(set) var weight: Double = 0
  @Published private(set) var state: ConnectionState = .idle

  private let scaleUUID = CBUUID(string: Config.SCALE_UUID)
  private var centralManager: CBCentralManager!
  private var peripheralMap: [UUID: CBPeripheral] = [:]

  private override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: .main)
  }

  func connect(to scale: CBPeripheral) {
    scale.delegate = self
    self.state = .connecting
    centralManager.connect(scale)
  }

  func disconnect(from scale: CBPeripheral) {
    centralManager.cancelPeripheralConnection(scale)
  }
 
  func subscribe(to peripheral: CBPeripheral, at characteristic: CBCharacteristic) {
    guard characteristic.properties.contains(.notify) else {
      print("Characteristic \(characteristic.uuid) does not support notifications.")
      return
    }
    peripheral.setNotifyValue(true, for: characteristic)
  }
}

extension BluetoothManager: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn:
      isBluetoothEnabled = true
      central.scanForPeripherals(
        withServices: [scaleUUID],
        options: [
          CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
      )
    default:
      print("Bluetooth unavailable: \(central.state.rawValue)")
      isBluetoothEnabled = false
      availableScales.removeAll()
      connectedScale = nil
    }
  }

  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    guard peripheral.name != nil else { return }

    if !availableScales.contains(where: { $0.identifier == peripheral.identifier }) {
      availableScales.append(peripheral)
      peripheralMap[peripheral.identifier] = peripheral
      print("Found scale:", peripheral.name ?? "Unknown")
    }
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("Connected to:", peripheral.name ?? "Unknown")
    connectedScale = peripheral
    peripheral.delegate = self
    central.stopScan()
    peripheral.discoverServices([CBUUID(string: Config.SCALE_UUID)])
  }

  func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?
  ) {
    if connectedScale?.identifier == peripheral.identifier {
      connectedScale = nil
    }
    central.scanForPeripherals(withServices: [scaleUUID], options: nil)
    print("Disconnected from:", peripheral.name ?? "Unknown")
    self.state = .idle
  }
}

extension BluetoothManager: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let error = error {
      print("Error discovering services:", error.localizedDescription)
      return
    }
    guard let services = peripheral.services else { return }

    for service in services {
      print("Discovering characteristics for service:", service.uuid)
      peripheral.discoverCharacteristics(
        [CBUUID(string: Config.WEIGHT_CHARACTERISTIC)],
        for: service
      )
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: Error?
  ) {
    if let error = error {
      print("Error discovering characteristics:", error.localizedDescription)
      return
    }
    guard let discovered = service.characteristics else { return }

    for characteristic in discovered {
      if !characteristics.contains(where: { $0.uuid == characteristic.uuid }) {
        characteristics.append(characteristic)
      }
      if characteristic.properties.contains(.notify) {
        subscribe(to: peripheral, at: characteristic)
      }
    }

    print("Discovered characteristics for \(service.uuid): \(discovered.map { $0.uuid })")
    self.state = .connected
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    if let error = error {
      print("Error updating value for \(characteristic.uuid):", error.localizedDescription)
      return
    }

    guard let data = characteristic.value else { return }

    guard data.count >= MemoryLayout<Float>.size else {
      print("Invalid data length: \(data.count)")
      return
    }

    self.weight = Double(
      data.withUnsafeBytes { $0.load(as: Float.self) }
    )
    print("Weight (grams): \(weight)")
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    if let error = error {
      print("Error changing notification state:", error.localizedDescription)
      return
    }
  }
}
