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
    
    // Accessibility support
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
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
        .safeAreaInset(edge: .bottom) {
            // Bottom content inset = 140 (84px sheet + 16px padding + 40px extra)
            Color.clear.frame(height: 140)
        }
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
        GeometryReader { geometry in
            HStack(spacing: 12) {
                // Profile Button (left, 32×32)
                Button(action: {
                    print("Profile tapped")
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(LiquidGlassColors.accentText)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Profile")
                .accessibilityHint("Open settings and social features")
                
                // Search Pill (width = screen-32, height = 52)
                SearchPill(searchText: $searchText, onTap: {
                    isSearchFocused = true
                })
                .frame(width: geometry.size.width - 32 - 32 - 12 - 12, height: 52)
                .onChange(of: searchText) { newValue in
                    if !newValue.isEmpty {
                        searchService.search(for: newValue)
                    }
                }
                
                // Mic Button (right, 28×28)
                Button(action: {
                    print("Voice search tapped")
                }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16))
                        .foregroundColor(LiquidGlassColors.accentText)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel("Voice Search")
                .accessibilityHint("Start voice search")
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(LiquidGlassColors.glassSurface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .frame(height: 52)
        .padding(.top, 12)
        .padding(.horizontal, 16)
    }
    
    private var floatingButtons: some View {
        HStack {
            VStack(spacing: 16) {
                // Adventure mini-FAB (44×44, margin 16) above Layers FAB
                Button(action: {
                    print("Adventure tapped")
                }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 18))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .frame(width: 44, height: 44)
                }
                .background(
                    Circle()
                        .fill(LiquidGlassColors.glassSurface2)
                        .overlay(
                            Circle()
                                .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .accessibilityLabel("Adventure")
                .accessibilityHint("Start an adventure")
                
                // Layers FAB (bottom-left, 56×56, margin 16)
                floatingButton(icon: "square.stack.3d.up", label: "Layers", size: 56) {
                    print("Layers tapped")
                }
            }
            
            Spacer()
            
            // Locate Me FAB (bottom-right, 56×56, margin 16)
            floatingButton(icon: "location.fill", label: "Locate", size: 56) {
                locationService.centerOnUserLocation()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private func floatingButton(icon: String, label: String, size: CGFloat = 56, action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: size == 56 ? 20 : 16))
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .frame(width: size, height: size)
            }
            .background(
                Circle()
                    .fill(LiquidGlassColors.glassSurface2)
                    .overlay(
                        Circle()
                            .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .accessibilityLabel(label)
            .accessibilityHint("Tap to \(label.lowercased())")
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(LiquidGlassColors.secondaryText)
        }
    }
    
    private var bottomSheet: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LiquidGlassColors.secondaryText.opacity(0.3))
                        .frame(width: 36, height: 4)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    VStack(spacing: 16) {
                        bottomSheetHeader
                        
                        if isBottomSheetExpanded && !navigationService.routes.isEmpty {
                            bottomSheetContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(height: isBottomSheetExpanded ? min(geometry.size.height * 0.65, 400) : 84)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LiquidGlassColors.glassSurface2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: isBottomSheetExpanded)
            }
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
