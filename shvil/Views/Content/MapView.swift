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
    @StateObject private var locationManager = DependencyContainer.shared.locationManager
    @StateObject private var searchService = DependencyContainer.shared.searchService
    
    var body: some View {
        ZStack {
            // Map Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            // Map
            Map {
                // Map content will be added here
            }
            .mapStyle(.standard)
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
                                    searchService.search(for: newValue)
                                } else {
                                    searchService.clearSearch()
                                }
                            }
                        }
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
                if showingSearchResults && !searchService.searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(searchService.searchResults) { result in
                                SearchResultRow(result: result) {
                                    selectSearchResult(result)
                                }
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                    }
                    .frame(maxHeight: 200)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, DesignTokens.Spacing.lg)
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

#Preview {
    MapView()
}