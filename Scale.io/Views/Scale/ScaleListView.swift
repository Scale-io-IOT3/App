//
//  ScaleListView.swift
//  Scale.io
//
//  Created by hater__ on 2025-11-01.
//

import CoreBluetooth
import SwiftUI

struct ScaleListView: View {
  @EnvironmentObject var manager: BluetoothManager
  @ViewBuilder private var view: some View {
    if !manager.availableScales.isEmpty {
      List(manager.availableScales, id: \.identifier) { scale in
        ScaleRow(scale: scale)
      }
    } else {
      ContentUnavailableView("No scale around", systemImage: "antenna.radiowaves.left.and.right.slash")
    }
  }
  var body: some View {
    view
      .environmentObject(manager)
  }
}

#Preview {
  ScaleListView()
    .environmentObject(BluetoothManager.shared)
}

private struct ScaleRow: View {
  @EnvironmentObject var manager: BluetoothManager
  let scale: CBPeripheral
  var body: some View {
    Text(scale.name!)
      .swipeActions(edge: .trailing) {
        Button(role: .confirm) {
          manager.connect(to: scale)
        } label: {
          Label("Connect", systemImage: "link")
        }
        .tint(.accent)
      }

  }
}
