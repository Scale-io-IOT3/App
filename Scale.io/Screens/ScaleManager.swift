import SwiftUI

struct ScaleManager: View {
  @StateObject var manager = BluetoothManager.shared
  @State var connected = false
  var body: some View {
    NavigationStack {
      VStack(spacing: 48) {

        Spacer()

        WeightView()
        ScaleControlsView()

        Spacer()

        ScaleConnectionState(connected: connected)
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(
            destination: ScaleListView().environmentObject(manager),
            label: {
              Label("Manage your scale", systemImage: "gearshape")
            }
          )
        }

      }
    }
  }
}

struct WeightView: View {
  var body: some View {
    VStack(spacing: 8) {
      Text("Weight")
        .font(.headline)
        .foregroundColor(.secondary)

      Text("0 g")
        .font(.system(size: 64, weight: .bold, design: .rounded))
        .foregroundColor(.primary)
    }
  }
}

struct ScaleControlsView: View {
  var body: some View {
    HStack(spacing: 48) {
      Button("Unit") {}
        .buttonStyle(.borderedProminent)

      Button("Tare") {}
        .buttonStyle(.bordered)
    }
  }
}

struct ScaleConnectionState: View {
  @State var connected: Bool
  var body: some View {
    VStack(spacing: 4) {
      Text("Battery: 100%")
        .font(.subheadline)
        .foregroundColor(.secondary)
      Text(connected ? "Connected" : "Disconnected")
        .font(.footnote)
        .foregroundColor(connected ? .green : .red)
    }
    .padding(.bottom, 24)
  }
}

#Preview {
  ScaleManager()
}
