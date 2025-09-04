//
//  LiquidGlassDesign.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Liquid Glass Design System
// Exact implementation matching the spec requirements

// MARK: - Typography (SF Pro)
struct LiquidGlassTypography {
    // TitleXL (Nav instruction): 24–28pt, semibold
    static let titleXL = Font.system(size: 26, weight: .semibold, design: .default)
    
    // Title (Sheet headers): 20–22pt, semibold
    static let title = Font.system(size: 21, weight: .semibold, design: .default)
    
    // Body: 17pt min
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
    static let bodySemibold = Font.system(size: 17, weight: .semibold, design: .default)
    
    // Caption: 13–15pt
    static let caption = Font.system(size: 14, weight: .regular, design: .default)
    static let captionMedium = Font.system(size: 14, weight: .medium, design: .default)
    static let captionSmall = Font.system(size: 13, weight: .regular, design: .default)
}

// MARK: - Color Palette
struct LiquidGlassColors {
    // Accent Gradient: Turquoise (#3DDAD7) → Deep Aqua (#007C8C)
    static let accentTurquoise = Color(red: 0.24, green: 0.85, blue: 0.84) // #3DDAD7
    static let accentDeepAqua = Color(red: 0.0, green: 0.49, blue: 0.55)   // #007C8C
    
    // Surface/Glass: #0E1116 with 40–60% opacity, subtle bluish tint
    static let glassBase = Color(red: 0.055, green: 0.067, blue: 0.086) // #0E1116
    static let glassSurface1 = glassBase.opacity(0.4)
    static let glassSurface2 = glassBase.opacity(0.5)
    static let glassSurface3 = glassBase.opacity(0.6)
    
    // Map Base: neutral/desaturated
    static let mapBase = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let mapRoads = Color(red: 0.3, green: 0.3, blue: 0.3)
    
    // Alerts
    static let accident = Color(red: 1.0, green: 0.23, blue: 0.19)  // #FF3B30
    static let police = Color(red: 1.0, green: 0.8, blue: 0.0)     // #FFCC00
    static let camera = Color(red: 0.04, green: 0.52, blue: 1.0)   // #0A84FF
    
    // Text Colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let accentText = accentTurquoise
    
    // Background
    static let background = Color.black
    static let surface = glassSurface1
}

// MARK: - Gradients
struct LiquidGlassGradients {
    // Primary Accent Gradient
    static let primaryGradient = LinearGradient(
        colors: [LiquidGlassColors.accentTurquoise, LiquidGlassColors.accentDeepAqua],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Glass Surface Gradients
    static let glassGradient1 = LinearGradient(
        colors: [LiquidGlassColors.glassSurface1, LiquidGlassColors.glassSurface2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient2 = LinearGradient(
        colors: [LiquidGlassColors.glassSurface2, LiquidGlassColors.glassSurface3],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Route Polyline Gradient
    static let routeGradient = LinearGradient(
        colors: [LiquidGlassColors.accentTurquoise, LiquidGlassColors.accentDeepAqua],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Animations
struct LiquidGlassAnimations {
    // Micro interactions: ≤200ms
    static let microInteraction = Animation.easeInOut(duration: 0.15)
    
    // Standard interactions: 300ms
    static let standard = Animation.easeInOut(duration: 0.3)
    
    // Pour Animation (sheets): ≤600ms, easeOut
    static let pourAnimation = Animation.easeOut(duration: 0.6)
    
    // Spring animations
    static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    
    // Scale animations for FABs
    static let fabPress = Animation.easeInOut(duration: 0.1)
}

// MARK: - Glass Effect Modifier
struct GlassEffectModifier: ViewModifier {
    let elevation: GlassElevation
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(glassColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(highlightColor, lineWidth: 2)
                    )
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
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
    
    private var highlightColor: Color {
        Color.white.opacity(0.2) // 2pt highlight edge
    }
    
    private var shadowColor: Color {
        Color.black.opacity(0.3) // Soft outer shadow
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

enum GlassElevation {
    case light
    case medium
    case high
}

// MARK: - Blur Effect Modifier
struct BlurEffectModifier: ViewModifier {
    let intensity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )
    }
}

// MARK: - View Extensions
extension View {
    func glassEffect(elevation: GlassElevation = .medium) -> some View {
        self.modifier(GlassEffectModifier(elevation: elevation))
    }
    
    func glassBlur(intensity: CGFloat = 20) -> some View {
        self.modifier(BlurEffectModifier(intensity: intensity))
    }
    
    func liquidGlassPill() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(LiquidGlassColors.glassSurface1)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
    
    func liquidGlassFAB() -> some View {
        self
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(LiquidGlassGradients.primaryGradient)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: LiquidGlassColors.accentTurquoise.opacity(0.3), radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - Route Polyline Style
struct RoutePolylineStyle {
    static let strokeWidth: CGFloat = 6
    static let glowRadius: CGFloat = 8
    static let glowOpacity: Double = 0.6
}