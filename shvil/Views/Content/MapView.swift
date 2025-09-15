//
//  MapView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Jerusalem
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var selectedMapLayer: MapLayer = .standard
    @State private var showingMapLayerOptions = false
    @State private var showingSearchResults = false
    @State private var showingFilters = false
    @State private var selectedFilter = "All"
    @StateObject private var locationManager = DependencyContainer.shared.locationManager
    @StateObject private var searchService = DependencyContainer.shared.searchService
    @StateObject private var analytics = Analytics.shared
    
    private let filters = ["All", "Restaurants", "Attractions", "Hotels", "Gas Stations", "Parks"]
    
    private let samplePOIs = [
        POI(id: UUID(), name: "Western Wall", coordinate: CLLocationCoordinate2D(latitude: 31.7767, longitude: 35.2345), icon: "building.columns", color: DesignTokens.Brand.primary),
        POI(id: UUID(), name: "Dome of the Rock", coordinate: CLLocationCoordinate2D(latitude: 31.7780, longitude: 35.2354), icon: "building.columns", color: DesignTokens.Brand.primary),
        POI(id: UUID(), name: "Church of the Holy Sepulchre", coordinate: CLLocationCoordinate2D(latitude: 31.7784, longitude: 35.2296), icon: "building.columns", color: DesignTokens.Brand.primary),
        POI(id: UUID(), name: "Mahane Yehuda Market", coordinate: CLLocationCoordinate2D(latitude: 31.7879, longitude: 35.2133), icon: "cart", color: DesignTokens.Semantic.success),
        POI(id: UUID(), name: "Yad Vashem", coordinate: CLLocationCoordinate2D(latitude: 31.7733, longitude: 35.1747), icon: "building.columns", color: DesignTokens.Brand.primary),
        POI(id: UUID(), name: "Israel Museum", coordinate: CLLocationCoordinate2D(latitude: 31.7719, longitude: 35.2044), icon: "building.columns", color: DesignTokens.Brand.primary)
    ]
    
    private var mapStyle: MapStyle {
        switch selectedMapLayer {
        case .standard: return .standard
        case .satellite: return .satellite
        case .hybrid: return .hybrid
        }
    }
    
    var body: some View {
        ZStack {
            // Map Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            // Map
            Map {
                // Sample POIs for demonstration
                ForEach(samplePOIs, id: \.id) { poi in
                    Annotation(poi.name, coordinate: poi.coordinate) {
                        VStack {
                            Image(systemName: poi.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(poi.color)
                                )
                                .shadow(radius: 4)
                            
                            Text(poi.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                }
            }
            .mapStyle(mapStyle)
            .ignoresSafeArea()
            
            // Top Search Bar
            VStack {
                HStack {
                    // Search Bar with standardized glass styling
                    GlassSearchBar(
                        text: $searchText,
                        placeholder: "Search places...",
                        isFocused: $isSearchFocused
                    )
                    .onTapGesture {
                        isSearchFocused = true
                        showingSearchResults = true
                    }
                    .onChange(of: searchText) { _, newValue in
                        // Debounce search for better performance
                        Task {
                            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
                            if !Task.isCancelled {
                                if !newValue.isEmpty {
                                    // Track search query
                                    analytics.logSearchQuery(newValue)
                                    searchService.search(for: newValue)
                                } else {
                                    searchService.clearSearch()
                                }
                            }
                        }
                    }
                    
                    // Filter Button
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(DesignTokens.Text.primary)
                            .font(.system(size: 16, weight: .medium))
                            .padding(DesignTokens.Spacing.sm)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Surface.primary)
                            )
                    }
                    .appleShadow(DesignTokens.Shadow.light)
                    .confirmationDialog("Filter Results", isPresented: $showingFilters) {
                        ForEach(filters, id: \.self) { filter in
                            Button(filter) {
                                selectedFilter = filter
                                // TODO: Apply filter to search results
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                    
                    // Map Layers Button
                    Button(action: {
                        showingMapLayerOptions.toggle()
                    }) {
                        Image(systemName: selectedMapLayer == .satellite ? "globe.americas.fill" : "layers.fill")
                            .foregroundColor(DesignTokens.Text.primary)
                            .font(.system(size: 16, weight: .medium))
                            .padding(DesignTokens.Spacing.sm)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Surface.primary)
                            )
                    }
                    .appleShadow(DesignTokens.Shadow.light)
                    .confirmationDialog("Map Style", isPresented: $showingMapLayerOptions) {
                        ForEach(MapLayer.allCases, id: \.self) { layer in
                            Button(layer.title) {
                                selectedMapLayer = layer
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.sm)
                
                // Search Results
                if showingSearchResults {
                    if searchService.searchResults.isEmpty && !searchText.isEmpty {
                        GlassEmptyState(
                            icon: "magnifyingglass",
                            title: "No Results",
                            description: "Try a different search term or check your spelling.",
                            actionTitle: "Clear Search",
                            action: {
                                searchText = ""
                                searchService.clearSearch()
                            }
                        )
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                    } else if !searchService.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: DesignTokens.Spacing.sm) {
                                ForEach(searchService.searchResults) { result in
                                    GlassListRow {
                                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                            Text(result.name)
                                                .font(DesignTokens.Typography.headline)
                                                .foregroundColor(DesignTokens.Text.primary)
                                            
                                            Text(result.address)
                                                .font(DesignTokens.Typography.callout)
                                                .foregroundColor(DesignTokens.Text.secondary)
                                        }
                                    } action: {
                                        selectSearchResult(result)
                                    }
                                }
                            }
                            .padding(.horizontal, DesignTokens.Spacing.lg)
                        }
                        .frame(maxHeight: 300)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg, style: .continuous)
                                .fill(DesignTokens.Surface.adaptiveGlass)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg, style: .continuous)
                                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                                        .blendMode(.overlay)
                                )
                        )
                        .shadow(
                            color: DesignTokens.Shadow.light.color,
                            radius: DesignTokens.Shadow.light.radius,
                            x: DesignTokens.Shadow.light.x,
                            y: DesignTokens.Shadow.light.y
                        )
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                    }
                }
                
                Spacer()
            }
            
            // Bottom Action Buttons
            VStack {
                Spacer()
                
                HStack {
                    // Locate Me Button
                    GlassFAB(
                        icon: locationManager.isLocationEnabled ? "location.fill" : "location.slash.fill",
                        size: .medium,
                        style: .primary,
                        action: centerOnUserLocation
                    )
                    .shvilAccessibility(
                        label: "Center on my location",
                        hint: "Centers the map on your current location",
                        traits: AccessibilityTraitsHelper.button
                    )
                    
                    Spacer()
                    
                    // Focus Mode Button
                    GlassFAB(
                        icon: "target",
                        size: .medium,
                        style: .primary,
                        action: toggleFocusMode
                    )
                    .shvilAccessibility(
                        label: "Focus mode",
                        hint: "Activates focus mode for better map navigation",
                        traits: AccessibilityTraitsHelper.button
                    )
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Layout.tabBarHeight + DesignTokens.Spacing.md)
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
    
    // MARK: - Private Methods
    
    private func centerOnUserLocation() {
        guard locationManager.isLocationEnabled,
              let currentLocation = locationManager.currentLocation else {
            // Request location permission if not authorized
            locationManager.requestLocationPermission()
            return
        }
        
        // Animate to user location
        let animation = AccessibilitySystem.prefersReducedMotion ? 
            Animation.linear(duration: 0.1) : DesignTokens.Animation.standard
        
        withAnimation(animation) {
            region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func toggleFocusMode() {
        // Implement focus mode functionality
        // This could zoom in, filter certain map features, etc.
        let animation = AccessibilitySystem.prefersReducedMotion ? 
            Animation.linear(duration: 0.1) : DesignTokens.Animation.standard
        
        withAnimation(animation) {
            region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        }
    }
    
    private func selectSearchResult(_ result: SearchResult) {
        // Track search result selection
        analytics.logEvent(AnalyticsEvent(
            name: "search_result_selected",
            properties: [
                "result_name": result.name,
                "result_address": result.address
            ],
            timestamp: Date()
        ))
        
        // Center map on selected search result
        let animation = AccessibilitySystem.prefersReducedMotion ? 
            Animation.linear(duration: 0.1) : DesignTokens.Animation.standard
        
        withAnimation(animation) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Hide search results
        showingSearchResults = false
        isSearchFocused = false
        
        // Add to recent searches
        searchService.addToRecentSearches(result)
    }
}



struct SearchResultRow: View {
    let result: SearchResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(DesignTokens.Brand.primary)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(1)
                    
                    Text(result.address)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(DesignTokens.Text.tertiary)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models

struct POI: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
    let color: Color
}

#Preview {
    MapView()
}