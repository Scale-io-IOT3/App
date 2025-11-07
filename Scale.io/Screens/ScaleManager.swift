import SwiftUI

struct ScaleManager: View {
  @StateObject var vm: BluetoothViewModel = .init()

  var connected: Bool {
    vm.connectedScale != nil
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 48) {
        Spacer()

        Group {
          WeightView()
          ScaleControlsView()
        }
        .environmentObject(vm)

        Spacer()

        ScaleConnectionState(connected: connected)
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(
            destination: ScaleListView().environmentObject(vm),
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
  @EnvironmentObject var vm: BluetoothViewModel
  var body: some View {
    VStack(spacing: 8) {
      Text("Weight")
        .font(.headline)
        .foregroundColor(.secondary)

      HStack(spacing: 8) {
        Text(vm.weightOnScale, format: .number.precision(.fractionLength(1)))
          .contentTransition(.numericText(value: Double(vm.weightOnScale)))
          .monospacedDigit()

        Text("g")
      }
      .font(.system(size: 64, weight: .bold, design: .rounded))

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
  let connected: Bool

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
