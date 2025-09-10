//
//  PlaceDetailsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct PlaceDetailsView: View {
    let place: shvil.SearchResult
    @Binding var isPresented: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Services
    @StateObject private var routingService = DependencyContainer.shared.routingEngine
    @StateObject private var persistence = DependencyContainer.shared.persistence
    @StateObject private var hapticFeedback = DependencyContainer.shared.hapticFeedback
    
    // State
    @State private var isRouting = false
    @State private var isSaving = false
    @State private var isSaved = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Background overlay with Landmarks-style blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }

            // Modal content with flexible header
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Header section with flexible header content
                    headerSection
                        .flexibleHeaderContent()

                    // Primary actions row
                    primaryActionsRow

                    // Content sections with scroll view
                    ScrollView {
                        contentSections
                    }
                    .flexibleHeaderScrollView()
                }
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.light, lineWidth: 1)
                        )
                        .appleShadow(DesignTokens.Shadow.heavy)
                )
                .padding(.horizontal, 16) // 16pt from edges
                .padding(.bottom, 16) // 16pt from edges
            }
        }
        .animation(reduceMotion ? .none : DesignTokens.Animation.complex, value: isPresented)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignTokens.Text.tertiary)
                .frame(width: 36, height: 4)
                .padding(.top, DesignTokens.Spacing.sm)
                .padding(.bottom, DesignTokens.Spacing.sm)

            HStack(spacing: 16) {
                // Place info
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(place.name)
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(2)

                    if false { // subtitle not available
                        Text("Not available")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Close button
                Button(action: {
                    dismissModal()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignTokens.Text.secondary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Close")
                .accessibilityHint("Double tap to close place details")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Primary Actions Row

    private var primaryActionsRow: some View {
        HStack(spacing: 12) {
            // Route button
            AppleButton(
                "Route",
                icon: "arrow.triangle.turn.up.right.diamond",
                style: .primary,
                size: .medium,
                isLoading: isRouting,
                isDisabled: isRouting
            ) {
                routeToPlace()
            }
            .accessibilityLabel("Route to \(place.name)")
            .accessibilityHint("Double tap to get directions to this place")

            // Save button
            AppleButton(
                isSaved ? "Saved" : "Save",
                icon: isSaved ? "bookmark.fill" : "bookmark",
                style: isSaved ? .secondary : .ghost,
                size: .medium,
                isLoading: isSaving,
                isDisabled: isSaving || isSaved
            ) {
                savePlace()
            }
            .accessibilityLabel(isSaved ? "\(place.name) is saved" : "Save \(place.name)")
            .accessibilityHint(isSaved ? "This place is already saved" : "Double tap to save this place to your favorites")

            // Share button
            Button(action: {
                // TODO: Implement share place
                print("Share \(place.name)")
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .fill(DesignTokens.Brand.primary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                                    .stroke(DesignTokens.Brand.primary, lineWidth: 1)
                            )
                    )
            }
            .accessibilityLabel("Share \(place.name)")
            .accessibilityHint("Double tap to share this place")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Content Sections

    private var contentSections: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Address section
                addressSection

                // Contact section
                contactSection

                // Hours section
                hoursSection

                // Additional details
                additionalDetailsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: "location")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 20)

                Text("Address")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)

                Spacer()
            }

            Text(place.address ?? "Address not available")
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(DesignTokens.Glass.light)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .accessibilityLabel("Address: \(place.address ?? "Address not available")")
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: "phone")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 20)

                Text("Contact")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                // Phone number (placeholder)
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary)
                        .frame(width: 16)

                    Text("(555) 123-4567")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)

                    Spacer()
                }

                // Website (placeholder)
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary)
                        .frame(width: 16)

                    Text("www.example.com")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Brand.primary)

                    Spacer()
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(DesignTokens.Glass.light)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .accessibilityLabel("Contact information")
    }

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 20)

                Text("Hours")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Monday - Friday: 9:00 AM - 6:00 PM")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)

                Text("Saturday: 10:00 AM - 4:00 PM")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)

                Text("Sunday: Closed")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(DesignTokens.Glass.light)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .accessibilityLabel("Business hours")
    }

    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 20)

                Text("Details")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Additional details about this place including amenities, reviews, and other relevant information.")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(DesignTokens.Glass.light)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .accessibilityLabel("Additional details")
    }

    // MARK: - Helper Functions

    private func dismissModal() {
        withAnimation(reduceMotion ? .none : DesignTokens.Animation.standard) {
            isPresented = false
        }
    }
    
    // MARK: - Action Methods
    
    private func routeToPlace() {
        isRouting = true
        hapticFeedback.impact(style: .medium)
        
        Task {
            do {
                // Get current location
                guard let currentLocation = DependencyContainer.shared.locationManager.currentLocation else {
                    await MainActor.run {
                        errorMessage = "Location not available"
                        showError = true
                        isRouting = false
                    }
                    return
                }
                
                // Calculate route
                routingService.calculateRoute(
                    from: currentLocation.coordinate,
                    to: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                    transportType: .automobile
                )
                
                await MainActor.run {
                    isRouting = false
                    // TODO: Navigate to route view
                    print("Route calculated successfully")
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to calculate route: \(error.localizedDescription)"
                    showError = true
                    isRouting = false
                }
            }
        }
    }
    
    private func savePlace() {
        isSaving = true
        hapticFeedback.impact(style: .light)
        
        Task {
            // Save to persistence
            let savedPlace = SavedPlace(
                id: UUID(),
                userId: UUID(), // TODO: Use actual user ID
                name: place.name,
                address: place.address ?? "Unknown Address",
                latitude: place.latitude,
                longitude: place.longitude,
                placeType: .other, // Use valid case
                createdAt: Date(),
                updatedAt: Date()
            )
            await persistence.savePlace(savedPlace)
            
            await MainActor.run {
                isSaved = true
                isSaving = false
                hapticFeedback.success()
            }
        }
    }
}

// MARK: - #Preview

#Preview {
    PlaceDetailsView(
        place: SearchResult(
            name: "Restaurant",
            address: "123 Main Street, San Francisco, CA 94102",
            latitude: 37.7749,
            longitude: -122.4194,
            category: "restaurant"
        ),
        isPresented: .constant(true)
    )
    .background(Color.black)
}
