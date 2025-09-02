//
//  ContentView.swift
//  shvil
//
//  Created by Ilan Uzan on 31/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var navigationService: NavigationService
    
    var body: some View {
        TabView {
            // Home/Map Tab
            ShvilNavigationView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            // Search Tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            // Saved Places Tab
            NavigationView {
                VStack {
                    Text("Saved Places")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Saved places functionality coming soon...")
                        .foregroundColor(.secondary)
                }
                .navigationTitle("Saved Places")
            }
            .tabItem {
                Image(systemName: "star")
                Text("Saved")
            }
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

#Preview {
    ContentView()
}
