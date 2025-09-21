//
//  Scale_ioApp.swift
//  Scale.io
//
//  Created by hater__ on 2025-09-21.
//

import SwiftUI
import SwiftData

@main
struct Scale_ioApp: App {
    let manager = DataManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(manager.container)
    }
}
