//
//  AdventureStopDetailView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct AdventureStopDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mapEngine = DependencyContainer.shared.mapEngine
    @StateObject private var locationService = DependencyContainer.shared.locationService
    
    let stop: AdventureStop
    let adventure: AdventurePlan
    
    @State private var isNavigating = false
    @State private var showDirections = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LiquidGlassColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Map
                        mapSection
                        
                        // Stop Info
                        stopInfoSection
                        
                        // Narrative
                        narrativeSection
                        
                        // Constraints
                        constraintsSection
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Stop Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
        }
        .sheet(isPresented: $showDirections) {
            DirectionsView(stop: stop)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stop Number and Category
            HStack {
                // Stop Number
                ZStack {
                    Circle()
                        .fill(LiquidGlassGradients.primaryGradient)
                        .frame(width: 48, height: 48)
                    
                    Text("\(stopIndex + 1)")
                        .font(LiquidGlassTypography.titleXL)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(stop.chapter)
                        .font(LiquidGlassTypography.titleXL)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    Text(stop.category.displayName)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                
                Spacer()
                
                // Category Icon
                Image(systemName: stopIcon(for: stop.category))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)
            }
            
            // Duration
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text("\(stop.idealDurationMin) minutes")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Spacer()
                
                if let stayMinutes = stop.stayMinutes {
                    Text("Stay: \(stayMinutes) min")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LiquidGlassColors.glassSurface2)
                        )
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var stopIndex: Int {
        adventure.stops.firstIndex(where: { $0.id == stop.id }) ?? 0
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            if let coordinate = stop.coordinate {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), annotationItems: [stop]) { stop in
                    MapAnnotation(coordinate: stop.coordinate!) {
                        ZStack {
                            Circle()
                                .fill(LiquidGlassGradients.primaryGradient)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: stopIcon(for: stop.category))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 200)
                .cornerRadius(16)
            } else {
                // No location available
                VStack(spacing: 12) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Text("Location not available")
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassColors.glassSurface1)
                )
            }
        }
    }
    
    // MARK: - Stop Info Section
    
    private var stopInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let name = stop.name {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Place Name")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Text(name)
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
            
            if let address = stop.address {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Address")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Text(address)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
            
            if let startHint = stop.startHintTimestamp {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Best Time to Visit")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Text(startHint, style: .time)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }
    
    // MARK: - Narrative Section
    
    private var narrativeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What to Expect")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            Text(stop.narrative)
                .font(LiquidGlassTypography.body)
                .foregroundColor(LiquidGlassColors.primaryText)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }
    
    // MARK: - Constraints Section
    
    private var constraintsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            VStack(spacing: 12) {
                // Budget
                constraintRow(
                    icon: "dollarsign.circle",
                    title: "Budget",
                    value: stop.constraints.budget.displayName
                )
                
                // Accessibility
                constraintRow(
                    icon: "figure.roll",
                    title: "Accessibility",
                    value: stop.constraints.accessibility ? "Wheelchair Accessible" : "Not Accessible"
                )
                
                // Outdoor
                constraintRow(
                    icon: "leaf",
                    title: "Setting",
                    value: stop.constraints.outdoor ? "Outdoor" : "Indoor"
                )
                
                // Open Late
                if stop.constraints.openLate {
                    constraintRow(
                        icon: "moon",
                        title: "Hours",
                        value: "Open Late"
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }
    
    private func constraintRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(LiquidGlassColors.accentDeepAqua)
                .frame(width: 20)
            
            Text(title)
                .font(LiquidGlassTypography.body)
                .foregroundColor(LiquidGlassColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(LiquidGlassTypography.body)
                .foregroundColor(LiquidGlassColors.primaryText)
        }
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Navigate Button
            Button(action: navigateToStop) {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Navigate Here")
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
            
            // Directions Button
            Button(action: { showDirections = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Get Directions")
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
        }
    }
    
    // MARK: - Actions
    
    private func navigateToStop() {
        guard stop.coordinate != nil else { return }
        
        isNavigating = true
        // Start navigation to stop
        HapticFeedback.shared.impact(style: .medium)
    }
}

// MARK: - Directions View

struct DirectionsView: View {
    @Environment(\.dismiss) private var dismiss
    let stop: AdventureStop
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Directions to \(stop.name ?? stop.chapter)")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .padding()
                
                Spacer()
                
                Text("Directions functionality would be implemented here")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Spacer()
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
        }
    }
}

#Preview {
    AdventureStopDetailView(
        stop: AdventureStop(
            chapter: "Morning Coffee",
            category: .food,
            idealDurationMin: 30,
            narrative: "Start your day with the best coffee in town. This local favorite serves artisanal coffee with a cozy atmosphere perfect for morning conversations.",
            constraints: StopConstraints(
                openLate: false,
                budget: .medium,
                accessibility: true,
                outdoor: false
            ),
            name: "Blue Bottle Coffee",
            address: "123 Main Street, Downtown",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            startHintTimestamp: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
            stayMinutes: 30
        ),
        adventure: AdventurePlan(
            title: "Downtown Food Adventure",
            tagline: "A culinary journey through the heart of the city",
            theme: "Food & Culture",
            mood: .fun,
            durationHours: 3,
            isGroup: false,
            stops: [],
            notes: "Perfect for a weekend morning"
        )
    )
}
