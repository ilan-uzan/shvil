//
//  AdventureNavigationView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct AdventureNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adventureKit = DependencyContainer.shared.adventureKit
    @StateObject private var mapEngine = DependencyContainer.shared.mapEngine
    @StateObject private var locationService = DependencyContainer.shared.locationService
    
    let adventure: AdventurePlan
    @State private var currentStopIndex = 0
    @State private var isNavigating = false
    @State private var showStopDetails = false
    @State private var showExitConfirmation = false
    
    private var currentStop: AdventureStop? {
        guard currentStopIndex < adventure.stops.count else { return nil }
        return adventure.stops[currentStopIndex]
    }
    
    private var nextStop: AdventureStop? {
        guard currentStopIndex + 1 < adventure.stops.count else { return nil }
        return adventure.stops[currentStopIndex + 1]
    }
    
    var body: some View {
        ZStack {
            // Background
            LiquidGlassColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar
                
                // Map
                mapSection
                
                // Bottom Navigation Panel
                bottomNavigationPanel
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showStopDetails) {
            if let stop = currentStop {
                AdventureStopDetailView(stop: stop, adventure: adventure)
            }
        }
        .confirmationDialog("Exit Adventure", isPresented: $showExitConfirmation) {
            Button("Exit Adventure", role: .destructive) {
                exitAdventure()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to exit this adventure? Your progress will be saved.")
        }
    }
    
    // MARK: - Top Navigation Bar
    
    private var topNavigationBar: some View {
        VStack(spacing: 0) {
            // Status Bar
            HStack {
                Text("Adventure Active")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Spacer()
                
                Button(action: { showExitConfirmation = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(LiquidGlassColors.glassSurface1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Progress Bar
            progressBar
            
            // Current Stop Info
            if let stop = currentStop {
                currentStopInfo(for: stop)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LiquidGlassColors.glassSurface1)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<adventure.stops.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStopIndex ? LiquidGlassColors.accentDeepAqua : LiquidGlassColors.glassSurface2)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private func currentStopInfo(for stop: AdventureStop) -> some View {
        HStack(spacing: 16) {
            // Stop Number
            ZStack {
                Circle()
                    .fill(LiquidGlassGradients.primaryGradient)
                    .frame(width: 40, height: 40)
                
                Text("\(currentStopIndex + 1)")
                    .font(LiquidGlassTypography.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.chapter)
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .lineLimit(1)
                
                if let name = stop.name {
                    Text(name)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Category Icon
            Image(systemName: stopIcon(for: stop.category))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(LiquidGlassColors.accentDeepAqua)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private func stopIcon(for category: StopCategory) -> String {
        switch category {
        case .landmark: return "building"
        case .food: return "fork.knife"
        case .scenic: return "camera"
        case .museum: return "building.columns"
        case .activity: return "figure.run"
        case .nightlife: return "moon.stars"
        case .hiddenGem: return "star"
        }
    }
    
    // MARK: - Map Section
    
    private var mapSection: some View {
        GeometryReader { geometry in
            Map(coordinateRegion: .constant(mapRegion), annotationItems: adventure.stops) { stop in
                MapAnnotation(coordinate: stop.coordinate ?? CLLocationCoordinate2D()) {
                    adventureStopAnnotation(for: stop)
                }
            }
            .frame(height: geometry.size.height)
            .cornerRadius(0)
        }
    }
    
    private var mapRegion: MKCoordinateRegion {
        guard let currentStop = currentStop,
              let coordinate = currentStop.coordinate else {
            return MKCoordinateRegion(
                center: locationService.currentLocation?.coordinate ?? CLLocationCoordinate2D(),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        return MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    private func adventureStopAnnotation(for stop: AdventureStop) -> some View {
        let isCurrentStop = stop.id == currentStop?.id
        let isCompleted = adventure.stops.firstIndex(where: { $0.id == stop.id }) ?? 0 < currentStopIndex
        
        return ZStack {
            Circle()
                .fill(isCurrentStop ? AnyShapeStyle(LiquidGlassGradients.primaryGradient) : 
                      isCompleted ? AnyShapeStyle(Color.green) : AnyShapeStyle(LiquidGlassColors.glassSurface2))
                .frame(width: isCurrentStop ? 40 : 32, height: isCurrentStop ? 40 : 32)
            
            Image(systemName: isCompleted ? "checkmark" : stopIcon(for: stop.category))
                .font(.system(size: isCurrentStop ? 16 : 14, weight: .medium))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: isCurrentStop ? 4 : 3)
        )
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Bottom Navigation Panel
    
    private var bottomNavigationPanel: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(LiquidGlassColors.secondaryText)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
            
            VStack(spacing: 20) {
                // Navigation Info
                navigationInfoSection
                
                // Action Buttons
                actionButtonsSection
                
                // Next Stop Preview
                if let nextStop = nextStop {
                    nextStopPreview(for: nextStop)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LiquidGlassColors.glassSurface1)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private var navigationInfoSection: some View {
        HStack(spacing: 20) {
            // Distance
            VStack(alignment: .leading, spacing: 4) {
                Text("Distance")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text("0.5 mi")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
            }
            
            Divider()
                .frame(height: 40)
            
            // ETA
            VStack(alignment: .leading, spacing: 4) {
                Text("ETA")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text("8 min")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
            }
            
            Divider()
                .frame(height: 40)
            
            // Duration
            VStack(alignment: .leading, spacing: 4) {
                Text("Stay")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text("\(currentStop?.idealDurationMin ?? 0) min")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface2)
        )
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Details Button
            Button(action: { showStopDetails = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Details")
                        .font(LiquidGlassTypography.bodyMedium)
                        .fontWeight(.medium)
                }
                .foregroundColor(LiquidGlassColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassColors.glassSurface2)
                )
            }
            
            // Arrived Button
            Button(action: markArrived) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("I'm Here")
                        .font(LiquidGlassTypography.bodyMedium)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassGradients.primaryGradient)
                )
            }
        }
    }
    
    private func nextStopPreview(for nextStop: AdventureStop) -> some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                // Next Stop Icon
                ZStack {
                    Circle()
                        .fill(LiquidGlassColors.glassSurface2)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: stopIcon(for: nextStop.category))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Next: \(nextStop.chapter)")
                        .font(LiquidGlassTypography.bodyMedium)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)
                    
                    if let name = nextStop.name {
                        Text(name)
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassColors.glassSurface2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    
    private func markArrived() {
        // Mark current stop as completed
        currentStopIndex += 1
        
        if currentStopIndex >= adventure.stops.count {
            // Adventure completed
            completeAdventure()
        } else {
            // Move to next stop
            HapticFeedback.shared.impact(style: .medium)
        }
    }
    
    private func completeAdventure() {
        // Show completion screen
        HapticFeedback.shared.impact(style: .heavy)
        dismiss()
    }
    
    private func exitAdventure() {
        // Save progress and exit
        HapticFeedback.shared.impact(style: .medium)
        dismiss()
    }
}

#Preview {
    AdventureNavigationView(adventure: AdventurePlan(
        title: "Downtown Food Adventure",
        tagline: "A culinary journey through the heart of the city",
        theme: "Food & Culture",
        mood: .fun,
        durationHours: 3,
        isGroup: false,
        stops: [
            AdventureStop(
                chapter: "Morning Coffee",
                category: .food,
                idealDurationMin: 30,
                narrative: "Start your day with the best coffee in town",
                constraints: StopConstraints(),
                name: "Blue Bottle Coffee",
                address: "123 Main St",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            ),
            AdventureStop(
                chapter: "Art Gallery",
                category: .museum,
                idealDurationMin: 45,
                narrative: "Explore contemporary art",
                constraints: StopConstraints(),
                name: "Modern Art Gallery",
                address: "456 Art Ave",
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094)
            )
        ],
        notes: "Perfect for a weekend morning"
    ))
}
