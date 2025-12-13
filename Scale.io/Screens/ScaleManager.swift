import SwiftUI

struct ScaleManager: View {
    @EnvironmentObject var vm: BluetoothViewModel
    @State var m: Measurement = .grams
    var connected: Bool { vm.connectedScale != nil }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                WeightView(m: m)
                ScaleControlsView(m: $m)
                ScaleConnectionState(connected: connected)
                    .padding(.top, 48)
            }
            .padding(.top, 48)
            .environmentObject(vm)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ScaleListView()) {
                        Image(systemName: "gearshape")
                    }
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
                Text(displayWeight(vm.weight, in: m), format: .number.precision(.fractionLength(1)))
                    .lineLimit(1)
                    .contentTransition(.numericText(value: Double(vm.weight)))
                    .monospacedDigit()

                Text(m.rawValue)
            }
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)

        }
    }

    func displayWeight(_ baseGrams: Double, in unit: Measurement) -> Double {
        return baseGrams / unit.toGramsFactor
    }

}

struct ScaleControlsView: View {
    @Binding var m: Measurement
    @EnvironmentObject var vm: BluetoothViewModel

    var body: some View {
        HStack(spacing: 12) {
            CustomButton(text: "Tare", color: .cyan) {}
                .padding()

            CustomButton(text: "Unit") {
                m = m.next
            }
            .padding()
        }
    }
}

struct ScaleConnectionState: View {
    let connected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(connected ? .green : .red)
                .frame(width: 8, height: 8)

            Text(connected ? "Connected" : "Disconnected")
                .font(.footnote)
                .foregroundColor(.secondary)

            if connected {
                Text("• Battery 100%")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 24)
    }
}

#Preview {
    ScaleManager()
        .environmentObject(BluetoothViewModel())
}
