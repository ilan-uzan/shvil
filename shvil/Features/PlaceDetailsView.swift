//
//  PlaceDetailsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct PlaceDetailsView: View {
    let place: SearchResult
    @Binding var isPresented: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
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
                    RoundedRectangle(cornerRadius: 24) // 24pt corner radius for modal
                        .fill(LiquidGlassColors.glassSurface2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.2), lineWidth: 2) // 2pt highlight edge
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8) // Soft outer shadow
                )
                .padding(.horizontal, 16) // 16pt from edges
                .padding(.bottom, 16) // 16pt from edges
            }
        }
        .animation(reduceMotion ? .none : LiquidGlassAnimations.pourAnimation, value: isPresented) // Pour animation ≤600ms
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(LiquidGlassColors.secondaryText.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            HStack(spacing: 16) {
                // Place info
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(LiquidGlassTypography.title) // Title typography
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(2)
                    
                    if let subtitle = place.subtitle {
                        Text(subtitle)
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
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
                        .foregroundColor(LiquidGlassColors.secondaryText)
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
            Button(action: {
                // TODO: Implement route to place
                print("Route to \(place.name)")
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Route")
                        .font(LiquidGlassTypography.bodySemibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassGradients.primaryGradient)
                )
            }
            .accessibilityLabel("Route to \(place.name)")
            .accessibilityHint("Double tap to get directions to this place")
            
            // Save button
            Button(action: {
                // TODO: Implement save place
                print("Save \(place.name)")
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Save")
                        .font(LiquidGlassTypography.bodySemibold)
                }
                .foregroundColor(LiquidGlassColors.accentText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassColors.accentText.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(LiquidGlassColors.accentText, lineWidth: 2)
                        )
                )
            }
            .accessibilityLabel("Save \(place.name)")
            .accessibilityHint("Double tap to save this place to your favorites")
            
            // Share button
            Button(action: {
                // TODO: Implement share place
                print("Share \(place.name)")
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LiquidGlassColors.accentText.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(LiquidGlassColors.accentText, lineWidth: 2)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location")
                    .font(.system(size: 16))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 20)
                
                Text("Address")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
            }
            
            Text(place.address ?? "Address not available")
                .font(LiquidGlassTypography.body)
                .foregroundColor(LiquidGlassColors.secondaryText)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                )
        )
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "phone")
                    .font(.system(size: 16))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 20)
                
                Text("Contact")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Phone number (placeholder)
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .frame(width: 16)
                    
                    Text("(555) 123-4567")
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Spacer()
                }
                
                // Website (placeholder)
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .frame(width: 16)
                    
                    Text("www.example.com")
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.accentText)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                )
        )
    }
    
    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 20)
                
                Text("Hours")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Monday - Friday: 9:00 AM - 6:00 PM")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text("Saturday: 10:00 AM - 4:00 PM")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text("Sunday: Closed")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                )
        )
    }
    
    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 20)
                
                Text("Details")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("This is a sample place with additional details that would typically include amenities, reviews, and other relevant information.")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LiquidGlassColors.glassSurface3, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    
    private func dismissModal() {
        withAnimation(reduceMotion ? .none : LiquidGlassAnimations.standard) {
            isPresented = false
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
