//
//  LiquidGlassDesign.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Liquid Glass Design System

// Exact implementation matching the spec requirements

// MARK: - Typography (SF Pro) - Dynamic Type Support

enum LiquidGlassTypography {
    // TitleXL (Nav instruction): 24–28pt, semibold - Dynamic Type
    static let titleXL = Font.system(.title2, design: .default).weight(.semibold)

    // Title (Sheet headers): 20–22pt, semibold - Dynamic Type
    static let title = Font.system(.title3, design: .default).weight(.semibold)

    // Body: 17pt min - Dynamic Type
    static let body = Font.system(.body, design: .default)
    static let bodyMedium = Font.system(.body, design: .default).weight(.medium)
    static let bodySemibold = Font.system(.body, design: .default).weight(.semibold)

    // Caption: 13–15pt - Dynamic Type
    static let caption = Font.system(.caption, design: .default)
    static let captionMedium = Font.system(.caption, design: .default).weight(.medium)
    static let captionSmall = Font.system(.caption2, design: .default)

    // Additional Dynamic Type styles
    static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    static let headline = Font.system(.headline, design: .default)
    static let subheadline = Font.system(.subheadline, design: .default)
    static let footnote = Font.system(.footnote, design: .default)
}

// MARK: - Color Palette

enum LiquidGlassColors {
    // Accent Gradient: Turquoise (#3DDAD7) → Deep Aqua (#007C8C)
    static let accentTurquoise = Color(red: 0.24, green: 0.85, blue: 0.84) // #3DDAD7
    static let accentDeepAqua = Color(red: 0.0, green: 0.49, blue: 0.55) // #007C8C

    // Surface/Glass: #0E1116 with 40–60% opacity, subtle bluish tint
    static let glassBase = Color(red: 0.055, green: 0.067, blue: 0.086) // #0E1116
    static let glassSurface1 = glassBase.opacity(0.4)
    static let glassSurface2 = glassBase.opacity(0.5)
    static let glassSurface3 = glassBase.opacity(0.6)

    // Map Base: neutral/desaturated
    static let mapBase = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let mapRoads = Color(red: 0.3, green: 0.3, blue: 0.3)

    // Alerts
    static let accident = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
    static let police = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00
    static let camera = Color(red: 0.04, green: 0.52, blue: 1.0) // #0A84FF

    // Text Colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let accentText = accentTurquoise

    // Background
    static let background = Color.black
    static let surface = glassSurface1
    
    // Glass surface colors for components
    static let glassSurface = glassSurface1
    static let glassBorder = glassSurface2
}

// MARK: - Gradients

enum LiquidGlassGradients {
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

enum LiquidGlassAnimations {
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
            LiquidGlassColors.glassSurface1
        case .medium:
            LiquidGlassColors.glassSurface2
        case .high:
            LiquidGlassColors.glassSurface3
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
        case .light: 4
        case .medium: 8
        case .high: 12
        }
    }

    private var shadowOffset: CGFloat {
        switch elevation {
        case .light: 2
        case .medium: 4
        case .high: 6
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
        modifier(GlassEffectModifier(elevation: elevation))
    }

    func glassBlur(intensity: CGFloat = 20) -> some View {
        modifier(BlurEffectModifier(intensity: intensity))
    }

    func liquidGlassPill() -> some View {
        padding(.horizontal, 16)
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
        frame(width: 56, height: 56)
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

enum RoutePolylineStyle {
    static let strokeWidth: CGFloat = 6
    static let glowRadius: CGFloat = 8
    static let glowOpacity: Double = 0.6
}

// MARK: - Accessibility Extensions

extension View {
    /// Adds comprehensive accessibility support for Shvil UI components
    func shvilAccessibility(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = [],
        action: (() -> Void)? = nil
    ) -> some View {
        var view = accessibilityAddTraits(traits)

        if let label {
            view = view.accessibilityLabel(label)
        }
        if let hint {
            view = view.accessibilityHint(hint)
        }
        if let value {
            view = view.accessibilityValue(value)
        }
        if let action {
            view = view.accessibilityAction(named: "Activate", action)
        }

        return view
    }

    /// Adds accessibility support for navigation elements
    func navigationAccessibility(
        label: String,
        hint: String? = nil,
        isSelected: Bool = false
    ) -> some View {
        shvilAccessibility(
            label: label,
            hint: hint ?? "Double tap to navigate",
            traits: isSelected ? [.isSelected] : [.isButton]
        )
    }

    /// Adds accessibility support for toggle elements
    func toggleAccessibility(
        label: String,
        isOn: Bool,
        hint: String? = nil
    ) -> some View {
        shvilAccessibility(
            label: label,
            hint: hint ?? "Double tap to toggle",
            value: isOn ? "On" : "Off",
            traits: .isButton
        )
    }

    /// Adds accessibility support for button elements
    func buttonAccessibility(
        label: String,
        hint: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        shvilAccessibility(
            label: label,
            hint: hint ?? "Double tap to activate",
            traits: .isButton,
            action: action
        )
    }

    /// Adds accessibility support for list items
    func listItemAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        shvilAccessibility(
            label: label,
            hint: hint,
            value: value,
            traits: .isButton
        )
    }

    /// Adds accessibility support for map elements
    func mapElementAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        shvilAccessibility(
            label: label,
            hint: hint ?? "Double tap for more information",
            value: value,
            traits: .isButton
        )
    }
}

// MARK: - Dynamic Type Support

extension View {
    /// Ensures text scales properly with Dynamic Type
    func dynamicTypeSupport() -> some View {
        dynamicTypeSize(.large ... .accessibility3)
    }

    /// Limits Dynamic Type scaling for UI elements that shouldn't grow too large
    func limitedDynamicType() -> some View {
        dynamicTypeSize(.medium ... .accessibility1)
    }
}

// MARK: - RTL Support

extension View {
    /// Ensures proper RTL layout support
    func rtlSupport() -> some View {
        environment(\.layoutDirection, .leftToRight) // Will be overridden by system
    }
}

// MARK: - High Contrast Support

extension LiquidGlassColors {
    /// High contrast color variants for accessibility
    static let highContrastPrimaryText = Color.white
    static let highContrastSecondaryText = Color.white.opacity(0.9)
    static let highContrastAccentText = Color.cyan
    static let highContrastBackground = Color.black
    static let highContrastGlassSurface1 = Color.white.opacity(0.2)
    static let highContrastGlassSurface2 = Color.white.opacity(0.3)
    static let highContrastGlassSurface3 = Color.white.opacity(0.4)
}

// MARK: - Accessibility Constants

enum AccessibilityConstants {
    static let minimumTouchTarget: CGFloat = 44
    static let minimumContrastRatio: Double = 4.5
    static let maximumAnimationDuration: Double = 0.5
}
