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
    @StateObject private var locationManager = DependencyContainer.shared.locationManager

    let stop: AdventureStop
    let adventure: AdventurePlan

    @State private var isNavigating = false
    @State private var showDirections = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DesignTokens.Surface.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.lg) {
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
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.lg)
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
        VStack(spacing: DesignTokens.Spacing.md) {
            // Stop Number and Category
            HStack {
                // Stop Number
                ZStack {
                    Circle()
                        .fill(DesignTokens.Brand.gradient)
                        .frame(width: 48, height: 48)
                        .appleShadow(DesignTokens.Shadow.medium)

                    Text("\(stopIndex + 1)")
                        .font(AppleTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(stop.name)
                        .font(AppleTypography.largeTitle)
                        .foregroundColor(DesignTokens.Text.primary)

                    Text(stop.category.displayName)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                }

                Spacer()

                // Category Icon
                Image(systemName: stopIcon(for: stop.category))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
            }

            // Duration
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)

                Text("\(stop.estimatedDuration) minutes")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)

                Spacer()

                Text("Stay: \(stop.estimatedDuration) min")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Brand.primary)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .fill(DesignTokens.Surface.secondary)
                    )
            }
        }
        .padding(.vertical, DesignTokens.Spacing.lg)
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Location")
                .font(DesignTokens.Typography.title3)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Text.primary)

            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: stop.location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [stop]) { stop in
                MapAnnotation(coordinate: stop.location.coordinate) {
                        ZStack {
                            Circle()
                                .fill(DesignTokens.Brand.gradient)
                                .frame(width: 32, height: 32)
                                .appleShadow(DesignTokens.Shadow.light)

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
                .cornerRadius(DesignTokens.CornerRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
                .appleShadow(DesignTokens.Shadow.light)
        }
    }

    // MARK: - Stop Info Section

    private var stopInfoSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Place Information")
                    .font(DesignTokens.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Text.primary)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Place Name")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)

                    Text(stop.name)
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(DesignTokens.Text.primary)
                }

                if false { // openingHours not available
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Opening Hours")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)

                        Text("Not available")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                    }
                }

                if false { // rating not available
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Rating")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)

                        HStack(spacing: DesignTokens.Spacing.xs) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < 3 ? "star.fill" : "star") // Default rating
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12))
                            }
                            Text("3.0") // Default rating
                                .font(DesignTokens.Typography.body)
                                .foregroundColor(DesignTokens.Text.primary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Narrative Section

    private var narrativeSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("What to Expect")
                    .font(DesignTokens.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Text.primary)

                Text(stop.description ?? "No description available")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.primary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Constraints Section

    private var constraintsSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Details")
                    .font(DesignTokens.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Text.primary)

                VStack(spacing: DesignTokens.Spacing.md) {
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
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.Brand.primary)
                .frame(width: 20)

            Text(title)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)

            Spacer()

            Text(value)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
        }
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
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
                    .font(DesignTokens.Typography.title2)
                    .foregroundColor(DesignTokens.Text.primary)
                    .padding()

                Spacer()

                Text("Directions functionality would be implemented here")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)

                Spacer()
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Text.primary)
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
