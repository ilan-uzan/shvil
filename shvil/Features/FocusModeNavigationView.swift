//
//  FocusModeNavigationView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit
import CoreLocation

/// Complete Focus Mode navigation interface with top slab and bottom bar
struct FocusModeNavigationView: View {
    // MARK: - Dependencies
    @StateObject private var routingEngine = RoutingEngine()
    @StateObject private var locationService = LocationService()
    @StateObject private var hapticFeedback = HapticFeedback()
    @StateObject private var smartStopsService = SmartStopsService(
        contextEngine: ContextEngine(),
        locationService: LocationService()
    )
    
    // MARK: - State
    @State private var destination: String = ""
    @State private var isVoiceGuidanceEnabled = true
    @State private var showRouteOverview = false
    @State private var showEmergencyOptions = false
    @State private var currentStepIndex = 0
    @State private var navigationStartTime: Date?
    
    // MARK: - Computed Properties
    private var currentStep: MKRoute.Step? {
        guard let route = routingEngine.currentRoute,
              currentStepIndex < route.steps.count else { return nil }
        return route.steps[currentStepIndex]
    }
    
    private var nextStep: MKRoute.Step? {
        guard let route = routingEngine.currentRoute,
              currentStepIndex + 1 < route.steps.count else { return nil }
        return route.steps[currentStepIndex + 1]
    }
    
