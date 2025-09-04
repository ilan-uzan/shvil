//
//  NavigationComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

// MARK: - Navigation Components for Focus Mode

/// Reusable navigation button component
struct NavigationButton: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                Text(title)
                    .font(LiquidGlassTypography.captionSmall)
            }
            .foregroundColor(isActive ? LiquidGlassColors.accentText : LiquidGlassColors.secondaryText)
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? LiquidGlassColors.glassSurface2 : LiquidGlassColors.glassSurface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isActive ? LiquidGlassColors.accentText.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonAccessibility(
            label: "\(title) \(isActive ? "on" : "off")",
            hint: "Tap to toggle \(title.lowercased())"
        )
    }
}

/// Turn instruction card component
struct TurnInstructionCard: View {
    let step: MKRoute.Step
    let nextStep: MKRoute.Step?
    let distance: CLLocationDistance
    
    var body: some View {
        HStack(spacing: 12) {
            // Turn Icon
            Image(systemName: turnIcon(for: step))
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(LiquidGlassColors.accentText)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(LiquidGlassColors.glassSurface2)
                        .overlay(
                            Circle()
                                .stroke(LiquidGlassColors.accentText.opacity(0.3), lineWidth: 1)
                        )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(step.instructions)
                    .font(LiquidGlassTypography.titleXL)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .lineLimit(2)
                
                if let nextStep = nextStep {
                    Text("Then \(nextStep.instructions)")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Distance to Turn
            Text(MKDistanceFormatter().string(fromDistance: distance))
                .font(LiquidGlassTypography.captionMedium)
                .foregroundColor(LiquidGlassColors.accentText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func turnIcon(for step: MKRoute.Step) -> String {
        let instructions = step.instructions.lowercased()
        
        if instructions.contains("left") {
            return "arrow.turn.up.left"
        } else if instructions.contains("right") {
            return "arrow.turn.up.right"
        } else if instructions.contains("straight") || instructions.contains("continue") {
            return "arrow.up"
        } else if instructions.contains("u-turn") {
            return "arrow.uturn.up"
        } else if instructions.contains("merge") {
            return "arrow.merge"
        } else if instructions.contains("arrive") {
            return "checkmark.circle.fill"
        } else {
            return "arrow.up"
        }
    }
}

/// Route option selector component
struct RouteOptionSelector: View {
    let options: [RouteOption]
    let selectedOption: RouteOption
    let onSelectionChanged: (RouteOption) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                Button(action: { onSelectionChanged(option) }) {
                    VStack(spacing: 4) {
                        Text(option.name)
                            .font(LiquidGlassTypography.captionMedium)
                            .foregroundColor(option.id == selectedOption.id ? LiquidGlassColors.accentText : LiquidGlassColors.secondaryText)
                        
                        Text(option.formattedTime)
                            .font(LiquidGlassTypography.captionSmall)
                            .foregroundColor(option.id == selectedOption.id ? LiquidGlassColors.accentText : LiquidGlassColors.secondaryText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(option.id == selectedOption.id ? LiquidGlassColors.glassSurface2 : LiquidGlassColors.glassSurface1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(option.id == selectedOption.id ? LiquidGlassColors.accentText.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .buttonAccessibility(
                    label: "\(option.name) route",
                    hint: "Tap to select this route option"
                )
            }
        }
    }
}

/// Navigation status indicator
struct NavigationStatusIndicator: View {
    let isActive: Bool
    let remainingTime: TimeInterval
    let remainingDistance: CLLocationDistance
    
    var body: some View {
        HStack(spacing: 8) {
            // Status Dot
            Circle()
                .fill(isActive ? LiquidGlassColors.accentText : LiquidGlassColors.secondaryText)
                .frame(width: 8, height: 8)
                .scaleEffect(isActive ? 1.2 : 1.0)
                .animation(LiquidGlassAnimations.microInteraction, value: isActive)
            
            if isActive {
                Text(formattedTime)
                    .font(LiquidGlassTypography.captionMedium)
                    .foregroundColor(LiquidGlassColors.accentText)
                
                Text("•")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                
                Text(formattedDistance)
                    .font(LiquidGlassTypography.captionMedium)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
        }
    }
    
    private var formattedTime: String {
        let hours = Int(remainingTime) / 3600
        let minutes = Int(remainingTime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var formattedDistance: String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: remainingDistance)
    }
}

/// Emergency button component
struct EmergencyButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20, weight: .medium))
                Text("Help")
                    .font(LiquidGlassTypography.captionSmall)
            }
            .foregroundColor(LiquidGlassColors.accident)
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LiquidGlassColors.accident.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonAccessibility(
            label: "Emergency options",
            hint: "Tap for emergency options"
        )
    }
}

/// Glass surface container for navigation elements
struct NavigationGlassSurface: View {
    let content: AnyView
    let elevation: GlassElevation
    
    init<Content: View>(elevation: GlassElevation = .medium, @ViewBuilder content: () -> Content) {
        self.elevation = elevation
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(glassColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: shadowRadius, x: 0, y: shadowOffset)
            )
    }
    
    private var glassColor: Color {
        switch elevation {
        case .light:
            return LiquidGlassColors.glassSurface1
        case .medium:
            return LiquidGlassColors.glassSurface2
        case .high:
            return LiquidGlassColors.glassSurface3
        }
    }
    
    private var shadowRadius: CGFloat {
        switch elevation {
        case .light: return 4
        case .medium: return 8
        case .high: return 12
        }
    }
    
    private var shadowOffset: CGFloat {
        switch elevation {
        case .light: return 2
        case .medium: return 4
        case .high: return 6
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        NavigationButton(
            icon: "speaker.wave.2.fill",
            title: "Voice",
            isActive: true
        ) { }
        
        TurnInstructionCard(
            step: MKRoute.Step(),
            nextStep: nil,
            distance: 500
        )
        
        RouteOptionSelector(
            options: [
                RouteOption.fastest,
                RouteOption.fastest
            ],
            selectedOption: RouteOption.fastest
        ) { _ in }
        
        NavigationStatusIndicator(
            isActive: true,
            remainingTime: 1800,
            remainingDistance: 5000
        )
        
        EmergencyButton { }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
