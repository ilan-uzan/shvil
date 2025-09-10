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
    @StateObject private var locationManager = DependencyContainer.shared.locationManager
    
    var body: some View {
        ZStack {
            // Map Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            // Map
            Map(coordinateRegion: $region)
                .ignoresSafeArea()
            
            // Top Search Bar
            VStack {
                HStack {
                    // Search Pill with glass effect
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignTokens.Text.secondary)
                        
                        TextField("Search places...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onTapGesture {
                                isSearchFocused = true
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(DesignTokens.Text.tertiary)
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                                    .fill(DesignTokens.Glass.medium)
                            )
                    )
                    .appleShadow(DesignTokens.Shadow.light)
                    
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
                
                Spacer()
            }
            
            // Bottom Action Buttons
            VStack {
                Spacer()
                
                HStack {
                    // Locate Me Button
                    Button(action: {
                        centerOnUserLocation()
                    }) {
                        Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .padding(DesignTokens.Spacing.md)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Brand.gradient)
                            )
                    }
                    .appleShadow(DesignTokens.Shadow.medium)
                    .accessibilityLabel("Center on my location")
                    .accessibilityHint("Centers the map on your current location")
                    
                    Spacer()
                    
                    // Focus Mode Button
                    Button(action: {
                        toggleFocusMode()
                    }) {
                        Image(systemName: "target")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .padding(DesignTokens.Spacing.md)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Brand.gradient)
                            )
                    }
                    .appleShadow(DesignTokens.Shadow.medium)
                    .accessibilityLabel("Focus mode")
                    .accessibilityHint("Activates focus mode for better map navigation")
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
        withAnimation(DesignTokens.Animation.standard) {
            region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func toggleFocusMode() {
        // Implement focus mode functionality
        // This could zoom in, filter certain map features, etc.
        withAnimation(DesignTokens.Animation.standard) {
            region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        }
    }
}



#Preview {
    MapView()
}