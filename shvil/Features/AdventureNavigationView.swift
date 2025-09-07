//
//  AdventureNavigationView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

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
            AppleColors.background
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
            Button("Cancel", role: .cancel) {}
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
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)

                Spacer()

                AppleButton(
                    "",
                    icon: "xmark",
                    style: .ghost,
                    size: .small
                ) {
                    showExitConfirmation = true
                }
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, AppleSpacing.lg)
            .padding(.top, AppleSpacing.sm)

            // Progress Bar
            progressBar

            // Current Stop Info
            if let stop = currentStop {
                currentStopInfo(for: stop)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppleColors.surfaceTertiary)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    private var progressBar: some View {
        HStack(spacing: AppleSpacing.sm) {
            ForEach(0 ..< adventure.stops.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStopIndex ? AppleColors.brandPrimary : AppleColors.surfaceTertiary)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.vertical, AppleSpacing.sm)
    }

    private func currentStopInfo(for stop: AdventureStop) -> some View {
        HStack(spacing: AppleSpacing.md) {
            // Stop Number
            ZStack {
                Circle()
                    .fill(AppleColors.brandGradient)
                    .frame(width: 40, height: 40)
                    .appleShadow(AppleShadows.light)

                Text("\(currentStopIndex + 1)")
                    .font(AppleTypography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                Text(stop.name)
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
                    .lineLimit(1)

                Text(stop.description ?? "No description available")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Category Icon
            Image(systemName: stopIcon(for: stop.category))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppleColors.brandPrimary)
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.bottom, AppleSpacing.md)
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
        case .other: "star"
        case .shopping: "bag"
        case .entertainment: "tv"
        case .other: "wrench.and.screwdriver"
        case .culture: "car"
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        GeometryReader { geometry in
            Map(coordinateRegion: .constant(mapRegion), annotationItems: adventure.stops) { stop in
                MapAnnotation(coordinate: stop.location.coordinate) {
                    adventureStopAnnotation(for: stop)
                }
            }
            .frame(height: geometry.size.height)
            .cornerRadius(0)
        }
    }

    private var mapRegion: MKCoordinateRegion {
        guard let currentStop = currentStop else {
            return MKCoordinateRegion(
                center: locationService.currentLocation?.coordinate ?? CLLocationCoordinate2D(),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        return MKCoordinateRegion(
            center: currentStop.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private func adventureStopAnnotation(for stop: AdventureStop) -> some View {
        let isCurrentStop = stop.id == currentStop?.id
        let isCompleted = adventure.stops.firstIndex(where: { $0.id == stop.id }) ?? 0 < currentStopIndex

        return ZStack {
            Circle()
                .fill(isCurrentStop ? AnyShapeStyle(AppleColors.brandGradient) :
                    isCompleted ? AnyShapeStyle(Color.green) : AnyShapeStyle(AppleColors.surfaceSecondary))
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
                .fill(AppleColors.textSecondary)
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            VStack(spacing: 20) {
                // Navigation Info
                navigationInfoSection

                // Action Buttons
                actionButtonsSection

                // Next Stop Preview
                if let nextStop {
                    nextStopPreview(for: nextStop)
                }
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

    private var navigationInfoSection: some View {
        HStack(spacing: 20) {
            // Distance
            VStack(alignment: .leading, spacing: 4) {
                Text("Distance")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)

                Text("0.5 mi")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
            }

            Divider()
                .frame(height: 40)

            // ETA
            VStack(alignment: .leading, spacing: 4) {
                Text("ETA")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)

                Text("8 min")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
            }

            Divider()
                .frame(height: 40)

            // Duration
            VStack(alignment: .leading, spacing: 4) {
                Text("Stay")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)

                Text("\(currentStop?.estimatedDuration ?? 0) min")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppleColors.surfaceSecondary)
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
                        .font(AppleTypography.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(AppleColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppleColors.surfaceSecondary)
                )
            }

            // Arrived Button
            Button(action: markArrived) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))

                    Text("I'm Here")
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
        }
    }

    private func nextStopPreview(for nextStop: AdventureStop) -> some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                // Next Stop Icon
                ZStack {
                    Circle()
                        .fill(AppleColors.surfaceSecondary)
                        .frame(width: 32, height: 32)

                    Image(systemName: stopIcon(for: nextStop.category))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.brandPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Next: \(nextStop.name)")
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)

                    Text(nextStop.description ?? "No description available")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppleColors.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppleColors.surfaceSecondary)
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
        description: "A culinary journey through the heart of the city",
        theme: .fun,
        stops: [
            AdventureStop(
                name: "Blue Bottle Coffee",
                description: "Start your day with the best coffee in town",
                location: LocationData(
                    latitude: 37.7749,
                    longitude: -122.4194,
                    address: "66 Mint St, San Francisco, CA 94103"
                ),
                category: .food,
                estimatedDuration: 30
            ),
            AdventureStop(
                name: "Modern Art Gallery",
                description: "Explore contemporary art",
                location: LocationData(
                    latitude: 37.7849,
                    longitude: -122.4094,
                    address: "151 3rd St, San Francisco, CA 94103"
                ),
                category: .museum,
                estimatedDuration: 45
            ),
        ],
        totalDuration: 180,
        totalDistance: 2000,
        budgetLevel: .medium
    ))
}
