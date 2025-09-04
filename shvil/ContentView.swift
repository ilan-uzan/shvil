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
                    
                    // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                        .tag(3)
        }
        .accentColor(LiquidGlassColors.accentText)
    }
}

// MARK: - Placeholder Views (will be replaced with real implementations)

// MARK: - Liquid Glass Search View
struct SearchView: View {
    @State private var searchText = ""
    @State private var recentSearches = ["Coffee Shop", "Gas Station", "Restaurant"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    SearchPill(searchText: $searchText) {
                        // Search focused
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    if !searchText.isEmpty {
                        // Search Results
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(0..<5) { index in
                                    SearchResultRow(
                                        title: "Search result \(index + 1)",
                                        subtitle: "123 Main St, City, State",
                                        distance: "0.\(index + 1) miles away"
                                    ) {
                                        print("Result \(index + 1) selected")
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // Recent Searches
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent Searches")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(LiquidGlassColors.primaryText)
                                
                                Spacer()
                                
                                Button("Clear") {
                                    recentSearches.removeAll()
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(LiquidGlassColors.accentText)
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(recentSearches, id: \.self) { search in
                                    RecentSearchRow(search: search) {
                                        searchText = search
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let title: String
    let subtitle: String
    let distance: String
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(LiquidGlassColors.accentText)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
                Text(distance)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(16)
            .glassEffect(elevation: .light)
            .cornerRadius(12)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Recent Search Row
struct RecentSearchRow: View {
    let search: String
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.system(size: 16))
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text(search)
                    .font(.system(size: 16))
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 14))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(LiquidGlassColors.glassSurface1)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Saved Places View (moved to separate file)

// MARK: - Liquid Glass Profile View
struct ProfileView: View {
    var body: some View {
        NavigationView {
        ScrollView {
                VStack(spacing: 32) {
                // Profile Header
                    VStack(spacing: 20) {
                    // Profile Picture
                        ZStack {
                    Circle()
                                .fill(LiquidGlassGradients.primaryGradient)
                                .frame(width: 120, height: 120)
                                .glassEffect(elevation: .high)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Welcome to Shvil")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(LiquidGlassColors.primaryText)
                        
                        Text("Your personal navigation assistant")
                                .font(.system(size: 16))
                                .foregroundColor(LiquidGlassColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Settings Section
                    VStack(spacing: 16) {
                        SettingsRow(
                            icon: "gear",
                            title: "Settings",
                            subtitle: "App preferences and configuration"
                        ) {
                            print("Settings tapped")
                        }
                        
                        SettingsRow(
                            icon: "location.fill",
                            title: "Location Services",
                            subtitle: "Manage location permissions"
                        ) {
                            print("Location services tapped")
                        }
                        
                        SettingsRow(
                            icon: "person.2.fill",
                            title: "Social Features",
                            subtitle: "ETA sharing and friends on map"
                        ) {
                            print("Social features tapped")
                        }
                        
                        SettingsRow(
                            icon: "shield.fill",
                            title: "Privacy & Security",
                            subtitle: "Control your data and privacy"
                        ) {
                            print("Privacy tapped")
                        }
                        
                        SettingsRow(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            subtitle: "Get help and contact support"
                        ) {
                            print("Help tapped")
                        }
                        
                        SettingsRow(
                            icon: "info.circle",
                            title: "About Shvil",
                            subtitle: "Version 1.0.0"
                        ) {
                            print("About tapped")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // App Info
                    VStack(spacing: 12) {
                        Text("Shvil Minimal")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LiquidGlassColors.primaryText)
                        
                        Text("Version 1.0.0 • Build 1")
                            .font(.system(size: 14))
                            .foregroundColor(LiquidGlassColors.secondaryText)
                        
                        Text("Built with ❤️ for iOS")
                            .font(.system(size: 12))
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
        }
    }
}


#Preview {
    ContentView()
}