internal import Combine
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
  @Published var enabled = true
  @Published var availableScales: [CBPeripheral] = []
  @Published var scale: CBPeripheral?
  static let shared = BluetoothManager()
  private let scaleUUID = CBUUID(string: Secrets.SCALE_UUID)

  private var centralManager: CBCentralManager!

  private override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  func connect(scale: CBPeripheral) {
    centralManager.connect(scale)
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

    guard let UUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
      UUIDs.contains(scaleUUID)
    else { return }

    if !availableScales.contains(where: { $0.identifier == peripheral.identifier }) {
      availableScales.append(peripheral)
      print("Found scale:", peripheral.name!)
    }
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    self.scale = peripheral
  }

  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    // Handle error
  }

}
