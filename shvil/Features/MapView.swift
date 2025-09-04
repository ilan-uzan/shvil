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
    @State private var isFocusMode = false
    @State private var showExitConfirmation = false
    @State private var showOverflowMenu = false
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
        }
        .navigationBarHidden(true)
        .gesture(
            // Edge swipe right gesture for exit confirmation
            DragGesture()
                .onEnded { value in
                    if isFocusMode && value.startLocation.x < 50 && value.translation.width > 100 {
                        showExitConfirmation = true
                    }
                }
        )
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
    
    // MARK: - Focus Mode Components
    
    private var focusModeTopSlab: some View {
        VStack(spacing: 0) {
            // Drag handle for exit gesture
            RoundedRectangle(cornerRadius: 2)
                .fill(LiquidGlassColors.secondaryText.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            HStack(spacing: 16) {
                // Arrow direction
                Image(systemName: getDirectionArrow(for: navigationService.currentStep))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Next maneuver
                    Text(getManeuverText(for: navigationService.currentStep))
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(2)
                    
                    // Distance and lanes
                    HStack(spacing: 12) {
                        Text(getDistanceText(for: navigationService.currentStep))
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                        
                        if let lanes = getLanesText(for: navigationService.currentStep) {
                            Text(lanes)
                                .font(LiquidGlassTypography.caption)
                                .foregroundColor(LiquidGlassColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                // Exit button
                Button(action: {
                    showExitConfirmation = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                .accessibilityLabel("Exit Focus Mode")
                .accessibilityHint("Double tap to exit navigation")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(height: 84) // 72-96 height range, using 84
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LiquidGlassColors.glassSurface2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: isFocusMode)
    }
    
    private var focusModeBottomBar: some View {
        HStack(spacing: 16) {
            // ETA/Arrival info (left)
            VStack(alignment: .leading, spacing: 2) {
                Text("ETA")
                    .font(LiquidGlassTypography.captionSmall)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text(formatArrivalTime())
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
            }
            
            Spacer()
            
            // Stop button (right)
            Button(action: {
                navigationService.stopNavigation()
                isFocusMode = false
                stopRerouteTimer()
            }) {
                Text("Stop")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LiquidGlassColors.accident)
                    )
            }
            .accessibilityLabel("Stop Navigation")
            .accessibilityHint("Double tap to stop navigation")
            
            // Overflow menu (right)
            Button(action: {
                showOverflowMenu = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("More options")
            .accessibilityHint("Double tap to show more navigation options")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LiquidGlassColors.glassSurface2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: isFocusMode)
    }
    
    private var exitConfirmationDialog: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showExitConfirmation = false
                }
            
            // Dialog content
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(LiquidGlassColors.accident)
                    
                    Text("Exit Navigation?")
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    Text("You'll lose your current route and navigation progress.")
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 16) {
                    // Cancel button
                    Button(action: {
                        showExitConfirmation = false
                    }) {
                        Text("Cancel")
                            .font(LiquidGlassTypography.bodySemibold)
                            .foregroundColor(LiquidGlassColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LiquidGlassColors.glassSurface1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                                    )
                            )
                    }
                    .accessibilityLabel("Cancel exit")
                    .accessibilityHint("Double tap to cancel exiting navigation")
                    
                    // Exit button
                    Button(action: {
                        navigationService.stopNavigation()
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.3)) {
                            isFocusMode = false
                            showExitConfirmation = false
                        }
                        stopRerouteTimer()
                    }) {
                        Text("Exit")
                            .font(LiquidGlassTypography.bodySemibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LiquidGlassColors.accident)
                            )
                    }
                    .accessibilityLabel("Exit navigation")
                    .accessibilityHint("Double tap to confirm exiting navigation")
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LiquidGlassColors.glassSurface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: showExitConfirmation)
    }
    
    // MARK: - Overflow Menu Sheet
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
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Navigation Options")
                            .font(LiquidGlassTypography.title)
                            .foregroundColor(LiquidGlassColors.primaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            showOverflowMenu = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(LiquidGlassColors.secondaryText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Menu items
                    VStack(spacing: 0) {
                        // Share ETA
                        Button(action: {
                            shareETA()
                            showOverflowMenu = false
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                    .foregroundColor(LiquidGlassColors.accentText)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Share ETA")
                                        .font(LiquidGlassTypography.body)
                                        .foregroundColor(LiquidGlassColors.primaryText)
                                    
                                    Text("Send arrival time to friends")
                                        .font(LiquidGlassTypography.caption)
                                        .foregroundColor(LiquidGlassColors.secondaryText)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .accessibilityLabel("Share ETA")
                        .accessibilityHint("Double tap to share your arrival time")
                        
                        Divider()
                            .background(LiquidGlassColors.glassSurface3)
                        
                        // Add Stop
                        Button(action: {
                            addStop()
                            showOverflowMenu = false
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                                    .foregroundColor(LiquidGlassColors.accentText)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Add Stop")
                                        .font(LiquidGlassTypography.body)
                                        .foregroundColor(LiquidGlassColors.primaryText)
                                    
                                    Text("Add a waypoint to your route")
                                        .font(LiquidGlassTypography.caption)
                                        .foregroundColor(LiquidGlassColors.secondaryText)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .accessibilityLabel("Add Stop")
                        .accessibilityHint("Double tap to add a waypoint to your route")
                        
                        Divider()
                            .background(LiquidGlassColors.glassSurface3)
                        
                        // Audio Controls
                        Button(action: {
                            toggleAudio()
                            showOverflowMenu = false
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "speaker.wave.2")
                                    .font(.title3)
                                    .foregroundColor(LiquidGlassColors.accentText)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Audio Controls")
                                        .font(LiquidGlassTypography.body)
                                        .foregroundColor(LiquidGlassColors.primaryText)
                                    
                                    Text("Adjust voice guidance settings")
                                        .font(LiquidGlassTypography.caption)
                                        .foregroundColor(LiquidGlassColors.secondaryText)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .accessibilityLabel("Audio Controls")
                        .accessibilityHint("Double tap to adjust voice guidance settings")
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LiquidGlassColors.glassSurface1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: showOverflowMenu)
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
            routeOptionChips
            routeOptions
            actionButtons
        }
    }
    
    private var routeOptionChips: some View {
        HStack(spacing: 12) {
            // Fastest route chip
            Button(action: {
                navigationService.selectRoute(at: 0)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Fastest")
                        .font(LiquidGlassTypography.captionMedium)
                }
                .foregroundColor(navigationService.selectedRouteIndex == 0 ? .white : LiquidGlassColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(navigationService.selectedRouteIndex == 0 ? LiquidGlassColors.accentText : LiquidGlassColors.glassSurface1)
                        .overlay(
                            Capsule()
                                .stroke(navigationService.selectedRouteIndex == 0 ? Color.clear : LiquidGlassColors.glassSurface3, lineWidth: 1)
                        )
                )
            }
            .accessibilityLabel("Fastest route")
            .accessibilityHint("Select the fastest route option")
            
            // Safest route chip
            Button(action: {
                if navigationService.routes.count > 1 {
                    navigationService.selectRoute(at: 1)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Safest")
                        .font(LiquidGlassTypography.captionMedium)
                }
                .foregroundColor(navigationService.selectedRouteIndex == 1 ? .white : LiquidGlassColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(navigationService.selectedRouteIndex == 1 ? LiquidGlassColors.accentText : LiquidGlassColors.glassSurface1)
                        .overlay(
                            Capsule()
                                .stroke(navigationService.selectedRouteIndex == 1 ? Color.clear : LiquidGlassColors.glassSurface3, lineWidth: 1)
                        )
                )
            }
            .disabled(navigationService.routes.count <= 1)
            .opacity(navigationService.routes.count <= 1 ? 0.5 : 1.0)
            .accessibilityLabel("Safest route")
            .accessibilityHint("Select the safest route option")
            
            Spacer()
        }
        .padding(.horizontal, 4)
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
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.3)) {
                    isFocusMode = true
                }
                startRerouteTimer()
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
    
    // MARK: - Focus Mode Helper Functions
    
    private func getDirectionArrow(for step: MKRoute.Step?) -> String {
        guard let step = step else { return "arrow.up" }
        
        let instruction = step.instructions.lowercased()
        
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
    
    private func getManeuverText(for step: MKRoute.Step?) -> String {
        guard let step = step else { return "Continue straight" }
        return step.instructions.isEmpty ? "Continue straight" : step.instructions
    }
    
    private func getDistanceText(for step: MKRoute.Step?) -> String {
        guard let step = step else { return "0 ft" }
        
        let distance = step.distance
        if distance < 1000 {
            return "\(Int(distance)) ft"
        } else {
            return String(format: "%.1f mi", distance / 1609.34)
        }
    }
    
    private func getLanesText(for step: MKRoute.Step?) -> String? {
        // This would typically come from the route step's lane information
        // For now, return nil as this data isn't readily available in MKRoute.Step
        return nil
    }
    
    private func formatArrivalTime() -> String {
        let now = Date()
        let arrivalTime = now.addingTimeInterval(navigationService.remainingTime)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: arrivalTime)
    }
    
    // MARK: - Overflow Menu Actions
    private func shareETA() {
        // TODO: Implement ETA sharing functionality
        print("Share ETA tapped")
        // This would typically open a share sheet with the ETA information
    }
    
    private func addStop() {
        // TODO: Implement add stop functionality
        print("Add Stop tapped")
        // This would typically open a search interface to add a waypoint
    }
    
    private func toggleAudio() {
        // TODO: Implement audio controls
        print("Audio Controls tapped")
        // This would typically open audio settings or toggle voice guidance
    }
    
    // MARK: - Reroute Logic
    private func checkForReroute() {
        guard isFocusMode else { return }
        
        // This would typically check if the user has deviated from the current route
        // For now, we'll implement a basic check that could be enhanced with actual route tracking
        let currentLocation = locationService.region.center
        let routeDeviationThreshold: Double = 100 // meters
        
        // TODO: Implement actual route deviation detection
        // This would involve:
        // 1. Getting the current route from NavigationService
        // 2. Calculating distance from current location to nearest point on route
        // 3. If distance > threshold, trigger reroute
        
        // For now, we'll simulate a reroute check
        if shouldTriggerReroute() {
            triggerReroute()
        }
    }
    
    private func shouldTriggerReroute() -> Bool {
        // This is a placeholder - in a real implementation, this would check
        // if the user has deviated from the current route
        return false
    }
    
    private func triggerReroute() {
        // Provide haptic feedback for reroute
        HapticFeedback.shared.impact(style: .medium)
        
        // TODO: Implement actual rerouting logic
        // This would involve:
        // 1. Recalculating the route from current location to destination
        // 2. Updating the navigation instructions
        // 3. Providing visual/audio feedback to the user
        
        print("Rerouting triggered")
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
