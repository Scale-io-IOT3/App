import Foundation
import CoreBluetooth

enum ConnectionState {
  case idle
  case connecting
  case connected
  case failed
}
