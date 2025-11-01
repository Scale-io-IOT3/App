import SwiftUI
import CoreBluetooth

struct ScaleManager: View {
  @StateObject var manager = BluetoothManager.shared
  var body: some View {
    List(manager.scales, id: \.identifier){scale in
      Text(scale.name ?? "Unknown")
    }
  }
}

#Preview {
  ScaleManager()
}
