import CoreBluetooth
import Foundation

enum ConnectionState {
    case idle
    case connecting
    case connected
    case failed
}
