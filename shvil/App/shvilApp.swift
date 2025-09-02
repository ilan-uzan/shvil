//
//  shvilApp.swift
//  shvil
//
//  Created by Ilan Uzan on 31/08/2025.
//

import SwiftUI

@main
struct ShvilApp: App {
    @StateObject private var locationService = LocationService.shared
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationService)
                .environmentObject(supabaseManager)
                .onAppear {
                    // Initialize services
                    locationService.requestLocationPermission()
                }
        }
    }
}
