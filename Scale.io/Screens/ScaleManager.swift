import SwiftUI

struct ScaleManager: View {
    @EnvironmentObject var vm: BluetoothViewModel
    @State var m: Measurement = .grams
    var connected: Bool { vm.connectedScale != nil }

    var body: some View {
        NavigationStack {
            VStack(spacing: 48) {
                Spacer()

                Group {
                    WeightView(m: m)
                    ScaleControlsView(m: $m)
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
    var m: Measurement
    var body: some View {
        VStack(spacing: 8) {
            Text("Weight")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Text(vm.weight, format: .number.precision(.fractionLength(1)))
                    .contentTransition(.numericText(value: Double(vm.weight)))
                    .monospacedDigit()

                Text(m.rawValue)
            }
            .font(.system(size: 64, weight: .bold, design: .rounded))

        }
    }
}

struct ScaleControlsView: View {
    @Binding var m: Measurement
    @EnvironmentObject var vm: BluetoothViewModel

    var body: some View {
        HStack(spacing: 12) {
            CustomButton(text: "Tare") {}
                .padding()

            CustomButton(text: "Unit", color: .cyan) {
                convert()
            }
            .padding()
        }
    }

    private func convert() {
        vm.weight = m.convert(vm.weight, from: m, to: m.next)
        m = m.next
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
