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