//
//  ContentView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// SavedPlace is defined in SupabaseService.swift as a top-level struct

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(0)

            // Search Tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)

            // Saved Places Tab
            SavedPlacesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Saved")
                }
                .tag(2)

            // Social Plans Tab
            SocialPlansView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Plans")
                }
                .tag(3)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(LiquidGlassColors.accentText)
    }
}

// MARK: - Placeholder Views (will be replaced with real implementations)

// MARK: - Liquid Glass Profile View

struct ProfileView: View {
    var body: some View {
        SettingsView()
    }
}

#Preview {
    ContentView()
}
