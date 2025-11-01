internal import Combine
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
  @Published var enabled = true
  @Published var scales: [CBPeripheral] = []
  static let shared = BluetoothManager()
  private let scaleUUID = CBUUID(string: Secrets.SCALE_UUID)

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

    guard let uuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID], uuids.contains(scaleUUID)
    else { return }

    if !scales.contains(where: { $0.identifier == peripheral.identifier }) {
      scales.append(peripheral)
      print("Found scale:", peripheral.name ?? "Scale")
    }
  }

}
