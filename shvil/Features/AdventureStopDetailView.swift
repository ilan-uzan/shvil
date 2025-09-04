//
//  AdventureStopDetailView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

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
                    Text(stop.name)
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

                Text("\(stop.estimatedDuration) minutes")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)

                Spacer()

                Text("Stay: \(stop.estimatedDuration) min")
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
        .padding(.vertical, 20)
    }

    private var stopIndex: Int {
        adventure.stops.firstIndex(where: { $0.id == stop.id }) ?? 0
    }

    private func stopIcon(for category: StopCategory) -> String {
        switch category {
        case .all: "star"
        case .landmark: "building"
        case .food: "fork.knife"
        case .scenic: "camera"
        case .museum: "building.columns"
        case .activity: "figure.run"
        case .nightlife: "moon.stars"
        case .hiddenGem: "star"
        case .shopping: "bag"
        case .entertainment: "tv"
        case .services: "wrench.and.screwdriver"
        case .transportation: "car"
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: stop.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [stop]) { stop in
                MapAnnotation(coordinate: stop.coordinate) {
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
        }
    }

    // MARK: - Stop Info Section

    private var stopInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Place Name")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)

                Text(stop.name)
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
            }

            if let openingHours = stop.openingHours {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Opening Hours")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)

                    Text(openingHours)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.primaryText)
                }
            }

            if let rating = stop.rating {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)

                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                        }
                        Text(String(format: "%.1f", rating))
                            .font(LiquidGlassTypography.body)
                            .foregroundColor(LiquidGlassColors.primaryText)
                    }
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

            Text(stop.description)
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
                    value: stop.priceLevel.displayName
                )

                // Accessibility
                constraintRow(
                    icon: "figure.roll",
                    title: "Accessibility",
                    value: stop.isAccessible ? "Wheelchair Accessible" : "Not Accessible"
                )

                // Tags
                if !stop.tags.isEmpty {
                    constraintRow(
                        icon: "tag",
                        title: "Tags",
                        value: stop.tags.joined(separator: ", ")
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
                Text("Directions to \(stop.name)")
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
            name: "Blue Bottle Coffee",
            description: "Start your day with the best coffee in town. This local favorite serves artisanal coffee with a cozy atmosphere perfect for morning conversations.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            category: .food,
            estimatedDuration: 30,
            openingHours: "7:00 AM - 6:00 PM",
            priceLevel: .medium,
            rating: 4.5,
            isAccessible: true,
            tags: ["coffee", "breakfast", "cozy"]
        ),
        adventure: AdventurePlan(
            title: "Downtown Food Adventure",
            description: "A culinary journey through the heart of the city",
            theme: .fun,
            stops: [],
            totalDuration: 180,
            totalDistance: 2000,
            budgetLevel: .medium
        )
    )
}
