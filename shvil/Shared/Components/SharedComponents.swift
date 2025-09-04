//
//  SharedComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                    )
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(LiquidGlassDesign.Typography.caption)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Saved Place Card
struct SavedPlaceCard: View {
    let place: SavedPlace
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(color: categoryColor.opacity(0.3), radius: 6, x: 0, y: 3)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(LiquidGlassDesign.Typography.headline)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .lineLimit(1)
                    
                    if let address = place.address {
                        Text(address)
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        if let distance = place.distance {
                            Label(distance, systemImage: "location")
                                .font(LiquidGlassDesign.Typography.caption)
                                .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(place.category)
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                            .padding(.horizontal, LiquidGlassDesign.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(LiquidGlassDesign.Colors.glassMedium)
                            )
                    }
                }
                
                Spacer()
                
                // Action Button
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryColor: Color {
        switch place.category.lowercased() {
        case "home": return LiquidGlassDesign.Colors.accentGreen
        case "work": return LiquidGlassDesign.Colors.accentOrange
        case "favorites": return LiquidGlassDesign.Colors.accentRed
        default: return LiquidGlassDesign.Colors.liquidBlue
        }
    }
    
    private var categoryIcon: String {
        switch place.category.lowercased() {
        case "home": return "house.fill"
        case "work": return "briefcase.fill"
        case "favorites": return "heart.fill"
        default: return "location.fill"
        }
    }
}

// MARK: - Settings Row
// Note: SettingsRow is already defined in LiquidGlassProfileView.swift

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
            Text(title)
                .font(LiquidGlassDesign.Typography.headline)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            
            content
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        QuickActionCard(
            icon: "house.fill",
            title: "Home",
            subtitle: "Set your home address",
            color: LiquidGlassDesign.Colors.liquidBlue
        ) {
            // Action
        }
        
        SavedPlaceCard(
            place: SavedPlace(
                id: UUID(),
                name: "Home",
                address: "123 Main Street, City",
                category: "Home",
                emoji: "🏠",
                coordinate: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
                distance: "2.3 mi",
                createdAt: Date(),
                updatedAt: Date()
            )
        ) {
            // Action
        }
        
        SettingsRow(
            icon: "car.fill",
            title: "Transport Mode",
            subtitle: "Car",
            color: LiquidGlassDesign.Colors.liquidBlue
        ) {
            // Action
        }
    }
    .padding()
    .background(LiquidGlassDesign.Colors.backgroundPrimary)
}
