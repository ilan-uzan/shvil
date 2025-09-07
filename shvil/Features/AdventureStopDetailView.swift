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
                AppleColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppleSpacing.lg) {
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
                    .padding(.horizontal, AppleSpacing.lg)
                    .padding(.bottom, AppleSpacing.lg)
                }
            }
            .navigationTitle("Stop Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AppleButton("Close", style: .ghost, size: .small) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showDirections) {
            DirectionsView(stop: stop)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppleSpacing.md) {
            // Stop Number and Category
            HStack {
                // Stop Number
                ZStack {
                    Circle()
                        .fill(AppleColors.brandGradient)
                        .frame(width: 48, height: 48)
                        .appleShadow(AppleShadows.medium)

                    Text("\(stopIndex + 1)")
                        .font(AppleTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    Text(stop.name)
                        .font(AppleTypography.largeTitle)
                        .foregroundColor(AppleColors.textPrimary)

                    Text(stop.category.displayName)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                }

                Spacer()

                // Category Icon
                Image(systemName: stopIcon(for: stop.category))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(AppleColors.brandPrimary)
            }

            // Duration
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.textSecondary)

                Text("\(stop.estimatedDuration) minutes")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)

                Spacer()

                Text("Stay: \(stop.estimatedDuration) min")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.brandPrimary)
                    .padding(.horizontal, AppleSpacing.sm)
                    .padding(.vertical, AppleSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                            .fill(AppleColors.surfaceSecondary)
                    )
            }
        }
        .padding(.vertical, AppleSpacing.lg)
    }

    private var stopIndex: Int {
        adventure.stops.firstIndex(where: { $0.id == stop.id }) ?? 0
    }

    private func stopIcon(for category: StopCategory) -> String {
        switch category {
        case .restaurant: "star"
        case .attraction: "building"
        case .food: "fork.knife"
        case .nature: "camera"
        case .museum: "building.columns"
        case .restaurant: "figure.run"
        case .restaurant: "moon.stars"
        case .restaurant: "star"
        case .shopping: "bag"
        case .entertainment: "tv"
        case .culture: "wrench.and.screwdriver"
        case .other: "car"
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            Text("Location")
                .font(AppleTypography.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppleColors.textPrimary)

            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: stop.location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [stop]) { stop in
                MapAnnotation(coordinate: stop.location.coordinate) {
                        ZStack {
                            Circle()
                                .fill(AppleColors.brandGradient)
                                .frame(width: 32, height: 32)
                                .appleShadow(AppleShadows.light)

                            Image(systemName: stopIcon(for: stop.category))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                    }
                }
                .frame(height: 200)
                .cornerRadius(AppleCornerRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
                .appleShadow(AppleShadows.light)
        }
    }

    // MARK: - Stop Info Section

    private var stopInfoSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Place Information")
                    .font(AppleTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                    Text("Place Name")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)

                    Text(stop.name)
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)
                }

                if false { // openingHours not available
                    VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                        Text("Opening Hours")
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)

                        Text("Not available")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                    }
                }

                if false { // rating not available
                    VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                        Text("Rating")
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)

                        HStack(spacing: AppleSpacing.xs) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < 3 ? "star.fill" : "star") // Default rating
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12))
                            }
                            Text("3.0") // Default rating
                                .font(AppleTypography.body)
                                .foregroundColor(AppleColors.textPrimary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Narrative Section

    private var narrativeSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("What to Expect")
                    .font(AppleTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppleColors.textPrimary)

                Text(stop.description ?? "No description available")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textPrimary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Constraints Section

    private var constraintsSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Details")
                    .font(AppleTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(spacing: AppleSpacing.md) {
                    // Budget
                    constraintRow(
                        icon: "dollarsign.circle",
                        title: "Budget",
                        value: "Not available"
                    )

                    // Accessibility
                    constraintRow(
                        icon: "figure.roll",
                        title: "Accessibility",
                        value: "Not available"
                    )

                    // Tags
                    if false { // tags not available
                        constraintRow(
                            icon: "tag",
                            title: "Tags",
                            value: "Not available"
                        )
                    }
                }
            }
        }
    }

    private func constraintRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: AppleSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppleColors.brandPrimary)
                .frame(width: 20)

            Text(title)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textSecondary)

            Spacer()

            Text(value)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textPrimary)
        }
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: AppleSpacing.md) {
            // Navigate Button
            AppleButton(
                "Navigate Here",
                icon: "location.fill",
                style: .primary,
                size: .large
            ) {
                navigateToStop()
            }

            // Directions Button
            AppleButton(
                "Get Directions",
                icon: "map",
                style: .secondary,
                size: .large
            ) {
                showDirections = true
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
                    .font(AppleTypography.title2)
                    .foregroundColor(AppleColors.textPrimary)
                    .padding()

                Spacer()

                Text("Directions functionality would be implemented here")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)

                Spacer()
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppleColors.textPrimary)
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
            location: LocationData(
                latitude: 37.7749,
                longitude: -122.4194,
                address: "66 Mint St, San Francisco, CA 94103"
            ),
            category: .food,
            estimatedDuration: 30
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
