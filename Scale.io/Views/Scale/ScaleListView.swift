//
//  ScaleListView.swift
//  Scale.io
//
//  Created by hater__ on 2025-11-01.
//

import SwiftUI
import CoreBluetooth

struct ScaleListView: View {
  @EnvironmentObject var manager: BluetoothManager
  var body : some View {
    List(manager.scales, id: \.identifier){ scale in
      Text(scale.name!)
    }
  }
}

#Preview {
  ScaleListView()
    .environmentObject(BluetoothManager.shared)
}
