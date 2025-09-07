//
//  MapView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {
    // Use DependencyContainer for better performance and memory management
    @StateObject private var locationService = DependencyContainer.shared.locationService
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
        Map(coordinateRegion: $locationService.region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: .constant(.none),
            annotationItems: searchService.searchResults)
        { result in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)) {
                annotationView(for: result)
            }
        }
        .mapStyle(mapStyleForLayer(selectedMapLayer))
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            // Bottom content inset
            Color.clear.frame(height: 140)
        }
        .onAppear {
            locationService.requestLocationPermission()
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

    private func annotationView(for result: SearchResult) -> some View {
        VStack(spacing: AppleSpacing.xs) {
            // Apple-style annotation
            ZStack {
                    Circle()
                    .fill(AppleColors.glassMedium)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(AppleColors.glassLight, lineWidth: 2)
                    )
                    .appleShadow(AppleShadows.medium)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppleColors.accent)
            }
            
            // Enhanced label
            Text(result.name)
                .font(AppleTypography.caption1)
                .foregroundColor(AppleColors.textPrimary)
                .padding(.horizontal, AppleSpacing.sm)
                .padding(.vertical, AppleSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.sm)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.sm)
                                .stroke(AppleColors.glassLight, lineWidth: 1)
                        )
                        .appleShadow(AppleShadows.light)
                )
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .scaleEffect(selectedAnnotation == result ? 1.1 : 1.0)
        .animation(AppleAnimations.spring, value: selectedAnnotation == result)
        .onTapGesture {
            withAnimation(AppleAnimations.spring) {
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
                    }
                )
                
                Spacer()
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.sm)
            
            // Popular destinations pills
            PopularDestinationsPills { destination in
                handlePopularDestinationSelection(destination)
            }
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
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: DesignTokens.Spacing.sm) {
                    // Layers selector
                    MapLayersSelector(selectedLayer: $selectedMapLayer)
                        .accessibilityLabel("Map layers")
                        .accessibilityHint("Double tap to toggle map layers")
                    
                    // Locate Me button
                    LocateMeButton(isLocating: $isLocating) {
                        locationService.centerOnUserLocation()
                        isLocating = true
                        HapticFeedback.shared.impact(style: .medium)
                        
                        // Reset locating state after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isLocating = false
                        }
                    }
                    .accessibilityLabel("Center on my location")
                    .accessibilityHint("Double tap to center the map on your current location")
                }
                .padding(.trailing, DesignTokens.Spacing.lg)
                .padding(.bottom, 150) // Position higher above nav bar
            }
        }
    }

    // MARK: - Focus Mode Components

    private var focusModeTopSlab: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(AppleColors.textTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, AppleSpacing.sm)
                .padding(.bottom, AppleSpacing.sm)

            HStack(spacing: AppleSpacing.md) {
                // Direction arrow
                Image(systemName: getDirectionArrow(for: navigationService.currentStep))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    // Next maneuver
                    Text(getManeuverText(for: navigationService.currentStep))
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(2)

                    // Distance and lanes
                    HStack(spacing: AppleSpacing.sm) {
                        Text(getDistanceText(for: navigationService.currentStep))
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)

                        if let lanes = getLanesText(for: navigationService.currentStep) {
                            Text(lanes)
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
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
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.md)
        }
        .frame(height: 84)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                .fill(AppleColors.glassMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
        )
        .appleShadow(AppleShadows.medium)
        .padding(.horizontal, AppleSpacing.sm)
        .padding(.top, AppleSpacing.sm)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
        .animation(reduceMotion ? .none : AppleAnimations.standard, value: isFocusMode)
    }

    private var focusModeBottomBar: some View {
        HStack(spacing: AppleSpacing.md) {
            // ETA/Arrival info
            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                Text("ETA")
                    .font(AppleTypography.caption2)
                    .foregroundColor(AppleColors.textSecondary)

                Text(formatArrivalTime())
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)
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
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                .fill(AppleColors.glassMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
        )
        .appleShadow(AppleShadows.medium)
        .padding(.horizontal, AppleSpacing.sm)
        .padding(.bottom, AppleSpacing.sm)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
        .animation(reduceMotion ? .none : AppleAnimations.standard, value: isFocusMode)
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
                locationService.centerOnUserLocation()
                HapticFeedback.shared.impact(style: .medium)
            }
            .accessibilityLabel("Center on my location")
            .accessibilityHint("Double tap to center the map on your current location")
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.bottom, AppleSpacing.md)
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppleColors.textTertiary)
                        .frame(width: 36, height: 4)
                        .padding(.top, AppleSpacing.sm)
                        .padding(.bottom, AppleSpacing.sm)

                    VStack(spacing: AppleSpacing.md) {
                        bottomSheetHeader

                        if isBottomSheetExpanded, !navigationService.routes.isEmpty {
                            bottomSheetContent
                        }
                    }
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.bottom, AppleSpacing.md)
                }
                .frame(height: isBottomSheetExpanded ? min(geometry.size.height * 0.65, 400) : 84)
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                                .fill(AppleColors.glassMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                                        .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                        .blendMode(.overlay)
                                )
                        )
                )
                .appleShadow(AppleShadows.glass)
                .padding(.horizontal, AppleSpacing.md)
                .padding(.bottom, AppleSpacing.md)
                .animation(reduceMotion ? .none : AppleAnimations.complex, value: isBottomSheetExpanded)
            }
        }
    }

    private var bottomSheetHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                if let route = navigationService.currentRoute {
                    Text("\(Int(route.expectedTravelTime / 60)) min")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppleColors.textPrimary)

                    Text("\(String(format: "%.1f", route.distance / 1000)) km via \(route.name)")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
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
        VStack(spacing: AppleSpacing.md) {
            routeOptionChips
            routeOptions
            actionButtons
        }
    }

    private var routeOptionChips: some View {
        HStack(spacing: AppleSpacing.sm) {
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
        VStack(spacing: AppleSpacing.md) {
            ForEach(Array(navigationService.routes.enumerated()), id: \.offset) { index, route in
                AppleGlassCard(style: .elevated) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                            Text(route.name)
                                .font(AppleTypography.bodyEmphasized)
                                .foregroundColor(AppleColors.textPrimary)

                            Text("\(Int(route.expectedTravelTime / 60)) min • \(String(format: "%.1f", route.distance / 1000)) km")
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                        }

                        Spacer()

                        if index == navigationService.selectedRouteIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppleColors.accent)
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
        HStack(spacing: AppleSpacing.md) {
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
                withAnimation(reduceMotion ? .none : AppleAnimations.standard) {
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
                VStack(spacing: AppleSpacing.lg) {
                    VStack(spacing: AppleSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppleColors.danger)

                        Text("Exit Navigation?")
                            .font(AppleTypography.title2)
                            .foregroundColor(AppleColors.textPrimary)

                        Text("You'll lose your current route and navigation progress.")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: AppleSpacing.md) {
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
                            withAnimation(reduceMotion ? .none : AppleAnimations.standard) {
                                isFocusMode = false
                                showExitConfirmation = false
                            }
                            stopRerouteTimer()
                        }
                    }
                }
            }
            .padding(.horizontal, AppleSpacing.xl)
        }
        .animation(reduceMotion ? .none : AppleAnimations.standard, value: showExitConfirmation)
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
                                .font(AppleTypography.title3)
                                .foregroundColor(AppleColors.textPrimary)

                            Spacer()

                            AppleGlassFAB(
                                icon: "xmark",
                                size: .small,
                                style: .secondary
                            ) {
                                showOverflowMenu = false
                            }
                        }
                        .padding(.bottom, AppleSpacing.md)

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
                                .background(AppleColors.glassLight)

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
                                .background(AppleColors.glassLight)

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
                .padding(.horizontal, AppleSpacing.md)
                .padding(.bottom, AppleSpacing.xxl)
            }
        }
        .animation(reduceMotion ? .none : AppleAnimations.complex, value: showOverflowMenu)
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
                    withAnimation(AppleAnimations.spring) {
                        showSearchOverlay = false
                    }
                }
            
            VStack(spacing: 0) {
                // Search header
                VStack(spacing: AppleSpacing.md) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppleColors.textTertiary)
                        .frame(width: 36, height: 4)
                        .padding(.top, AppleSpacing.sm)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppleColors.textSecondary)
                            .padding(.leading, AppleSpacing.sm)
                        
                        TextField("Search places, activities, or locations", text: $searchText)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
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
                                    .foregroundColor(AppleColors.textTertiary)
                            }
                            .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.vertical, AppleSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                            .fill(AppleColors.glassMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                                    .stroke(AppleColors.glassLight, lineWidth: 1)
                            )
                    )
                    .appleShadow(AppleShadows.light)
                }
                .padding(.horizontal, AppleSpacing.md)
                .padding(.bottom, AppleSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                .fill(AppleColors.glassMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                        .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                        .blendMode(.overlay)
                                )
                        )
                )
                .appleShadow(AppleShadows.glass)
                
                // Search results
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: AppleSpacing.sm) {
                            ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                                searchResultRow(for: result)
                                    .id("map-result-\(index)")
                            }
                        }
                        .padding(.horizontal, AppleSpacing.md)
                        .padding(.top, AppleSpacing.md)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                    .fill(AppleColors.glassMedium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                            .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                            )
                    )
                    .appleShadow(AppleShadows.glass)
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.top, AppleSpacing.sm)
                } else if !searchText.isEmpty {
                    // Empty state
                    VStack(spacing: AppleSpacing.lg) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(AppleColors.textTertiary)
                        
                        Text("No results found")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)
                        
                        Text("Try searching for something else")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)
                    }
                    .padding(.vertical, AppleSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                    .fill(AppleColors.glassMedium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                            .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                            )
                    )
                    .appleShadow(AppleShadows.glass)
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.top, AppleSpacing.sm)
                }
                
                Spacer()
            }
        }
        .animation(reduceMotion ? .none : AppleAnimations.complex, value: showSearchOverlay)
    }
    
    private func searchResultRow(for result: SearchResult) -> some View {
        HStack(spacing: AppleSpacing.md) {
            // Place icon
            ZStack {
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .fill(AppleColors.surfaceSecondary)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                            .stroke(AppleColors.glassLight, lineWidth: 1)
                    )
                    .appleShadow(AppleShadows.light)
                
                Image(systemName: "location")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppleColors.accent)
            }
            
            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                Text(result.name)
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)
                    .lineLimit(1)
                
                Text(result.address ?? "Address not available")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: {
                selectSearchResult(result)
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppleColors.brandPrimary)
            }
            .accessibilityLabel("Add to map")
            .accessibilityHint("Double tap to add \(result.name) to the map")
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(AppleShadows.light)
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
        withAnimation(AppleAnimations.spring) {
            locationService.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Close search overlay
        withAnimation(AppleAnimations.spring) {
            showSearchOverlay = false
        }
        
        HapticFeedback.shared.impact(style: .medium)
    }
}

#Preview {
    MapView()
}