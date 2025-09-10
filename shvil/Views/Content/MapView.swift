//
//  MapView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - Additional Dependencies for MapView
// Note: These services are defined in their respective files

// SearchResult is defined in APIModels.swift
// PlaceDetailsView is defined in PlaceDetailsView.swift

struct MapView: View {
    // Use DependencyContainer for better performance and memory management
    @StateObject private var locationManager = DependencyContainer.shared.locationManager
    @StateObject private var navigationService = DependencyContainer.shared.navigationService
    @StateObject private var searchService = DependencyContainer.shared.searchService

    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var isBottomSheetExpanded = false
    @State private var selectedAnnotation: SearchResult?
    @State private var isFocusMode = false
    @State private var showExitConfirmation = false
    @State private var showOverflowMenu = false
    @State private var showPlaceDetails = false
    @State private var selectedPlace: SearchResult?
    @State private var rerouteTimer: Timer?
    @State private var showSearchOverlay = false
    @State private var searchResults: [SearchResult] = []
    @State private var selectedMapLayer: MapLayer = .standard
    @State private var isLocating: Bool = false

    // Accessibility support
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            mapView
            overlayUI

            // Exit confirmation dialog
            if showExitConfirmation {
                exitConfirmationDialog
            }

            // Overflow menu sheet
            if showOverflowMenu {
                overflowMenuSheet
            }

            // Place details modal
            if showPlaceDetails, let place = selectedPlace {
                PlaceDetailsView(place: place, isPresented: $showPlaceDetails)
            }
            
