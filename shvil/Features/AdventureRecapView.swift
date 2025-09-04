//
//  AdventureRecapView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct AdventureRecapView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adventureKit = DependencyContainer.shared.adventureKit

    let adventure: AdventurePlan
    @State private var showShareSheet = false
    @State private var showRating = false
    @State private var userRating = 0

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

                        // Stats
                        statsSection

                        // Map
                        mapSection

                        // Stops Summary
                        stopsSummarySection

                        // Rating Section
                        ratingSection

                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Adventure Complete")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [adventureShareText])
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 20) {
            // Success Icon
            ZStack {
                Circle()
                    .fill(LiquidGlassGradients.primaryGradient)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("Adventure Complete!")
                    .font(LiquidGlassTypography.titleXL)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .multilineTextAlignment(.center)

                Text(adventure.title)
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)
                    .multilineTextAlignment(.center)

                Text("You've successfully completed your \(adventure.theme.displayName.lowercased()) adventure!")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Your Adventure Stats")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            HStack(spacing: 20) {
                // Duration
                statCard(
                    icon: "clock.fill",
                    title: "Duration",
                    value: "\(adventure.totalDuration / 60)h",
                    color: LiquidGlassColors.accentDeepAqua
                )

                // Stops
                statCard(
                    icon: "location.fill",
                    title: "Stops",
                    value: "\(adventure.stops.count)",
                    color: .green
                )

                // Distance
                statCard(
                    icon: "figure.walk",
                    title: "Distance",
                    value: "2.3 mi",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }

    private func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)

            Text(value)
                .font(LiquidGlassTypography.titleXL)
                .fontWeight(.bold)
                .foregroundColor(LiquidGlassColors.primaryText)

            Text(title)
                .font(LiquidGlassTypography.caption)
                .foregroundColor(LiquidGlassColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Journey")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            Map(coordinateRegion: .constant(mapRegion), annotationItems: adventure.stops) { stop in
                MapAnnotation(coordinate: stop.coordinate) {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 32, height: 32)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
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

    private var mapRegion: MKCoordinateRegion {
        guard let firstStop = adventure.stops.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        return MKCoordinateRegion(
            center: firstStop.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    // MARK: - Stops Summary Section

    private var stopsSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stops Visited")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            VStack(spacing: 12) {
                ForEach(Array(adventure.stops.enumerated()), id: \.element.id) { index, stop in
                    stopSummaryRow(for: stop, at: index)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }

    private func stopSummaryRow(for stop: AdventureStop, at index: Int) -> some View {
        HStack(spacing: 12) {
            // Stop Number
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 32, height: 32)

                Text("\(index + 1)")
                    .font(LiquidGlassTypography.bodyMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(stop.name)
                    .font(LiquidGlassTypography.bodyMedium)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text(stop.description)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }

            Spacer()

            // Category Icon
            Image(systemName: stopIcon(for: stop.category))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(LiquidGlassColors.accentDeepAqua)
        }
        .padding(.vertical, 8)
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

    // MARK: - Rating Section

    private var ratingSection: some View {
        VStack(spacing: 16) {
            Text("How was your adventure?")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            HStack(spacing: 8) {
                ForEach(1 ... 5, id: \.self) { rating in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            userRating = rating
                        }
                        HapticFeedback.shared.impact(style: .light)
                    }) {
                        Image(systemName: rating <= userRating ? "star.fill" : "star")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(rating <= userRating ? .yellow : LiquidGlassColors.secondaryText)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if userRating > 0 {
                Text(ratingText)
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }

    private var ratingText: String {
        switch userRating {
        case 1: "We're sorry it wasn't great. We'll do better next time!"
        case 2: "Thanks for the feedback. We're always improving!"
        case 3: "Glad you had a decent time. Thanks for trying Shvil!"
        case 4: "Awesome! We're so glad you enjoyed your adventure!"
        case 5: "Fantastic! We're thrilled you loved your adventure!"
        default: ""
        }
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Share Button
            Button(action: { showShareSheet = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))

                    Text("Share Adventure")
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

            // Create Another Button
            Button(action: createAnotherAdventure) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16, weight: .medium))

                    Text("Create Another Adventure")
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

    private var adventureShareText: String {
        """
        🎉 I just completed an amazing adventure with Shvil!

        \(adventure.title)
        \(adventure.description)

        \(adventure.stops.count) stops • \(adventure.totalDuration / 60) hours • \(adventure.theme.displayName)

        Download Shvil to create your own adventures!
        """
    }

    // MARK: - Actions

    private func createAnotherAdventure() {
        // Navigate to adventure setup
        HapticFeedback.shared.impact(style: .medium)
        dismiss()
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    AdventureRecapView(adventure: AdventurePlan(
        title: "Downtown Food Adventure",
        description: "A culinary journey through the heart of the city",
        theme: .fun,
        stops: [
            AdventureStop(
                name: "Blue Bottle Coffee",
                description: "Start your day with the best coffee in town",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                category: .food,
                estimatedDuration: 30,
                openingHours: "7:00 AM - 6:00 PM",
                priceLevel: .medium,
                rating: 4.5,
                isAccessible: true,
                tags: ["coffee", "breakfast"]
            ),
            AdventureStop(
                name: "Modern Art Gallery",
                description: "Explore contemporary art",
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                category: .museum,
                estimatedDuration: 45,
                openingHours: "10:00 AM - 6:00 PM",
                priceLevel: .high,
                rating: 4.2,
                isAccessible: true,
                tags: ["art", "culture"]
            ),
        ],
        totalDuration: 180,
        totalDistance: 2000,
        budgetLevel: .medium
    ))
}
