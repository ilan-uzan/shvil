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
                LiquidGlassColors.background
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
                .fill(LiquidGlassColors.secondaryText)
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            HStack(spacing: 16) {
                // Close Button
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(LiquidGlassColors.glassSurface1)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(adventure.title)
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)

                    Text(adventure.tagline)
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                // Status Badge
                statusBadge
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LiquidGlassColors.glassSurface1)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(adventure.status.displayName)
                .font(LiquidGlassTypography.caption)
                .foregroundColor(LiquidGlassColors.primaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LiquidGlassColors.glassSurface2)
        )
    }

    private var statusColor: Color {
        switch adventure.status {
        case .draft: LiquidGlassColors.secondaryText
        case .active: LiquidGlassColors.accentDeepAqua
        case .completed: .green
        case .cancelled: .red
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
        guard let firstStop = adventure.stops.first,
              let coordinate = firstStop.coordinate
        else {
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
        Button(action: {
            selectedStop = stop
            showStopDetails = true
            HapticFeedback.shared.impact(style: .light)
        }) {
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

    private func stopIcon(for category: StopCategory) -> String {
        switch category {
        case .landmark: "building"
        case .food: "fork.knife"
        case .scenic: "camera"
        case .museum: "building.columns"
        case .activity: "figure.run"
        case .nightlife: "moon.stars"
        case .hiddenGem: "star"
        }
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(LiquidGlassColors.secondaryText)
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
                .fill(LiquidGlassColors.glassSurface1)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    private var adventureInfoSection: some View {
        HStack(spacing: 16) {
            // Mood
            VStack(spacing: 4) {
                Image(systemName: moodIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)

                Text(adventure.mood.displayName)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }

            Divider()
                .frame(height: 40)

            // Duration
            VStack(spacing: 4) {
                Text("\(adventure.durationHours)h")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text("Duration")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }

            Divider()
                .frame(height: 40)

            // Stops Count
            VStack(spacing: 4) {
                Text("\(adventure.stops.count)")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text("Stops")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface2)
        )
    }

    private var moodIcon: String {
        switch adventure.mood {
        case .fun: "face.smiling"
        case .relaxing: "leaf"
        case .cultural: "building.columns"
        case .romantic: "heart"
        case .adventurous: "mountain.2"
        }
    }

    private var stopsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adventure Stops")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

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
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(LiquidGlassGradients.primaryGradient)
                        )

                    Spacer()

                    Image(systemName: stopIcon(for: stop.category))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(stop.chapter)
                        .font(LiquidGlassTypography.bodyMedium)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(2)

                    if let name = stop.name {
                        Text(name)
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                            .lineLimit(1)
                    }

                    Text("\(stop.idealDurationMin) min")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                }
            }
            .padding(16)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassColors.glassSurface2)
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

            // Share Button
            Button(action: shareAdventure) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LiquidGlassColors.glassSurface2)
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
                address: "123 Main St"
            ),
            AdventureStop(
                chapter: "Art Gallery",
                category: .museum,
                idealDurationMin: 45,
                narrative: "Explore contemporary art",
                constraints: StopConstraints(),
                name: "Modern Art Gallery",
                address: "456 Art Ave"
            ),
        ],
        notes: "Perfect for a weekend morning"
    ))
}
