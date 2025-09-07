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
    @StateObject private var locationService = DependencyContainer.shared.locationService

    @State private var selectedStop: AdventureStop?
    @State private var showStopDetails = false
    @State private var currentStopIndex = 0
    @State private var isNavigating = false

    let adventure: AdventurePlan

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppleColors.background
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
                .fill(AppleColors.textTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, AppleSpacing.sm)

            HStack(spacing: AppleSpacing.md) {
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

                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    Text(adventure.title)
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)

                    Text(adventure.description)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Status Badge
                statusBadge
            }
            .padding(.horizontal, AppleSpacing.lg)
            .padding(.vertical, AppleSpacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xl, style: .continuous)
                .fill(AppleColors.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl, style: .continuous)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
                .appleShadow(AppleShadows.medium)
        )
    }

    private var statusBadge: some View {
        Text(adventure.status.displayName)
            .font(AppleTypography.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, AppleSpacing.sm)
            .padding(.vertical, AppleSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppleCornerRadius.sm)
                    .fill(statusColor)
            )
    }

    private var statusColor: Color {
        switch adventure.status {
        case .draft: AppleColors.textTertiary
        case .active: AppleColors.brandPrimary
        case .completed: AppleColors.success
        case .cancelled: AppleColors.error
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
                center: locationService.currentLocation?.coordinate ?? CLLocationCoordinate2D(),
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
                    .fill(AppleColors.brandGradient)
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
                .fill(AppleColors.textSecondary)
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
                .fill(AppleColors.surfaceTertiary)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    private var adventureInfoSection: some View {
        HStack(spacing: 16) {
            // Mood
            VStack(spacing: 4) {
                Image(systemName: moodIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppleColors.brandPrimary)

                Text(adventure.theme.displayName)
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            Divider()
                .frame(height: 40)

            // Duration
            VStack(spacing: 4) {
                Text("\(adventure.totalDuration / 60)h")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                Text("Duration")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            Divider()
                .frame(height: 40)

            // Stops Count
            VStack(spacing: 4) {
                Text("\(adventure.stops.count)")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                Text("Stops")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppleColors.surfaceSecondary)
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
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

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
                        .font(AppleTypography.caption1)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(AppleColors.brandGradient)
                        )

                    Spacer()

                    Image(systemName: stopIcon(for: stop.category))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppleColors.brandPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(stop.name)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(2)

                    Text(stop.description ?? "No description available")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                        .lineLimit(1)

                    Text("\(stop.estimatedDuration) min")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.brandPrimary)
                }
            }
            .padding(16)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppleColors.surfaceSecondary)
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
                        .font(AppleTypography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppleColors.brandGradient)
                )
            }

            // Share Button
            Button(action: shareAdventure) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppleColors.surfaceSecondary)
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
