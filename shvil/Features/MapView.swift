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
    @StateObject private var locationService = LocationService()
    @StateObject private var navigationService = NavigationService()
    @StateObject private var searchService = SearchService()
    
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var isBottomSheetExpanded = false
    @State private var selectedAnnotation: SearchResult?
    
    var body: some View {
        ZStack {
            mapView
            overlayUI
        }
        .navigationBarHidden(true)
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $locationService.region, 
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: .constant(.none),
            annotationItems: searchService.searchResults) { result in
            MapAnnotation(coordinate: result.coordinate) {
                annotationView(for: result)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            locationService.requestLocationPermission()
        }
    }
    
    private func annotationView(for result: SearchResult) -> some View {
        VStack {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(LiquidGlassColors.accentText)
                .background(
                    Circle()
                        .fill(LiquidGlassColors.glassSurface2)
                        .frame(width: 30, height: 30)
                )
            Text(result.name)
                .font(.caption)
                .foregroundColor(LiquidGlassColors.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LiquidGlassColors.glassSurface2)
                )
        }
        .onTapGesture {
            selectedAnnotation = result
            calculateRoute(to: result.coordinate)
        }
    }
    
    private var overlayUI: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            floatingButtons
            bottomSheet
        }
    }
    
    private var topBar: some View {
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
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    searchService.search(for: newValue)
                }
            }
            
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
    }
    
    private var floatingButtons: some View {
        HStack {
            floatingButton(icon: "square.stack.3d.up", label: "Layers") {
                print("Layers tapped")
            }
            
            Spacer()
            
            floatingButton(icon: "location.fill", label: "Locate") {
                locationService.centerOnUserLocation()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    private func floatingButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        VStack {
            Button(action: action) {
                Image(systemName: icon)
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
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(LiquidGlassColors.secondaryText)
        }
    }
    
    private var bottomSheet: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                bottomSheetHeader
                
                if isBottomSheetExpanded && !navigationService.routes.isEmpty {
                    bottomSheetContent
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
    
    private var bottomSheetHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let route = navigationService.currentRoute {
                    Text("\(Int(route.expectedTravelTime / 60)) min")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    Text("\(String(format: "%.1f", route.distance / 1000)) km via \(route.name)")
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                } else {
                    Text("Search for a destination")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    Text("Tap on a location to get directions")
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
            }
            
            Spacer()
            
            if navigationService.currentRoute != nil {
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
        }
    }
    
    private var bottomSheetContent: some View {
        VStack(spacing: 16) {
            routeOptions
            actionButtons
        }
    }
    
    private var routeOptions: some View {
        VStack(spacing: 16) {
            ForEach(Array(navigationService.routes.enumerated()), id: \.offset) { index, route in
                RouteCard(
                    route: RouteInfo(
                        duration: "\(Int(route.expectedTravelTime / 60)) min",
                        distance: "\(String(format: "%.1f", route.distance / 1000)) km",
                        type: route.name,
                        isFastest: index == 0,
                        isSafest: false
                    ),
                    isSelected: index == navigationService.selectedRouteIndex,
                    onTap: {
                        navigationService.selectRoute(at: index)
                    }
                )
            }
        }
    }
    
    private var actionButtons: some View {
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
                navigationService.startNavigation()
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
    
    private func calculateRoute(to destination: CLLocationCoordinate2D) {
        guard let currentLocation = locationService.currentLocation else { return }
        
        navigationService.calculateRoute(
            from: currentLocation.coordinate,
            to: destination
        ) { success in
            if success {
                isBottomSheetExpanded = true
            }
        }
    }
}
