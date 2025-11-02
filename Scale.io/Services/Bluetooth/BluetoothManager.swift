internal import Combine
import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject {
  static let shared = BluetoothManager()

  @Published private(set) var availableScales: [CBPeripheral] = []
  @Published private(set) var connectedScale: CBPeripheral?

  private let scaleUUID = CBUUID(string: Secrets.SCALE_UUID)
  private var centralManager: CBCentralManager!

  private override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  func connect(to scale: CBPeripheral) {
    centralManager.connect(scale)
  }

  func disconnect(from scale: CBPeripheral) {
    centralManager.cancelPeripheralConnection(scale)
  }
}

extension BluetoothManager: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      central.scanForPeripherals(withServices: [scaleUUID])
    } else {
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
    guard !availableScales.contains(where: { $0.identifier == peripheral.identifier }) else { return }
    availableScales.append(peripheral)
    print("Found scale:", peripheral.name ?? "Unknown")
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    connectedScale = peripheral
    peripheral.delegate = self
    central.stopScan()
    print("Connected to:", peripheral.name ?? "Unknown")
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if connectedScale?.identifier == peripheral.identifier {
      connectedScale = nil
      print("Disconnected from:", peripheral.name ?? "Unknown")
      central.scanForPeripherals(withServices: [scaleUUID])
    }
  }
}

extension BluetoothManager: CBPeripheralDelegate {}
