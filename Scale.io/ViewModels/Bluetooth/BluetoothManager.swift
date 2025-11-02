internal import Combine
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
  @Published var enabled = true
  @Published var availableScales: [CBPeripheral] = []
  @Published var connectedScale: CBPeripheral?
  static let shared = BluetoothManager()
  private let scaleUUID = CBUUID(string: Secrets.SCALE_UUID)

  private var centralManager: CBCentralManager!

  private override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  func connect(to scale: CBPeripheral) {
    if let current = connectedScale {
      centralManager.cancelPeripheralConnection(current)
    }
    centralManager.connect(scale)
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if centralManager.state == .poweredOn {
      enabled = true
      centralManager.scanForPeripherals(withServices: [scaleUUID])
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

    if !availableScales.contains(where: { $0.identifier == peripheral.identifier }) {
      availableScales.append(peripheral)
      print("Found scale:", peripheral.name ?? "Unknown")
    }
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    connectedScale = peripheral
    centralManager.stopScan()
    print("Connected to:", peripheral.name ?? "Unknown")
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if connectedScale?.identifier == peripheral.identifier {
      connectedScale = nil
      print("Disconnected from:", peripheral.name ?? "Unknown")

      centralManager.scanForPeripherals(withServices: [scaleUUID])

    }
  }

}
