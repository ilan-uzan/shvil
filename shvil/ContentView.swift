//
//  ContentView.swift
//  shvil
//
//  Created by Ilan Uzan on 31/08/2025.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var navigationService: NavigationService
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            // Background
            LiquidGlassDesign.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                
                // Content Area
                TabView(selection: $selectedTab) {
                    // Map Tab
                    mapTabView
                        .tag(0)
                    
                    // Search Tab
                    searchTabView
                        .tag(1)
                    
                    // Saved Places Tab
                    savedPlacesTabView
                        .tag(2)
                    
                    // Profile Tab
                    profileTabView
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Tab Bar
                bottomTabBar
            }
        }
        .onAppear {
            locationService.requestLocationPermission()
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Logo/Title
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                
                Text("Shvil")
                    .font(LiquidGlassDesign.Typography.title2)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
                
                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
        .padding(.vertical, LiquidGlassDesign.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Map Tab View
    private var mapTabView: some View {
        ZStack {
            // Map Background
            Rectangle()
                .fill(LiquidGlassDesign.Colors.backgroundSecondary)
                .overlay(
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(LiquidGlassDesign.Colors.liquidBlue.opacity(0.3))
                        Text("Map View")
                            .font(LiquidGlassDesign.Typography.title3)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    }
                )
            
            // Map Controls Overlay
        VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Location Button
                        Button(action: {}) {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(LiquidGlassDesign.Colors.liquidBlue)
                                        .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                        }
                        
                        // Search Button
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(LiquidGlassDesign.Colors.liquidBlue)
                                        .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                        }
                    }
                    .padding(.trailing, LiquidGlassDesign.Spacing.md)
                    .padding(.bottom, 100) // Above tab bar
                }
            }
        }
    }
    
    // MARK: - Search Tab View
    private var searchTabView: some View {
        ScrollView {
            VStack(spacing: LiquidGlassDesign.Spacing.md) {
                // Search Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search")
                        .font(LiquidGlassDesign.Typography.largeTitle)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    Text("Find places, addresses, and points of interest")
                        .font(LiquidGlassDesign.Typography.body)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    
                    TextField("Search for places...", text: .constant(""))
                        .font(LiquidGlassDesign.Typography.body)
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                    }
                }
                .padding(LiquidGlassDesign.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                        .fill(LiquidGlassDesign.Colors.glassWhite)
                        .shadow(color: LiquidGlassDesign.Shadows.light, radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                
                // Quick Actions
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: LiquidGlassDesign.Spacing.md) {
                    QuickActionCard(icon: "house.fill", title: "Home", subtitle: "Set your home address", color: LiquidGlassDesign.Colors.liquidBlue, action: {})
                    QuickActionCard(icon: "briefcase.fill", title: "Work", subtitle: "Set your work address", color: LiquidGlassDesign.Colors.accentGreen, action: {})
                    QuickActionCard(icon: "heart.fill", title: "Favorites", subtitle: "Your saved places", color: LiquidGlassDesign.Colors.accentRed, action: {})
                    QuickActionCard(icon: "clock.fill", title: "Recent", subtitle: "Recently searched", color: LiquidGlassDesign.Colors.accentOrange, action: {})
                }
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            }
            .padding(.top, LiquidGlassDesign.Spacing.md)
        }
    }
    
    // MARK: - Saved Places Tab View
    private var savedPlacesTabView: some View {
        ScrollView {
            VStack(spacing: LiquidGlassDesign.Spacing.md) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Saved Places")
                        .font(LiquidGlassDesign.Typography.largeTitle)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    Text("Your favorite locations")
                        .font(LiquidGlassDesign.Typography.body)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                
                // Saved Places List
                LazyVStack(spacing: LiquidGlassDesign.Spacing.sm) {
                    ForEach(0..<5) { index in
                        SavedPlaceCard(
                            place: SavedPlace(
                                id: UUID(),
                                name: "Home",
                                address: "123 Main Street, City",
                                category: "Home",
                                emoji: "🏠",
                                coordinate: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
                                distance: "2.3 mi",
                                createdAt: Date(),
                                updatedAt: Date()
                            ),
                            action: {}
                        )
                    }
                }
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            }
            .padding(.top, LiquidGlassDesign.Spacing.md)
        }
    }
    
    // MARK: - Profile Tab View
    private var profileTabView: some View {
        ScrollView {
            VStack(spacing: LiquidGlassDesign.Spacing.lg) {
                // Profile Header
                VStack(spacing: LiquidGlassDesign.Spacing.md) {
                    // Profile Picture
                    Circle()
                        .fill(LiquidGlassDesign.Colors.liquidBlue)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                        .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 4) {
                        Text("Welcome to Shvil")
                            .font(LiquidGlassDesign.Typography.title2)
                            .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        
                        Text("Your personal navigation assistant")
                            .font(LiquidGlassDesign.Typography.body)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    }
                }
                .padding(.top, LiquidGlassDesign.Spacing.lg)
                
                // Settings Sections
                VStack(spacing: LiquidGlassDesign.Spacing.md) {
                    SettingsSection(title: "Navigation") {
                        SettingsRow(icon: "car.fill", title: "Transport Mode", subtitle: "Car", color: LiquidGlassDesign.Colors.liquidBlue, action: {})
                        SettingsRow(icon: "speaker.wave.2.fill", title: "Voice Guidance", subtitle: "On", color: LiquidGlassDesign.Colors.accentGreen, action: {})
                        SettingsRow(icon: "road.lanes", title: "Route Options", subtitle: "Fastest", color: LiquidGlassDesign.Colors.accentOrange, action: {})
                    }
                    
                    SettingsSection(title: "Privacy") {
                        SettingsRow(icon: "location.fill", title: "Location Services", subtitle: "Enabled", color: LiquidGlassDesign.Colors.liquidBlue, action: {})
                        SettingsRow(icon: "eye.fill", title: "Data Collection", subtitle: "Minimal", color: LiquidGlassDesign.Colors.accentPurple, action: {})
                    }
                    
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle.fill", title: "App Version", subtitle: "1.0.0", color: LiquidGlassDesign.Colors.liquidBlue, action: {})
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: "", color: LiquidGlassDesign.Colors.accentGreen, action: {})
                    }
                }
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Bottom Tab Bar
    private var bottomTabBar: some View {
        LiquidGlassTabBar(
            selectedTab: $selectedTab,
            tabs: [
                LiquidGlassTabBar.TabItem(icon: "map.fill", title: "Map", badge: nil),
                LiquidGlassTabBar.TabItem(icon: "magnifyingglass", title: "Search", badge: nil),
                LiquidGlassTabBar.TabItem(icon: "bookmark.fill", title: "Saved", badge: nil),
                LiquidGlassTabBar.TabItem(icon: "person.fill", title: "Profile", badge: nil)
            ]
        )
    }
}

// MARK: - Supporting Components

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
            Text(title)
                .font(LiquidGlassDesign.Typography.headline)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            
            content
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationService.shared)
        .environmentObject(SupabaseManager.shared)
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(NavigationService.shared)
}
