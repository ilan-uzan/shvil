//
//  shvilApp.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

@main
struct shvilApp: App {
    // MARK: - App State
    
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.accessibilityManager)
                .environmentObject(appState.performanceOptimizer)
                .environmentObject(appState.cacheManager)
                .dynamicTypeSupport()
                .rtlSupport()
                .accessibleAnimation()
        }
    }
}