    private var formattedRemainingTime: String {
        let hours = Int(routingEngine.remainingTime) / 3600
        let minutes = Int(routingEngine.remainingTime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var formattedRemainingDistance: String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: routingEngine.remainingDistance)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Map Background
            MapView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Slab Navigation Bar
                topSlabNavigationBar
                
                Spacer()
                
                // Smart Stops Suggestions
                if !smartStopsService.activeSuggestions.isEmpty {
                    SmartStopCardContainer(
                        suggestions: smartStopsService.activeSuggestions,
                        onAddStop: { suggestion in
                            smartStopsService.addStopToRoute(suggestion)
                            hapticFeedback.impact(style: .medium)
                        },
                        onDismiss: { suggestion in
                            smartStopsService.dismissSuggestion(suggestion)
                            hapticFeedback.impact(style: .light)
                        },
                        onSnooze: { suggestion in
                            smartStopsService.snoozeSuggestion(suggestion)
                            hapticFeedback.impact(style: .light)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
                
                // Bottom Navigation Bar
                bottomNavigationBar
            }
        }
        .onAppear {
            setupNavigation()
        }
        .sheet(isPresented: $showRouteOverview) {
            RouteOverviewSheet(
                route: routingEngine.currentRoute,
                selectedOption: routingEngine.selectedRouteOption,
                onRouteSelected: { option in
                    routingEngine.selectRouteOption(option)
                    showRouteOverview = false
                }
            )
        }
        .confirmationDialog("Emergency Options", isPresented: $showEmergencyOptions) {
            Button("End Navigation", role: .destructive) {
                endNavigation()
            }
            Button("Call Emergency", role: .destructive) {
                callEmergency()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Top Slab Navigation Bar
    private var topSlabNavigationBar: some View {
        VStack(spacing: 0) {
            // Status Bar Spacer
            Rectangle()
                .fill(Color.clear)
                .frame(height: 12)
            
            // Navigation Content
            HStack(spacing: 16) {
                // Destination Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.isEmpty ? "Navigation" : destination)
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)
                    
                    if routingEngine.isNavigating {
                        HStack(spacing: 8) {
                            Text(formattedRemainingTime)
                                .font(LiquidGlassTypography.captionMedium)
                                .foregroundColor(LiquidGlassColors.accentText)
                            
                            Text("•")
                                .font(LiquidGlassTypography.caption)
                                .foregroundColor(LiquidGlassColors.secondaryText)
                            
                            Text(formattedRemainingDistance)
                                .font(LiquidGlassTypography.captionMedium)
                                .foregroundColor(LiquidGlassColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                // Route Options Toggle
                if !routingEngine.routeOptions.isEmpty {
                    Button(action: toggleRouteOption) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(routingEngine.selectedRouteOption.name)
                                .font(LiquidGlassTypography.captionMedium)
                        }
                        .foregroundColor(LiquidGlassColors.accentText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LiquidGlassColors.glassSurface2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LiquidGlassColors.accentText.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonAccessibility(
                        label: "Route options",
                        hint: "Tap to switch between fastest and safest routes"
                    )
                }
                
                // Exit Navigation Button
                Button(action: endNavigation) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(LiquidGlassColors.glassSurface2)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .buttonAccessibility(
                    label: "Exit navigation",
                    hint: "Tap to end current navigation"
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    // MARK: - Bottom Navigation Bar
    private var bottomNavigationBar: some View {
        VStack(spacing: 0) {
            // Turn-by-turn Instructions
            if let currentStep = currentStep {
                VStack(spacing: 8) {
                    // Current Turn Instruction
                    HStack(spacing: 12) {
                        // Turn Icon
                        Image(systemName: turnIcon(for: currentStep))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(LiquidGlassColors.accentText)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(LiquidGlassColors.glassSurface2)
                                    .overlay(
                                        Circle()
                                            .stroke(LiquidGlassColors.accentText.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentStep.instructions)
                                .font(LiquidGlassTypography.titleXL)
                                .foregroundColor(LiquidGlassColors.primaryText)
                                .lineLimit(2)
                            
                            if let nextStep = nextStep {
                                Text("Then \(nextStep.instructions)")
                                    .font(LiquidGlassTypography.caption)
                                    .foregroundColor(LiquidGlassColors.secondaryText)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Distance to Turn
                        Text(MKDistanceFormatter().string(fromDistance: currentStep.distance))
                            .font(LiquidGlassTypography.captionMedium)
                            .foregroundColor(LiquidGlassColors.accentText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            
            // Control Buttons
            HStack(spacing: 16) {
                // Voice Guidance Toggle
                Button(action: toggleVoiceGuidance) {
                    VStack(spacing: 4) {
                        Image(systemName: isVoiceGuidanceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 20, weight: .medium))
                        Text("Voice")
                            .font(LiquidGlassTypography.captionSmall)
                    }
                    .foregroundColor(isVoiceGuidanceEnabled ? LiquidGlassColors.accentText : LiquidGlassColors.secondaryText)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isVoiceGuidanceEnabled ? LiquidGlassColors.glassSurface2 : LiquidGlassColors.glassSurface1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isVoiceGuidanceEnabled ? LiquidGlassColors.accentText.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .buttonAccessibility(
                    label: isVoiceGuidanceEnabled ? "Voice guidance on" : "Voice guidance off",
                    hint: "Tap to toggle voice guidance"
                )
                
                Spacer()
                
                // Route Overview Button
                Button(action: { showRouteOverview = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 20, weight: .medium))
                        Text("Route")
                            .font(LiquidGlassTypography.captionSmall)
                    }
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LiquidGlassColors.glassSurface2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(LiquidGlassColors.accentText.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonAccessibility(
                    label: "Route overview",
                    hint: "Tap to view full route details"
                )
                
                Spacer()
                
                // Emergency Button
                Button(action: { showEmergencyOptions = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20, weight: .medium))
                        Text("Help")
                            .font(LiquidGlassTypography.captionSmall)
                    }
                    .foregroundColor(LiquidGlassColors.accident)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LiquidGlassColors.glassSurface2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(LiquidGlassColors.accident.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonAccessibility(
                    label: "Emergency options",
                    hint: "Tap for emergency options"
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Helper Methods
    private func setupNavigation() {
        // This would be called when navigation starts
        // For now, we'll simulate with placeholder data
        destination = "Downtown Los Angeles"
        routingEngine.isNavigating = true
        navigationStartTime = Date()
        
        // Start Smart Stops analysis if we have a route
        if let route = routingEngine.currentRoute {
            smartStopsService.startAnalysis(for: route)
        }
    }
    
    private func toggleRouteOption() {
        let currentIndex = routingEngine.routeOptions.firstIndex(where: { $0.id == routingEngine.selectedRouteOption.id }) ?? 0
        let nextIndex = (currentIndex + 1) % routingEngine.routeOptions.count
        routingEngine.selectRouteOption(routingEngine.routeOptions[nextIndex])
        
        hapticFeedback.impact(style: .light)
    }
    
    private func toggleVoiceGuidance() {
        isVoiceGuidanceEnabled.toggle()
        hapticFeedback.impact(style: .light)
    }
    
    private func endNavigation() {
        routingEngine.stopNavigation()
        smartStopsService.stopAnalysis()
        destination = ""
        navigationStartTime = nil
        hapticFeedback.impact(style: .medium)
    }
    
    private func callEmergency() {
        // This would trigger emergency call functionality
        hapticFeedback.impact(style: .heavy)
    }
    
    private func turnIcon(for step: MKRoute.Step) -> String {
        let instructions = step.instructions.lowercased()
        
        if instructions.contains("left") {
            return "arrow.turn.up.left"
        } else if instructions.contains("right") {
            return "arrow.turn.up.right"
        } else if instructions.contains("straight") || instructions.contains("continue") {
            return "arrow.up"
        } else if instructions.contains("u-turn") {
            return "arrow.uturn.up"
        } else if instructions.contains("merge") {
            return "arrow.merge"
        } else if instructions.contains("arrive") {
            return "checkmark.circle.fill"
        } else {
            return "arrow.up"
        }
    }
}

// MARK: - Route Overview Sheet
struct RouteOverviewSheet: View {
    let route: MKRoute?
    let selectedOption: RouteOption
    let onRouteSelected: (RouteOption) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let route = route {
                    // Route Map Preview
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: route.polyline.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )))
                    .frame(height: 200)
                    .overlay(
                        // Route polyline would be rendered here
                        Rectangle()
                            .fill(LiquidGlassColors.accentText.opacity(0.3))
                            .frame(height: 4)
                    )
                    
                    // Route Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Route Details")
                            .font(LiquidGlassTypography.title)
                            .foregroundColor(LiquidGlassColors.primaryText)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Distance")
                                    .font(LiquidGlassTypography.caption)
                                    .foregroundColor(LiquidGlassColors.secondaryText)
                                Text(selectedOption.formattedDistance)
                                    .font(LiquidGlassTypography.bodySemibold)
                                    .foregroundColor(LiquidGlassColors.primaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Time")
                                    .font(LiquidGlassTypography.caption)
                                    .foregroundColor(LiquidGlassColors.secondaryText)
                                Text(selectedOption.formattedTime)
                                    .font(LiquidGlassTypography.bodySemibold)
                                    .foregroundColor(LiquidGlassColors.primaryText)
                            }
                        }
                    }
                    .padding(16)
                }
                
                Spacer()
            }
            .navigationTitle("Route Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassColors.accentText)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FocusModeNavigationView()
        .preferredColorScheme(.dark)
}
