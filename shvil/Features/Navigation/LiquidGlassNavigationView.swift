//
//  LiquidGlassNavigationView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct LiquidGlassNavigationView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var navigationService: NavigationService
    @State private var selectedTab: Int = 0
    @State private var showSearch = false
    @State private var showRouteOptions = false
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            // Background
            LiquidGlassDesign.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            // Main Content
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                
                // Content Area
                TabView(selection: $selectedTab) {
                    // Map Tab
                    LiquidGlassMapView()
                        .tag(0)
                    
                    // Search Tab
                    LiquidGlassSearchView()
                        .tag(1)
                    
                    // Saved Places Tab
                    LiquidGlassSavedPlacesView()
                        .tag(2)
                    
                    // Profile Tab
                    LiquidGlassProfileView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Tab Bar
                LiquidGlassTabBar(
                    selectedTab: $selectedTab,
                    tabs: [
                        LiquidGlassTabBar.TabItem(icon: "map.fill", title: "Map", badge: nil),
                        LiquidGlassTabBar.TabItem(icon: "magnifyingglass", title: "Search", badge: nil),
                        LiquidGlassTabBar.TabItem(icon: "bookmark.fill", title: "Saved", badge: nil),
                        LiquidGlassTabBar.TabItem(icon: "person.fill", title: "Profile", badge: nil)
                    ]
                )
                .padding(.bottom, 8)
            }
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingActionButtons
                }
                .padding(.trailing, LiquidGlassDesign.Spacing.md)
                .padding(.bottom, 100) // Above tab bar
            }
            
            // Navigation Overlay
            if isNavigating {
                LiquidGlassNavigationOverlay()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(LiquidGlassDesign.Animation.fluid, value: isNavigating)
        .animation(LiquidGlassDesign.Animation.smooth, value: selectedTab)
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Location Status
            HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Circle()
                    .fill(locationService.isLocationEnabled ? LiquidGlassDesign.Colors.accentGreen : LiquidGlassDesign.Colors.accentRed)
                    .frame(width: 8, height: 8)
                    .liquidGlassGlow(
                        color: locationService.isLocationEnabled ? LiquidGlassDesign.Colors.accentGreen : LiquidGlassDesign.Colors.accentRed,
                        radius: 4
                    )
                
                Text(locationService.isLocationEnabled ? "Location Active" : "Location Disabled")
                    .font(LiquidGlassDesign.Typography.caption)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Button(action: { showSearch.toggle() }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(LiquidGlassDesign.Colors.glassWhite)
                                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                        )
                }
                
                Button(action: { showRouteOptions.toggle() }) {
                    Image(systemName: "route")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(LiquidGlassDesign.Colors.glassWhite)
                                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
        .padding(.vertical, LiquidGlassDesign.Spacing.sm)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        )
    }
    
    // MARK: - Floating Action Buttons
    private var floatingActionButtons: some View {
        VStack(spacing: LiquidGlassDesign.Spacing.sm) {
            // My Location Button
            Button(action: { locationService.requestLocationPermission() }) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(LiquidGlassDesign.Colors.liquidBlue)
                            .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
            }
            .liquidGlassGlow(color: LiquidGlassDesign.Colors.liquidBlue, radius: 16)
            
            // Navigation Toggle
            Button(action: { isNavigating.toggle() }) {
                Image(systemName: isNavigating ? "stop.fill" : "play.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(isNavigating ? LiquidGlassDesign.Colors.accentRed : LiquidGlassDesign.Colors.accentGreen)
                            .shadow(color: (isNavigating ? LiquidGlassDesign.Colors.accentRed : LiquidGlassDesign.Colors.accentGreen).opacity(0.4), radius: 10, x: 0, y: 4)
                    )
            }
            .liquidGlassGlow(
                color: isNavigating ? LiquidGlassDesign.Colors.accentRed : LiquidGlassDesign.Colors.accentGreen,
                radius: 12
            )
        }
    }
}

