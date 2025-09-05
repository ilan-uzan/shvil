//
//  PlaceDetailsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct PlaceDetailsView: View {
    let place: SearchResult
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
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }

            // Modal content
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Header section
                    headerSection

                    // Primary actions row
                    primaryActionsRow

                    // Content sections
                    contentSections
                }
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                .stroke(AppleColors.glassLight, lineWidth: 1)
                        )
                        .appleShadow(AppleShadows.heavy)
                )
                .padding(.horizontal, 16) // 16pt from edges
                .padding(.bottom, 16) // 16pt from edges
            }
        }
        .animation(reduceMotion ? .none : AppleAnimations.complex, value: isPresented)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(AppleColors.textTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, AppleSpacing.sm)
                .padding(.bottom, AppleSpacing.sm)

            HStack(spacing: 16) {
                // Place info
                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    Text(place.name)
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(2)

                    if let subtitle = place.subtitle {
                        Text(subtitle)
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)
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
                        .foregroundColor(AppleColors.textSecondary)
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
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                            .fill(AppleColors.accent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                                    .stroke(AppleColors.accent, lineWidth: 1)
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
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            HStack {
                Image(systemName: "location")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 20)

                Text("Address")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)

                Spacer()
            }

            Text(place.address ?? "Address not available")
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, AppleSpacing.md)
        .padding(.horizontal, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                .fill(AppleColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
        )
        .accessibilityLabel("Address: \(place.address ?? "Address not available")")
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            HStack {
                Image(systemName: "phone")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 20)

                Text("Contact")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                // Phone number (placeholder)
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.textSecondary)
                        .frame(width: 16)

                    Text("(555) 123-4567")
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)

                    Spacer()
                }

                // Website (placeholder)
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.textSecondary)
                        .frame(width: 16)

                    Text("www.example.com")
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.accent)

                    Spacer()
                }
            }
        }
        .padding(.vertical, AppleSpacing.md)
        .padding(.horizontal, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                .fill(AppleColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
        )
        .accessibilityLabel("Contact information")
    }

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 20)

                Text("Hours")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                Text("Monday - Friday: 9:00 AM - 6:00 PM")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)

                Text("Saturday: 10:00 AM - 4:00 PM")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)

                Text("Sunday: Closed")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
            }
        }
        .padding(.vertical, AppleSpacing.md)
        .padding(.horizontal, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                .fill(AppleColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
        )
        .accessibilityLabel("Business hours")
    }

    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 20)

                Text("Details")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                Text("This is a sample place with additional details that would typically include amenities, reviews, and other relevant information.")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, AppleSpacing.md)
        .padding(.horizontal, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                .fill(AppleColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                        .stroke(AppleColors.glassLight, lineWidth: 1)
                )
        )
        .accessibilityLabel("Additional details")
    }

    // MARK: - Helper Functions

    private func dismissModal() {
        withAnimation(reduceMotion ? .none : AppleAnimations.standard) {
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
                guard let currentLocation = DependencyContainer.shared.locationService.currentLocation else {
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
                    to: place.coordinate,
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
                name: place.name,
                address: place.address ?? "Unknown Address",
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude,
                type: .custom, // Default type
                createdAt: Date(),
                userId: UUID() // TODO: Use actual user ID
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

// MARK: - Preview

#Preview {
    PlaceDetailsView(
        place: SearchResult(
            name: "Sample Restaurant",
            subtitle: "Italian Cuisine",
            address: "123 Main Street, San Francisco, CA 94102",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        ),
        isPresented: .constant(true)
    )
    .background(Color.black)
}
