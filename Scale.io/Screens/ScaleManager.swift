import SwiftUI

struct ScaleManager: View {
    @EnvironmentObject var vm: BluetoothViewModel
    @State var m: Measurement = .grams
    var connected: Bool { vm.connectedScale != nil }

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 16) {
                WeightView(m: m)
                ScaleControlsView(measurement: $m)
                ScaleConnectionState(connected: connected)
                    .frame(maxWidth: .infinity)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .environmentObject(vm)
        .navigationTitle("Scale")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: ScaleListView()) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.headline)
                }
            }
        }
    }
}

struct WeightView: View {
    @EnvironmentObject var vm: BluetoothViewModel
    var m: Measurement

    var body: some View {
        VStack(spacing: 12) {
            Text("Current Weight")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(displayWeight(vm.weight, in: m), format: .number.precision(.fractionLength(1)))
                    .lineLimit(1)
                    .contentTransition(.numericText(value: Double(vm.weight)))
                    .monospacedDigit()

                Text(m.rawValue)
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 54, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)

            Text("Place food on the scale to update weight.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .appCard(cornerRadius: 18, padding: 18)
    }

    func displayWeight(_ baseGrams: Double, in unit: Measurement) -> Double {
        return baseGrams / unit.toGramsFactor
    }
}

struct ScaleControlsView: View {
    @Binding var measurement: Measurement

    var body: some View {
        HStack(spacing: 12) {
            CustomButton("Tare", color: .cyan, icon: "arrow.clockwise") {}
            CustomButton("Unit", icon: "scalemass.fill") {
                step()
            }
        }
    }

    func step() {
        measurement = measurement.next
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

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ScaleManager()
        .environmentObject(BluetoothViewModel())
}
