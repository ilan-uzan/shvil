//
//  AdventureSheetView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct AdventureSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adventureKit = DependencyContainer.shared.adventureKit
    @StateObject private var mapEngine = DependencyContainer.shared.mapEngine
    @StateObject private var locationManager = DependencyContainer.shared.locationManager

    @State private var selectedStop: AdventureStop?
    @State private var showStopDetails = false
    @State private var currentStopIndex = 0
    @State private var isNavigating = false

    let adventure: AdventurePlan

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DesignTokens.Surface.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Map
                    mapSection

                    // Bottom Sheet
                    bottomSheet
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showStopDetails) {
            if let stop = selectedStop {
                AdventureStopDetailView(stop: stop, adventure: adventure)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignTokens.Text.tertiary)
                .frame(width: 36, height: 4)
                .padding(.top, DesignTokens.Spacing.sm)

            HStack(spacing: DesignTokens.Spacing.md) {
                // Close Button
                AppleButton(
                    "",
                    icon: "xmark",
                    style: .ghost,
                    size: .small
                ) {
                    dismiss()
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(adventure.title)
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(1)

                    Text(adventure.description)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Status Badge
                statusBadge
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                .fill(DesignTokens.Surface.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
                .appleShadow(DesignTokens.Shadow.medium)
        )
    }

    private var statusBadge: some View {
        Text(adventure.status.displayName)
            .font(AppleTypography.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(statusColor)
            )
    }

    private var statusColor: Color {
        switch adventure.status {
        case .draft: DesignTokens.Text.tertiary
        case .active: DesignTokens.Brand.primary
        case .completed: DesignTokens.Semantic.success
        case .cancelled: DesignTokens.Semantic.error
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        GeometryReader { geometry in
            Map(coordinateRegion: .constant(mapRegion), annotationItems: adventure.stops) { stop in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: stop.location.latitude, longitude: stop.location.longitude)) {
                    adventureStopAnnotation(for: stop)
                }
            }
            .frame(height: geometry.size.height)
            .cornerRadius(0)
        }
    }

    private var mapRegion: MKCoordinateRegion {
        guard let firstStop = adventure.stops.first else {
            return MKCoordinateRegion(
                center: locationManager.currentLocation?.coordinate ?? CLLocationCoordinate2D(),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: firstStop.location.latitude, longitude: firstStop.location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private func adventureStopAnnotation(for stop: AdventureStop) -> some View {
        Button(action: {
            selectedStop = stop
            showStopDetails = true
            HapticFeedback.shared.impact(style: .light)
        }) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Brand.gradient)
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
        case .other: "wrench.and.screwdriver"
        case .culture: "car"
        }
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignTokens.Text.secondary)
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            // Content
            VStack(spacing: 20) {
                // Adventure Info
                adventureInfoSection

                // Stops List
                stopsListSection

                // Action Buttons
                actionButtonsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignTokens.Surface.tertiary)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    private var adventureInfoSection: some View {
        HStack(spacing: 16) {
            // Mood
            VStack(spacing: 4) {
                Image(systemName: moodIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)

                Text(adventure.theme.displayName)
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }

            Divider()
                .frame(height: 40)

            // Duration
            VStack(spacing: 4) {
                Text("\(adventure.totalDuration / 60)h")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(DesignTokens.Text.primary)

                Text("Duration")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }

            Divider()
                .frame(height: 40)

            // Stops Count
            VStack(spacing: 4) {
                Text("\(adventure.stops.count)")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(DesignTokens.Text.primary)

                Text("Stops")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignTokens.Surface.secondary)
        )
    }

    private var moodIcon: String {
        switch adventure.theme {
        case .fun: "face.smiling"
        case .relaxing: "leaf"
        case .cultural: "building.columns"
        case .adventurous: "heart"
        case .adventurous: "mountain.2"
        }
    }

    private var stopsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adventure Stops")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(adventure.stops.enumerated()), id: \.element.id) { index, stop in
                        stopCard(for: stop, at: index)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func stopCard(for stop: AdventureStop, at index: Int) -> some View {
        Button(action: {
            selectedStop = stop
            showStopDetails = true
            HapticFeedback.shared.impact(style: .light)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Stop Number
                HStack {
                    Text("\(index + 1)")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(DesignTokens.Brand.gradient)
                        )

                    Spacer()

                    Image(systemName: stopIcon(for: stop.category))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(stop.name)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(2)

                    Text(stop.description ?? "No description available")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(1)

                    Text("\(stop.estimatedDuration) min")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Brand.primary)
                }
            }
            .padding(16)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DesignTokens.Surface.secondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Start Adventure Button
            Button(action: startAdventure) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .medium))

                    Text("Start Adventure")
                        .font(DesignTokens.Typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignTokens.Brand.gradient)
                )
            }

            // Share Button
            Button(action: shareAdventure) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignTokens.Surface.secondary)
                    )
            }
        }
    }

    // MARK: - Actions

    private func startAdventure() {
        isNavigating = true
        // Start navigation to first stop
        HapticFeedback.shared.impact(style: .medium)
    }

    private func shareAdventure() {
        // Share adventure
        HapticFeedback.shared.impact(style: .light)
    }
}

#Preview {
    AdventureSheetView(adventure: AdventurePlan(
        title: "Downtown Food Adventure",
        description: "A culinary journey through the heart of the city",
        theme: .fun,
        stops: [
            AdventureStop(
                name: "Blue Bottle Coffee",
                description: "Start your day with the best coffee in town",
                location: LocationData(
                    latitude: 37.7749,
                    longitude: -122.4194,
                    address: "123 Market St, San Francisco, CA"
                ),
                category: .food,
                order: 0,
                estimatedDuration: 1800
            ),
            AdventureStop(
                name: "Modern Art Gallery",
                description: "Explore contemporary art",
                location: LocationData(
                    latitude: 37.7849,
                    longitude: -122.4094,
                    address: "456 Union St, San Francisco, CA"
                ),
                category: .museum,
                order: 1,
                estimatedDuration: 2700
            ),
        ],
        totalDuration: 180,
        totalDistance: 2000,
        budgetLevel: .medium
    ))
}
