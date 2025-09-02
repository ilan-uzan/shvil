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
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var searchService = SearchService.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.shouldShowWelcome {
                    WelcomeView()
                } else if authManager.shouldShowOnboarding {
                    OnboardingView()
                } else if authManager.isGuest {
                    GuestModeView()
                } else {
                    ContentView()
                }
            }
            .environmentObject(locationService)
            .environmentObject(supabaseManager)
            .environmentObject(authManager)
            .environmentObject(searchService)
            .onAppear {
                // Initialize services
                locationService.requestLocationPermission()
            }
        }
    }
}
