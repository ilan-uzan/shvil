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
    @StateObject private var locationService = LocationService()
    @StateObject private var navigationService = NavigationService()
    @StateObject private var searchService = SearchService()

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
            MapAnnotation(coordinate: result.coordinate) {
                annotationView(for: result)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            // Bottom content inset
            Color.clear.frame(height: 140)
        }
        .onAppear {
            locationService.requestLocationPermission()
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
        VStack(spacing: 0) {
            if isFocusMode {
                focusModeTopSlab
            } else {
                topBar
            }
            Spacer()
            if !isFocusMode {
                floatingButtons
                bottomSheet
            } else {
                focusModeBottomBar
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: AppleSpacing.sm) {
            // Profile Button
            AppleGlassFAB(
                icon: "person.circle.fill",
                size: .small,
                style: .secondary
            ) {
                print("Profile tapped")
                HapticFeedback.shared.impact(style: .light)
            }

            // Search Bar
            AppleGlassSearchBar(
                text: $searchText,
                placeholder: "Search places, activities, or locations"
            ) {
                if !searchText.isEmpty {
                    searchService.search(for: searchText)
                }
            }

            // Voice Search Button
            AppleGlassFAB(
                icon: "mic.fill",
                size: .small,
                style: .secondary
            ) {
                print("Voice search tapped")
                HapticFeedback.shared.impact(style: .light)
            }
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.top, AppleSpacing.sm)
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
        .glassmorphism(intensity: .medium, cornerRadius: AppleCornerRadius.xl)
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
                title: "Stop",
                style: .destructive,
                size: .medium
            ) {
                navigationService.stopNavigation()
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
        .glassmorphism(intensity: .medium, cornerRadius: AppleCornerRadius.xl)
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
            VStack(spacing: AppleSpacing.sm) {
                // Adventure FAB
                AppleGlassFAB(
                    icon: "map.fill",
                    size: .small,
                    style: .secondary
                ) {
                    print("Adventure tapped")
                    HapticFeedback.shared.impact(style: .light)
                }

                // Layers FAB
                AppleGlassFAB(
                    icon: "square.stack.3d.up",
                    size: .medium,
                    style: .secondary
                ) {
                    print("Layers tapped")
                    HapticFeedback.shared.impact(style: .light)
                }
            }

            Spacer()

            // Locate Me FAB
            AppleGlassFAB(
                icon: "location.fill",
                size: .medium,
                style: .primary
            ) {
                locationService.centerOnUserLocation()
                HapticFeedback.shared.impact(style: .light)
            }
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
                .glassmorphism(intensity: .medium, cornerRadius: AppleCornerRadius.xl)
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
                } else {
                    Text("Search for a destination")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)

                    Text("Tap on a location to get directions")
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
                title: "Fastest",
                icon: "bolt.fill",
                style: navigationService.selectedRouteIndex == 0 ? .primary : .secondary,
                size: .small
            ) {
                navigationService.selectRoute(at: 0)
            }

            // Safest route chip
            AppleGlassButton(
                title: "Safest",
                icon: "shield.fill",
                style: navigationService.selectedRouteIndex == 1 ? .primary : .secondary,
                size: .small
            ) {
                if navigationService.routes.count > 1 {
                    navigationService.selectRoute(at: 1)
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
                AppleGlassCard(style: .glassmorphism) {
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
                    navigationService.selectRoute(at: index)
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: AppleSpacing.md) {
            AppleGlassButton(
                title: "Share ETA",
                icon: "square.and.arrow.up",
                style: .secondary,
                size: .medium
            ) {
                print("Share ETA tapped")
            }

            AppleGlassButton(
                title: "Start",
                icon: "play.fill",
                style: .primary,
                size: .medium
            ) {
                navigationService.startNavigation()
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
            AppleGlassCard(style: .glassmorphism, cornerRadius: AppleCornerRadius.lg) {
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
                            title: "Cancel",
                            style: .secondary,
                            size: .medium
                        ) {
                            showExitConfirmation = false
                        }

                        AppleGlassButton(
                            title: "Exit",
                            style: .destructive,
                            size: .medium
                        ) {
                            navigationService.stopNavigation()
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

                AppleGlassCard(style: .glassmorphism, cornerRadius: AppleCornerRadius.lg) {
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
                                showChevron: false,
                                action: {
                                    shareETA()
                                    showOverflowMenu = false
                                }
                            ) {
                                HStack(spacing: AppleSpacing.md) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(AppleColors.accent)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                                        Text("Share ETA")
                                            .font(AppleTypography.body)
                                            .foregroundColor(AppleColors.textPrimary)

                                        Text("Send arrival time to friends")
                                            .font(AppleTypography.caption1)
                                            .foregroundColor(AppleColors.textSecondary)
                                    }

                                    Spacer()
                                }
                            }

                            Divider()
                                .background(AppleColors.glassLight)

                            AppleGlassListRow(
                                showChevron: false,
                                action: {
                                    addStop()
                                    showOverflowMenu = false
                                }
                            ) {
                                HStack(spacing: AppleSpacing.md) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(AppleColors.accent)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                                        Text("Add Stop")
                                            .font(AppleTypography.body)
                                            .foregroundColor(AppleColors.textPrimary)

                                        Text("Add a waypoint to your route")
                                            .font(AppleTypography.caption1)
                                            .foregroundColor(AppleColors.textSecondary)
                                    }

                                    Spacer()
                                }
                            }

                            Divider()
                                .background(AppleColors.glassLight)

                            AppleGlassListRow(
                                showChevron: false,
                                action: {
                                    toggleAudio()
                                    showOverflowMenu = false
                                }
                            ) {
                                HStack(spacing: AppleSpacing.md) {
                                    Image(systemName: "speaker.wave.2")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(AppleColors.accent)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                                        Text("Audio Controls")
                                            .font(AppleTypography.body)
                                            .foregroundColor(AppleColors.textPrimary)

                                        Text("Adjust voice guidance settings")
                                            .font(AppleTypography.caption1)
                                            .foregroundColor(AppleColors.textSecondary)
                                    }

                                    Spacer()
                                }
                            }
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
}

#Preview {
    MapView()
}