// MARK: - Liquid Glass Map View
struct LiquidGlassMapView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var navigationService: NavigationService
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        ZStack {
            // Map
            Map(position: .constant(.region(region)), interactionModes: .all) {
                if let userLocation = locationService.currentLocation {
                    Marker("You", coordinate: userLocation.coordinate)
                        .tint(.blue)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            // Map Overlays
            VStack {
                // Transport Mode Selector
                transportModeSelector
                    .padding(.top, LiquidGlassDesign.Spacing.md)
                
                Spacer()
                
                // Route Information
                if let route = navigationService.currentRoute {
                    routeInformationCard(route)
                        .padding(.bottom, LiquidGlassDesign.Spacing.xl)
                }
            }
        }
    }
    
    // MARK: - Transport Mode Selector
    private var transportModeSelector: some View {
        HStack(spacing: LiquidGlassDesign.Spacing.sm) {
            ForEach(TransportMode.allCases, id: \.self) { mode in
                TransportModeButton(
                    mode: mode,
                    isSelected: navigationService.currentTransportMode == mode,
                    action: { navigationService.setTransportMode(mode) }
                )
            }
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
    }
    
    // MARK: - Route Information Card
    private func routeInformationCard(_ route: RouteResult) -> some View {
        LiquidGlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Route to Destination")
                        .font(LiquidGlassDesign.Typography.headline)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    HStack(spacing: LiquidGlassDesign.Spacing.md) {
                        Label("\(Int(route.distance / 1000)) km", systemImage: "location")
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        
                        Label("\(Int(route.expectedTravelTime / 60)) min", systemImage: "clock")
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Button(action: { navigationService.startNavigation() }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(LiquidGlassDesign.Colors.liquidBlue)
                                .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                }
            }
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
    }
}

// MARK: - Liquid Glass Navigation Overlay
struct LiquidGlassNavigationOverlay: View {
    @EnvironmentObject private var navigationService: NavigationService
    @State private var currentStepIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Turn")
                        .font(LiquidGlassDesign.Typography.caption)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    
                    if let currentStep = navigationService.currentRoute?.steps.first {
                        Text(currentStep.instructions)
                            .font(LiquidGlassDesign.Typography.headline)
                            .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    }
                }
                
                Spacer()
                
                Button(action: { navigationService.stopNavigation() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(LiquidGlassDesign.Colors.glassWhite)
                        )
                }
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
            )
            
            // Navigation Steps
            if let route = navigationService.currentRoute {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        ForEach(Array(route.steps.enumerated()), id: \.offset) { index, step in
                            NavigationStepCard(step: step, isActive: index == currentStepIndex)
                        }
                    }
                    .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                }
                .padding(.vertical, LiquidGlassDesign.Spacing.sm)
            }
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Navigation Step Card
struct NavigationStepCard: View {
    let step: RouteStep
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: LiquidGlassDesign.Spacing.sm) {
            Image(systemName: step.maneuverType.mapIcon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isActive ? .white : LiquidGlassDesign.Colors.liquidBlue)
                .frame(width: 24, height: 24)
            
            Text(step.instructions)
                .font(LiquidGlassDesign.Typography.callout)
                .foregroundColor(isActive ? .white : LiquidGlassDesign.Colors.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.sm)
        .padding(.vertical, LiquidGlassDesign.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.sm)
                .fill(isActive ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.glassWhite)
                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Transport Mode Icon Extension
// Note: TransportMode.icon is already defined in NavigationService.swift

// MARK: - Maneuver Type Icon Extension
extension ManeuverType {
    var mapIcon: String {
        switch self {
        case .start: return "play.circle.fill"
        case .end: return "stop.circle.fill"
        case .turnLeft: return "arrow.turn.up.left"
        case .turnRight: return "arrow.turn.up.right"
        case .continueStraight: return "arrow.up"
        case .merge: return "arrow.merge"
        case .exit: return "arrow.branch"
        case .roundabout: return "arrow.clockwise"
        case .ferry: return "ferry.fill"
        case .transit: return "tram.fill"
        }
    }
}

// MARK: - Transport Mode Button
struct TransportModeButton: View {
    let mode: TransportMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16, weight: .medium))
                Text(mode.shortName)
                    .font(LiquidGlassDesign.Typography.caption)
            }
            .foregroundColor(isSelected ? .white : LiquidGlassDesign.Colors.liquidBlue)
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(isSelected ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    LiquidGlassNavigationView()
        .environmentObject(LocationService.shared)
        .environmentObject(NavigationService.shared)
}