            // Search overlay
            if showSearchOverlay {
                searchOverlay
            }
        }
        .navigationBarHidden(true)
        .gesture(
            // Edge swipe right gesture for exit confirmation
            DragGesture()
                .onEnded { value in
                    if isFocusMode, value.startLocation.x < 50, value.translation.width > 100 {
                        showExitConfirmation = true
                    }
                }
        )
    }

    // MARK: - Map View

    private var mapView: some View {
        ZStack {
            // Actual MapKit implementation
            Map(coordinateRegion: $locationManager.region, annotationItems: searchService.searchResults) { result in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)) {
                    annotationView(for: result)
                }
            }
            .mapStyle(mapStyleForLayer(selectedMapLayer))
            .ignoresSafeArea()
            
            // Overlay for location denied state
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                locationDeniedView
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .safeAreaInset(edge: .bottom) {
            // Bottom content inset
            Color.clear.frame(height: 140)
        }
    }
    
    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location services enabled"
        case .denied, .restricted:
            return "Location access denied"
        case .notDetermined:
            return "Requesting location access..."
        @unknown default:
            return "Location status unknown"
        }
    }
    
    
    private var locationDeniedView: some View {
        ZStack {
            // Background with proper Liquid Glass effect
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Location icon
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(DesignTokens.Semantic.warning)
                
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("Location Access Required")
                        .font(DesignTokens.Typography.title)
                        .fontWeight(.bold)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Shvil needs location access to show maps and provide navigation. Please enable location services in Settings.")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                    
                    HStack(spacing: DesignTokens.Spacing.md) {
                        LiquidGlassButton(
                            "Open Settings",
                            style: .primary,
                            size: .medium
                        ) {
                            locationManager.openLocationSettings()
                        }
                        
                        LiquidGlassButton(
                            "Continue with Demo",
                            style: .secondary,
                            size: .medium
                        ) {
                            locationManager.showDemoRegion()
                        }
                    }
                    .padding(.top, DesignTokens.Spacing.sm)
                }
            }
            .padding(DesignTokens.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .fill(DesignTokens.Glass.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                            .stroke(DesignTokens.Glass.light, lineWidth: 1)
                    )
                    .appleShadow(DesignTokens.Shadow.glass)
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }
    
    private func mapStyleForLayer(_ layer: MapLayer) -> MapStyle {
        switch layer {
        case .standard:
            return .standard(elevation: .realistic)
        case .satellite:
            return .imagery(elevation: .realistic)
        case .hybrid:
            return .hybrid(elevation: .realistic)
        case .threeD:
            return .standard(elevation: .realistic)
        case .twoD:
            return .standard(elevation: .flat)
        }
    }
    
    // MARK: - Dynamic Colors for Map Layers
    
    private func getDynamicColors(for layer: MapLayer) -> (iconColor: Color, textColor: Color) {
        switch layer {
        case .satellite:
            // For satellite view, use white/light colors for better contrast against dark imagery
            return (iconColor: .white.opacity(0.9), textColor: .white.opacity(0.9))
        case .hybrid:
            // For hybrid view, use slightly darker colors for better readability
            return (iconColor: .white.opacity(0.8), textColor: .white.opacity(0.8))
        case .standard, .threeD, .twoD:
            // For standard views, use the default light grey
            return (iconColor: Color.gray.opacity(0.6), textColor: Color.gray.opacity(0.6))
        }
    }

    private func annotationView(for result: SearchResult) -> some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            // Apple-style annotation
            ZStack {
                    Circle()
                    .fill(DesignTokens.Glass.medium)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(DesignTokens.Glass.light, lineWidth: 2)
                    )
                    .appleShadow(DesignTokens.Shadow.medium)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
            }
            
            // Enhanced label
            Text(result.name)
                .font(DesignTokens.Typography.caption1)
                .foregroundColor(DesignTokens.Text.primary)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                                .stroke(DesignTokens.Glass.light, lineWidth: 1)
                        )
                        .appleShadow(DesignTokens.Shadow.light)
                )
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .scaleEffect(selectedAnnotation == result ? 1.1 : 1.0)
        .animation(DesignTokens.Animation.spring, value: selectedAnnotation == result)
        .onTapGesture {
            withAnimation(DesignTokens.Animation.spring) {
            selectedAnnotation = result
            selectedPlace = result
            showPlaceDetails = true
            }
            HapticFeedback.shared.impact(style: .light)
        }
    }

    // MARK: - Overlay UI

    private var overlayUI: some View {
        ZStack {
            VStack(spacing: 0) {
                if isFocusMode {
                    focusModeTopSlab
                } else {
                    topBar
                }
                Spacer()
                if !isFocusMode {
                    if navigationService.currentRoute != nil {
                        bottomSheet
                    }
                } else {
                    focusModeBottomBar
                }
            }
            
            // Floating action buttons above nav bar
            if !isFocusMode {
                floatingActionButtons
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 0) {
            // Top row with search pill only
            HStack {
                // New rounded search pill with logo
                MapsSearchPill(
                    onSearch: { searchQuery in
                        searchService.search(for: searchQuery)
                        isSearchFocused = false
                    },
                    onVoiceSearch: {
                        print("Voice search activated")
                        HapticFeedback.shared.impact(style: .light)
                    },
                    dynamicTextColor: getDynamicColors(for: selectedMapLayer).textColor,
                    dynamicIconColor: getDynamicColors(for: selectedMapLayer).iconColor
                )
                
                Spacer()
            }
            .padding(.horizontal, Constants.standardPadding)
            .padding(.top, Constants.spacingSM)
            
            // Popular destinations pills
            PopularDestinationsPills(
                onDestinationSelected: { destination in
                    handlePopularDestinationSelection(destination)
                },
                dynamicIconColor: getDynamicColors(for: selectedMapLayer).iconColor,
                dynamicTextColor: getDynamicColors(for: selectedMapLayer).textColor
            )
            .padding(.top, DesignTokens.Spacing.sm)
        }
    }
    
    private func handlePopularDestinationSelection(_ destination: PopularDestination) {
        // Handle popular destination selection
        let searchQuery = destination.title.lowercased()
        searchService.search(for: searchQuery)
        HapticFeedback.shared.impact(style: .light)
    }
    
    // MARK: - Floating Action Buttons
    
    private var floatingActionButtons: some View {
        ZStack {
            // Layers selector - positioned absolutely
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    MapLayersSelector(selectedLayer: $selectedMapLayer)
                        .accessibilityLabel("Map layers")
                        .accessibilityHint("Double tap to toggle map layers")
                        .padding(.trailing, DesignTokens.Spacing.lg)
                        .padding(.bottom, 200) // Position above locate button
                }
            }
            
            // Locate Me button - positioned absolutely
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    LocateMeButton(isLocating: $isLocating) {
                        locationManager.centerOnUserLocation()
                        isLocating = true
                        HapticFeedback.shared.impact(style: .medium)
                        
                        // Reset locating state after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isLocating = false
                        }
                    }
                    .accessibilityLabel("Center on my location")
                    .accessibilityHint("Double tap to center the map on your current location")
                    .padding(.trailing, DesignTokens.Spacing.lg)
                    .padding(.bottom, 150) // Fixed position above nav bar
                }
            }
        }
    }

    // MARK: - Focus Mode Components

    private var focusModeTopSlab: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignTokens.Text.tertiary)
                .frame(width: 36, height: 4)
                .padding(.top, DesignTokens.Spacing.sm)
                .padding(.bottom, DesignTokens.Spacing.sm)

            HStack(spacing: DesignTokens.Spacing.md) {
                // Direction arrow
                Image(systemName: getDirectionArrow(for: navigationService.currentStep))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    // Next maneuver
                    Text(getManeuverText(for: navigationService.currentStep))
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(2)

                    // Distance and lanes
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(getDistanceText(for: navigationService.currentStep))
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)

                        if let lanes = getLanesText(for: navigationService.currentStep) {
                            Text(lanes)
                                .font(DesignTokens.Typography.caption1)
                                .foregroundColor(DesignTokens.Text.secondary)
                        }
                    }
                }

                Spacer()

                // Exit button
                AppleGlassFAB(
                    icon: "xmark.circle.fill",
                    size: .small,
                    style: .secondary
                ) {
                    showExitConfirmation = true
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.md)
        }
        .frame(height: 84)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(DesignTokens.Glass.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .appleShadow(DesignTokens.Shadow.medium)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.top, DesignTokens.Spacing.sm)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
        .animation(reduceMotion ? .none : DesignTokens.Animation.standard, value: isFocusMode)
    }

    private var focusModeBottomBar: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // ETA/Arrival info
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("ETA")
                    .font(AppleTypography.caption2)
                    .foregroundColor(DesignTokens.Text.secondary)

                Text(formatArrivalTime())
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)
            }

            Spacer()

            // Stop button
            AppleGlassButton(
                "Stop",
                style: .destructive,
                size: .medium
            ) {
                Task {
                    await navigationService.stopNavigation()
                }
                isFocusMode = false
                stopRerouteTimer()
            }

            // Overflow menu
            AppleGlassFAB(
                icon: "ellipsis",
                size: .small,
                style: .secondary
            ) {
                showOverflowMenu = true
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(DesignTokens.Glass.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .appleShadow(DesignTokens.Shadow.medium)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.bottom, DesignTokens.Spacing.sm)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
        .animation(reduceMotion ? .none : DesignTokens.Animation.standard, value: isFocusMode)
    }

    // MARK: - Floating Buttons

    private var floatingButtons: some View {
        HStack {
            // Layers FAB
            AppleGlassFAB(
                icon: "square.stack.3d.up",
                size: .medium,
                style: .secondary
            ) {
                    print("Layers tapped")
                HapticFeedback.shared.impact(style: .light)
                }
            .accessibilityLabel("Map layers")
            .accessibilityHint("Double tap to toggle map layers")

            Spacer()

            // Locate Me FAB
            AppleGlassFAB(
                icon: "location.fill",
                size: .large,
                style: .primary
            ) {
                locationManager.centerOnUserLocation()
                HapticFeedback.shared.impact(style: .medium)
            }
            .accessibilityLabel("Center on my location")
            .accessibilityHint("Double tap to center the map on your current location")
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.md)
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DesignTokens.Text.tertiary)
                        .frame(width: 36, height: 4)
                        .padding(.top, DesignTokens.Spacing.sm)
                        .padding(.bottom, DesignTokens.Spacing.sm)

                    VStack(spacing: DesignTokens.Spacing.md) {
                        bottomSheetHeader

                        if isBottomSheetExpanded, !navigationService.routes.isEmpty {
                            bottomSheetContent
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.md)
                }
                .frame(height: isBottomSheetExpanded ? min(geometry.size.height * 0.65, 400) : 84)
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                                .fill(DesignTokens.Glass.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                        .blendMode(.overlay)
                                )
                        )
                )
                .appleShadow(DesignTokens.Shadow.glass)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.md)
                .animation(reduceMotion ? .none : DesignTokens.Animation.complex, value: isBottomSheetExpanded)
            }
        }
    }

    private var bottomSheetHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                if let route = navigationService.currentRoute {
                    Text("\(Int(route.expectedTravelTime / 60)) min")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DesignTokens.Text.primary)

                    Text("\(String(format: "%.1f", route.distance / 1000)) km via \(route.name)")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }

            Spacer()

            if navigationService.currentRoute != nil {
                AppleGlassFAB(
                    icon: isBottomSheetExpanded ? "chevron.down" : "chevron.up",
                    size: .small,
                    style: .secondary
                ) {
                    withAnimation {
                        isBottomSheetExpanded.toggle()
                    }
                }
            }
        }
    }

    private var bottomSheetContent: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            routeOptionChips
            routeOptions
            actionButtons
        }
    }

    private var routeOptionChips: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            // Fastest route chip
            AppleGlassButton(
                "Fastest",
                icon: "bolt.fill",
                style: navigationService.selectedRouteIndex == 0 ? .primary : .secondary,
                size: .small
            ) {
                Task {
                    await navigationService.selectRoute(at: 0)
                }
            }

            // Safest route chip
            AppleGlassButton(
                "Safest",
                icon: "shield.fill",
                style: navigationService.selectedRouteIndex == 1 ? .primary : .secondary,
                size: .small
            ) {
                if navigationService.routes.count > 1 {
                    Task {
                        await navigationService.selectRoute(at: 1)
                    }
                }
            }
            .disabled(navigationService.routes.count <= 1)
            .opacity(navigationService.routes.count <= 1 ? 0.5 : 1.0)

            Spacer()
        }
    }

    private var routeOptions: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ForEach(Array(navigationService.routes.enumerated()), id: \.offset) { index, route in
                AppleGlassCard(style: .elevated) {
                    HStack {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(route.name)
                                .font(DesignTokens.Typography.bodyEmphasized)
                                .foregroundColor(DesignTokens.Text.primary)

                            Text("\(Int(route.expectedTravelTime / 60)) min • \(String(format: "%.1f", route.distance / 1000)) km")
                                .font(DesignTokens.Typography.caption1)
                                .foregroundColor(DesignTokens.Text.secondary)
                        }

                        Spacer()

                        if index == navigationService.selectedRouteIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(DesignTokens.Brand.primary)
                        }
                    }
                }
                .onTapGesture {
                        Task {
                            await navigationService.selectRoute(at: index)
                        }
                    }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            AppleButton(
                "Share ETA",
                icon: "square.and.arrow.up",
                style: .secondary,
                size: .medium
            ) {
                print("Share ETA tapped")
            }

            AppleButton(
                "Start",
                icon: "play.fill",
                style: .primary,
                size: .medium
            ) {
                Task {
                    await navigationService.startNavigation()
                }
                withAnimation(reduceMotion ? .none : DesignTokens.Animation.standard) {
                    isFocusMode = true
                }
                startRerouteTimer()
            }
        }
    }

    // MARK: - Dialogs

    private var exitConfirmationDialog: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showExitConfirmation = false
                }

            // Dialog content
            AppleGlassCard(style: .elevated) {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.Semantic.error)

                        Text("Exit Navigation?")
                            .font(DesignTokens.Typography.title2)
                            .foregroundColor(DesignTokens.Text.primary)

                        Text("You'll lose your current route and navigation progress.")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: DesignTokens.Spacing.md) {
                        AppleGlassButton(
                            "Cancel",
                            style: .secondary,
                            size: .medium
                        ) {
                            showExitConfirmation = false
                        }

                        AppleGlassButton(
                            "Exit",
                            style: .destructive,
                            size: .medium
                        ) {
                            Task {
                                await navigationService.stopNavigation()
                            }
                            withAnimation(reduceMotion ? .none : DesignTokens.Animation.standard) {
                                isFocusMode = false
                                showExitConfirmation = false
                            }
                            stopRerouteTimer()
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
        }
        .animation(reduceMotion ? .none : DesignTokens.Animation.standard, value: showExitConfirmation)
    }

    private var overflowMenuSheet: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showOverflowMenu = false
                }

            // Menu content
            VStack(spacing: 0) {
                Spacer()

                AppleGlassCard(style: .elevated) {
                    VStack(spacing: 0) {
                        // Header
                HStack {
                            Text("Navigation Options")
                                .font(DesignTokens.Typography.title3)
                                .foregroundColor(DesignTokens.Text.primary)

                            Spacer()

                            AppleGlassFAB(
                                icon: "xmark",
                                size: .small,
                                style: .secondary
                            ) {
                                showOverflowMenu = false
                            }
                        }
                        .padding(.bottom, DesignTokens.Spacing.md)

                        // Menu items
                        VStack(spacing: 0) {
                            AppleGlassListRow(
                                icon: "square.and.arrow.up",
                                title: "Share ETA",
                                subtitle: "Send arrival time to friends",
                                action: {
                                    shareETA()
                                    showOverflowMenu = false
                                }
                            )

                            Divider()
                                .background(DesignTokens.Glass.light)

                            AppleGlassListRow(
                                icon: "plus.circle",
                                title: "Add Stop",
                                subtitle: "Add a waypoint to your route",
                                action: {
                                    addStop()
                                    showOverflowMenu = false
                                }
                            )

                            Divider()
                                .background(DesignTokens.Glass.light)

                            AppleGlassListRow(
                                icon: "speaker.wave.2",
                                title: "Audio Controls",
                                subtitle: "Adjust voice guidance settings",
                                action: {
                                    toggleAudio()
                                    showOverflowMenu = false
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.xxl)
            }
        }
        .animation(reduceMotion ? .none : DesignTokens.Animation.complex, value: showOverflowMenu)
    }

    // MARK: - Helper Functions

    private func getDirectionArrow(for step: RouteStep?) -> String {
        guard let step else { return "arrow.up" }

        let instruction = step.instruction.lowercased()

        if instruction.contains("turn left") || instruction.contains("left turn") {
            return "arrow.turn.up.left"
        } else if instruction.contains("turn right") || instruction.contains("right turn") {
            return "arrow.turn.up.right"
        } else if instruction.contains("u-turn") || instruction.contains("uturn") {
            return "arrow.uturn.up"
        } else if instruction.contains("merge") {
            return "arrow.triangle.merge"
        } else if instruction.contains("exit") {
            return "arrow.triangle.branch"
        } else if instruction.contains("straight") {
            return "arrow.up"
        } else {
            return "arrow.up"
        }
    }

    private func getManeuverText(for step: RouteStep?) -> String {
        guard let step else { return "Continue straight" }
        return step.instruction.isEmpty ? "Continue straight" : step.instruction
    }

    private func getDistanceText(for step: RouteStep?) -> String {
        guard let step else { return "0 ft" }

        let distance = step.distance
        if distance < 1000 {
            return "\(Int(distance)) ft"
        } else {
            return String(format: "%.1f mi", distance / 1609.34)
        }
    }

    private func getLanesText(for _: RouteStep?) -> String? {
        // This would typically come from the route step's lane information
        nil
    }

    private func formatArrivalTime() -> String {
        let now = Date()
        let arrivalTime = now.addingTimeInterval(navigationService.remainingTime)

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: arrivalTime)
    }

    // MARK: - Actions

    private func shareETA() {
        print("Share ETA tapped")
    }

    private func addStop() {
        print("Add Stop tapped")
    }

    private func toggleAudio() {
        print("Audio Controls tapped")
    }

    // MARK: - Reroute Logic

    private func checkForReroute() {
        guard isFocusMode else { return }
        // Implementation for reroute checking
    }

    private func startRerouteTimer() {
        stopRerouteTimer()
        rerouteTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            checkForReroute()
        }
    }

    private func stopRerouteTimer() {
        rerouteTimer?.invalidate()
        rerouteTimer = nil
    }
    
    // MARK: - Search Overlay
    
    private var searchOverlay: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(DesignTokens.Animation.spring) {
                        showSearchOverlay = false
                    }
                }
            
            VStack(spacing: 0) {
                // Search header
                VStack(spacing: DesignTokens.Spacing.md) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DesignTokens.Text.tertiary)
                        .frame(width: 36, height: 4)
                        .padding(.top, DesignTokens.Spacing.sm)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignTokens.Text.secondary)
                            .padding(.leading, DesignTokens.Spacing.sm)
                        
                        TextField("Search places, activities, or locations", text: $searchText)
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                            .onSubmit {
                                performMapSearch()
                            }
                            .accessibilityLabel("Search field")
                            .accessibilityHint("Enter a place, activity, or location to search")
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(DesignTokens.Text.tertiary)
                            }
                            .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .fill(DesignTokens.Glass.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                                    .stroke(DesignTokens.Glass.light, lineWidth: 1)
                            )
                    )
                    .appleShadow(DesignTokens.Shadow.light)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .fill(DesignTokens.Glass.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                        .blendMode(.overlay)
                                )
                        )
                )
                .appleShadow(DesignTokens.Shadow.glass)
                
                // Search results
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                                searchResultRow(for: result)
                                    .id("map-result-\(index)")
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.top, DesignTokens.Spacing.md)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                    .fill(DesignTokens.Glass.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                            .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                            )
                    )
                    .appleShadow(DesignTokens.Shadow.glass)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.sm)
                } else if !searchText.isEmpty {
                    // Empty state
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(DesignTokens.Text.tertiary)
                        
                        Text("No results found")
                            .font(DesignTokens.Typography.title3)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Text("Try searching for something else")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                    .fill(DesignTokens.Glass.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                            .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                            )
                    )
                    .appleShadow(DesignTokens.Shadow.glass)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.sm)
                }
                
                Spacer()
            }
        }
        .animation(reduceMotion ? .none : DesignTokens.Animation.complex, value: showSearchOverlay)
    }
    
    private func searchResultRow(for result: SearchResult) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Place icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(DesignTokens.Surface.secondary)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .stroke(DesignTokens.Glass.light, lineWidth: 1)
                    )
                    .appleShadow(DesignTokens.Shadow.light)
                
                Image(systemName: "location")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
            }
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(result.name)
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)
                    .lineLimit(1)
                
                Text(result.address)
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: {
                selectSearchResult(result)
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DesignTokens.Brand.primary)
            }
            .accessibilityLabel("Add to map")
            .accessibilityHint("Double tap to add \(result.name) to the map")
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(DesignTokens.Shadow.light)
        .onTapGesture {
            selectSearchResult(result)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Search result: \(result.name)")
        .accessibilityHint("Double tap to add to map")
        .accessibilityAddTraits(.isButton)
    }
    
    private func performMapSearch() {
        guard !searchText.isEmpty else { return }
        
        // TODO: Implement actual search logic
        // For now, create mock results
        searchResults = [
            SearchResult(
                id: UUID(),
                name: "\(searchText) Location 1",
                address: "123 Main St, San Francisco, CA",
                latitude: 37.7749,
                longitude: -122.4194,
                category: "popular",
                rating: 4.5,
                distance: 1000.0,
                isOpen: true
            ),
            SearchResult(
                id: UUID(),
                name: "\(searchText) Location 2",
                address: "456 Oak Ave, San Francisco, CA",
                latitude: 37.7849,
                longitude: -122.4094,
                category: "rated",
                rating: 4.8,
                distance: 1500.0,
                isOpen: true
            )
        ]
    }
    
    private func selectSearchResult(_ result: SearchResult) {
        // Add to search results for display on map
        searchService.searchResults.append(result)
        
        // Center map on selected location
        withAnimation(DesignTokens.Animation.spring) {
            locationManager.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Close search overlay
        withAnimation(DesignTokens.Animation.spring) {
            showSearchOverlay = false
        }
        
        HapticFeedback.shared.impact(style: .medium)
    }
}

#Preview {
    MapView()
}