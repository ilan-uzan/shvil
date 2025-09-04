//
//  ContentView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

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

// MARK: - Liquid Glass Map View
struct MapView: View {
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var isBottomSheetExpanded = false
    
    var body: some View {
        ZStack {
            // Map Background (placeholder)
            LinearGradient(
                gradient: Gradient(colors: [
                    LiquidGlassColors.glassSurface1,
                    LiquidGlassColors.glassSurface2
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    // Profile Button
                    Button(action: {
                        print("Profile tapped")
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(LiquidGlassColors.accentText)
                    }
                    
                    Spacer()
                    
                    // Search Pill
                    SearchPill(searchText: $searchText, onTap: {
                        isSearchFocused = true
                    })
                    .frame(maxWidth: 280)
                    
                    Spacer()
                    
                    // Mic Button
                    Button(action: {
                        print("Voice search tapped")
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(LiquidGlassColors.accentText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Floating Buttons
                HStack {
                    // Layers Button
                    VStack {
                        Button(action: {
                            print("Layers tapped")
                        }) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.system(size: 20))
                                .foregroundColor(LiquidGlassColors.primaryText)
                        }
                        .padding(12)
                        .background(
                            Circle()
                                .fill(LiquidGlassColors.glassSurface2)
                                .overlay(
                                    Circle()
                                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                                )
                        )
                        
                        Text("Layers")
                            .font(.system(size: 10))
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Locate Me Button
                    VStack {
                        Button(action: {
                            print("Locate me tapped")
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(LiquidGlassColors.primaryText)
                        }
                        .padding(12)
                        .background(
                            Circle()
                                .fill(LiquidGlassColors.glassSurface2)
                                .overlay(
                                    Circle()
                                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                                )
                        )
                        
                        Text("Locate")
                            .font(.system(size: 10))
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            
            // Bottom Sheet (Simplified)
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("12 min")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(LiquidGlassColors.primaryText)
                            
                            Text("2.3 miles via Main St")
                                .font(.system(size: 14))
                                .foregroundColor(LiquidGlassColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isBottomSheetExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isBottomSheetExpanded ? "chevron.down" : "chevron.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(LiquidGlassColors.secondaryText)
                        }
                    }
                    
                    if isBottomSheetExpanded {
                        VStack(spacing: 16) {
                            // Route Options
                            RouteCard(
                                route: RouteCard.RouteInfo(
                                    duration: "12 min",
                                    distance: "2.3 miles",
                                    type: "Drive",
                                    isFastest: true,
                                    isSafest: false
                                ),
                                isSelected: true,
                                onTap: {
                                    print("Fastest route selected")
                                }
                            )
                            
                            RouteCard(
                                route: RouteCard.RouteInfo(
                                    duration: "15 min",
                                    distance: "2.1 miles",
                                    type: "Drive",
                                    isFastest: false,
                                    isSafest: true
                                ),
                                isSelected: false,
                                onTap: {
                                    print("Safest route selected")
                                }
                            )
                            
                            // Action Buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    print("Share ETA tapped")
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share ETA")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(LiquidGlassColors.accentText)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(LiquidGlassColors.accentText.opacity(0.1))
                                .cornerRadius(25)
                                
                                Button(action: {
                                    print("Start navigation tapped")
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("Start")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(LiquidGlassGradients.primaryGradient)
                                .cornerRadius(25)
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LiquidGlassColors.glassSurface2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

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

// MARK: - Liquid Glass Saved Places View
struct SavedPlacesView: View {
    @State private var savedPlaces = [
        SavedPlace(name: "Home", address: "123 Main St", type: .home),
        SavedPlace(name: "Work", address: "456 Business Ave", type: .work),
        SavedPlace(name: "Coffee Shop", address: "789 Coffee St", type: .favorite)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if savedPlaces.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(LiquidGlassColors.accentText.opacity(0.6))
                        
                        VStack(spacing: 12) {
                            Text("No saved places yet")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(LiquidGlassColors.primaryText)
                            
                            Text("Tap the heart icon to save places you love")
                                .font(.system(size: 16))
                                .foregroundColor(LiquidGlassColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            print("Add first place tapped")
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Your First Place")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(LiquidGlassGradients.primaryGradient)
                            .cornerRadius(25)
                        }
                    }
                    .padding(40)
                } else {
                    // Saved Places List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(savedPlaces) { place in
                                SavedPlaceRow(place: place) {
                                    print("Place \(place.name) selected")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
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

// MARK: - Saved Place Model
struct SavedPlace: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let type: PlaceType
    
    enum PlaceType {
        case home
        case work
        case favorite
        case custom
    }
}

// MARK: - Saved Place Row
struct SavedPlaceRow: View {
    let place: SavedPlace
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Place Icon
                Image(systemName: placeIcon)
                    .font(.system(size: 24))
                    .foregroundColor(placeColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(place.address)
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Text(placeTypeText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(placeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(placeColor.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(20)
            .glassEffect(elevation: .medium)
            .cornerRadius(16)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var placeIcon: String {
        switch place.type {
        case .home: return "house.fill"
        case .work: return "building.2.fill"
        case .favorite: return "heart.fill"
        case .custom: return "location.fill"
        }
    }
    
    private var placeColor: Color {
        switch place.type {
        case .home: return LiquidGlassColors.accentText
        case .work: return LiquidGlassColors.deepAqua
        case .favorite: return Color.pink
        case .custom: return LiquidGlassColors.secondaryText
        }
    }
    
    private var placeTypeText: String {
        switch place.type {
        case .home: return "HOME"
        case .work: return "WORK"
        case .favorite: return "FAV"
        case .custom: return "CUSTOM"
        }
    }
}

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