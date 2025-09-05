//
//  RouteCard.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Glassmorphism route card component
struct RouteCard: View {
    let route: RouteInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Header with route info
                HStack(spacing: 16) {
                    // Route icon
                    routeIcon
                    
                    // Route details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(route.type)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 16) {
                            Text(route.duration)
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                            
                            Text(route.distance)
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppleColors.brandPrimary)
                    }
                }
                
                // Route badges
                if route.isFastest || route.isSafest {
                    routeBadges
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? 
                          AnyShapeStyle(AppleColors.surfaceSecondary) : 
                          AnyShapeStyle(AppleColors.surfaceTertiary))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? 
                                   AppleColors.brandPrimary.opacity(0.3) : 
                                   Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var routeIcon: some View {
        ZStack {
            Circle()
                .fill(AppleColors.surfaceSecondary)
                .frame(width: 40, height: 40)
            
            Image(systemName: "car.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppleColors.brandPrimary)
        }
    }
    
    private var routeBadges: some View {
        HStack(spacing: 8) {
            if route.isFastest {
                badge("bolt.fill", "fastest".localized, AppleColors.brandPrimary)
            }
            
            if route.isSafest {
                badge("shield.fill", "safest".localized, AppleColors.brandPrimary)
            }
        }
    }
    
    private func badge(_ icon: String, _ text: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            
            Text(text)
                .font(AppleTypography.caption2)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color)
        )
    }
}

/// Detailed route card with more information
struct DetailedRouteCard: View {
    let route: Route
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Main content
                HStack(spacing: 16) {
                    // Route icon
                    routeIcon
                    
                    // Route details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(route.name)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                            .lineLimit(1)
                        
                        // Time and distance
                        HStack(spacing: 16) {
                            timeInfo
                            distanceInfo
                        }
                        
                        // Additional info
                        if let tollCost = route.tollCost {
                            tollInfo(tollCost)
                        }
                        
                        if let fuelCost = route.fuelCost {
                            fuelInfo(fuelCost)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppleColors.brandPrimary)
                    }
                }
                .padding(16)
                
                // Route steps preview
                if !route.steps.isEmpty {
                    Divider()
                        .background(AppleColors.surfacePrimary)
                    
                    routeStepsPreview
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? 
                          AnyShapeStyle(AppleColors.surfaceSecondary) : 
                          AnyShapeStyle(AppleColors.surfaceTertiary))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? 
                                   AppleColors.brandPrimary.opacity(0.3) : 
                                   Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var routeIcon: some View {
        ZStack {
            Circle()
                .fill(AppleColors.surfaceSecondary)
                .frame(width: 48, height: 48)
            
            Image(systemName: route.options.transportationMode.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppleColors.brandPrimary)
        }
    }
    
    private var timeInfo: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppleColors.textSecondary)
            
            Text(formatTime(route.expectedTravelTime))
                .font(AppleTypography.caption1)
                .foregroundColor(AppleColors.textSecondary)
        }
    }
    
    private var distanceInfo: some View {
        HStack(spacing: 4) {
            Image(systemName: "location")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppleColors.textSecondary)
            
            Text(formatDistance(route.distance))
                .font(AppleTypography.caption1)
                .foregroundColor(AppleColors.textSecondary)
        }
    }
    
    private func tollInfo(_ cost: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "creditcard")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppleColors.textSecondary)
            
            Text("₪\(String(format: "%.0f", cost))")
                .font(AppleTypography.caption2)
                .foregroundColor(AppleColors.textSecondary)
        }
    }
    
    private func fuelInfo(_ cost: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "fuelpump")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppleColors.textSecondary)
            
            Text("₪\(String(format: "%.0f", cost))")
                .font(AppleTypography.caption2)
                .foregroundColor(AppleColors.textSecondary)
        }
    }
    
    private var routeStepsPreview: some View {
        VStack(spacing: 8) {
            ForEach(Array(route.steps.prefix(3).enumerated()), id: \.offset) { index, step in
                HStack(spacing: 12) {
                    Image(systemName: step.maneuverType.icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppleColors.brandPrimary)
                        .frame(width: 16)
                    
                    Text(step.instruction)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatDistance(step.distance))
                        .font(AppleTypography.caption2)
                        .foregroundColor(AppleColors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            
            if route.steps.count > 3 {
                Text("+ \(route.steps.count - 3) more steps")
                    .font(AppleTypography.caption2)
                    .foregroundColor(AppleColors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

/// Compact route card for lists
struct CompactRouteCard: View {
    let route: RouteInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Route icon
                Image(systemName: "car.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppleColors.brandPrimary)
                    .frame(width: 24)
                
                // Route details
                VStack(alignment: .leading, spacing: 2) {
                    Text(route.type)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Text(route.duration)
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)
                        
                        Text(route.distance)
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppleColors.brandPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          AnyShapeStyle(AppleColors.surfaceSecondary) : 
                          AnyShapeStyle(AppleColors.surfaceTertiary))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? 
                                   AppleColors.brandPrimary.opacity(0.3) : 
                                   Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        RouteCard(
            route: RouteInfo(
                duration: "25 min",
                distance: "12.5 km",
                type: "Fastest Route",
                isFastest: true,
                isSafest: false
            ),
            isSelected: true
        ) {
            print("Route tapped")
        }
        
        DetailedRouteCard(
            route: Route(
                name: "Via Highway 1",
                distance: 12500,
                expectedTravelTime: 1500,
                polyline: [],
                steps: [],
                options: RouteOptions(),
                isFastest: true,
                isSafest: false,
                tollCost: 15.0,
                fuelCost: 25.0
            ),
            isSelected: false
        ) {
            print("Detailed route tapped")
        }
        
        CompactRouteCard(
            route: RouteInfo(
                duration: "30 min",
                distance: "15.2 km",
                type: "Alternative Route",
                isFastest: false,
                isSafest: true
            ),
            isSelected: false
        ) {
            print("Compact route tapped")
        }
    }
    .padding()
    .background(AppleColors.background)
}
