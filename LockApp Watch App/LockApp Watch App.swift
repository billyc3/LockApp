//
//  LockAppApp.swift
//  LockApp Watch App
//
//  Created by William Cook on 3/26/25.
//

import SwiftUI

@main
struct LockApp_Watch_AppApp: App {
    // Initialize the connectivity manager
    let connectivityManager = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
