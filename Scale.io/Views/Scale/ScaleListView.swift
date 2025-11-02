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
  var body: some View {
    view
  }

  @ViewBuilder
  private var view: some View {
    if !manager.availableScales.isEmpty {
      List(manager.availableScales, id: \.identifier) { scale in
        Text(scale.name!)
      }
    } else {
      ContentUnavailableView("No scale around", systemImage: "antenna.radiowaves.left.and.right.slash")
      }
  }

}

#Preview {
  ScaleListView()
    .environmentObject(BluetoothManager.shared)
}
