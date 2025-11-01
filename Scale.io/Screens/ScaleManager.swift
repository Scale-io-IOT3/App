import SwiftUI

struct ScaleManager: View {
  var body: some View {
    VStack(spacing: 40) {

      Spacer()

      WeightView()
      ScaleControlsView()

      Spacer()

      ScaleConnectionState()

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}

struct WeightView: View {
  var body: some View {
    VStack(spacing: 8) {
      Text("Weight")
        .font(.headline)
        .foregroundColor(.secondary)

      Text("0.00 kg")
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
  var body: some View {
    VStack(spacing: 4) {
      Text("Battery: 100%")
        .font(.subheadline)
        .foregroundColor(.secondary)
      Text("Connected")
        .font(.footnote)
        .foregroundColor(.green)
    }
    .padding(.bottom, 24)
  }
}

#Preview {
  ScaleManager()
}
