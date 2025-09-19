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

            // Adventures Tab
            AdventuresView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Adventures")
                }
                .tag(1)

            // Hunts Tab
            HuntsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Hunts")
                }
                .tag(2)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(ShvilColors.accentPrimary)
    }
}

#Preview {
    ContentView()
}
