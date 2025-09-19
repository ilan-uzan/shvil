import SwiftUI

/// Shvil brand colors following the provided palette
struct ShvilColors {
    
    // MARK: - Primary Brand Colors
    
    /// Shvil Teal 500 - Main accent color
    static let accentPrimary = Color(red: 0.008, green: 0.757, blue: 0.710) // #02C1B5
    
    /// Shvil Teal 600 - Pressed/active state
    static let accentPrimaryPressed = Color(red: 0.0, green: 0.651, blue: 0.608) // #00A69B
    
    /// Shvil Teal 300 - Hover/focus, subtle outlines
    static let accentPrimaryLight = Color(red: 0.247, green: 0.843, blue: 0.804) // #3FD7CD
    
    // MARK: - Secondary Colors
    
    /// Electric Azure 500 - Links, secondary CTAs
    static let accentSecondary = Color(red: 0.102, green: 0.549, blue: 1.0) // #1A8CFF
    
    /// Electric Azure 600 - Pressed/active state
    static let accentSecondaryPressed = Color(red: 0.059, green: 0.451, blue: 0.839) // #0F73D6
    
    // MARK: - Text Colors
    
    /// Primary text color (light mode: Ink 900, dark mode: #EAF0F6)
    static let textPrimary = Color.primary
    
    /// Secondary text color (light mode: Ink 700, dark mode: #B7C3CF)
    static let textSecondary = Color.secondary
    
    // MARK: - Surface Colors
    
    /// Base surface color (light mode: Mist 050, dark mode: Night 900)
    static let surfaceBase = Color(UIColor.systemBackground)
    
    /// Elevated surface color (light mode: #FFFFFF 96%, dark mode: Night 800)
    static let surfaceElevated = Color(UIColor.secondarySystemBackground)
    
    // MARK: - Border Colors
    
    /// Divider/border color (light mode: Mist 100, dark mode: #2A313B)
    static let borderDivider = Color(UIColor.separator)
    
    // MARK: - Feedback Colors
    
    /// Success color
    static let success = Color(red: 0.125, green: 0.780, blue: 0.451) // #20C773
    
    /// Warning color
    static let warning = Color(red: 1.0, green: 0.690, blue: 0.125) // #FFB020
    
    /// Destructive color
    static let destructive = Color(red: 1.0, green: 0.353, blue: 0.373) // #FF5A5F
    
    // MARK: - Map Marker Colors
    
    /// City marker color
    static let markerCity = Color(red: 0.361, green: 0.420, blue: 1.0) // #5C6BFF
    
    /// Nature marker color
    static let markerNature = Color(red: 0.133, green: 0.773, blue: 0.337) // #22C55E
    
    /// Culture marker color
    static let markerCulture = Color(red: 0.659, green: 0.333, blue: 0.969) // #A855F7
    
    /// Food marker color
    static let markerFood = Color(red: 1.0, green: 0.478, blue: 0.271) // #FF7A45
    
    /// Default marker color (uses accent primary)
    static let markerDefault = accentPrimary
    
    // MARK: - Dark Mode Specific Colors
    
    /// Night 900 - Base dark surface
    static let night900 = Color(red: 0.039, green: 0.051, blue: 0.071) // #0A0D12
    
    /// Night 800 - Elevated dark surface
    static let night800 = Color(red: 0.071, green: 0.086, blue: 0.110) // #12161C
    
    /// Night 700 - Cards/sheets in dark mode
    static let night700 = Color(red: 0.102, green: 0.122, blue: 0.153) // #1A1F27
    
    // MARK: - Light Mode Specific Colors
    
    /// Ink 900 - Primary text on light
    static let ink900 = Color(red: 0.055, green: 0.067, blue: 0.086) // #0E1116
    
    /// Ink 700 - Secondary text on light
    static let ink700 = Color(red: 0.165, green: 0.192, blue: 0.231) // #2A313B
    
    /// Mist 050 - Surface on light
    static let mist050 = Color(red: 0.965, green: 0.973, blue: 0.984) // #F6F8FB
    
    /// Mist 100 - Dividers/lines on light
    static let mist100 = Color(red: 0.910, green: 0.929, blue: 0.957) // #E8EDF4
}

// MARK: - Gradient Definitions

extension ShvilColors {
    
    /// Primary CTA gradient (Start Adventure button)
    static let primaryGradient = LinearGradient(
        colors: [accentPrimaryPressed, accentPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Pin selected glow gradient
    static let pinGlowGradient = RadialGradient(
        colors: [accentPrimary.opacity(0.3), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 20
    )
    
    /// Explore header sweep gradient (optional)
    static let exploreHeaderGradient = LinearGradient(
        colors: [accentSecondary.opacity(0.08), accentPrimary.opacity(0.0)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Dynamic Color Support

extension ShvilColors {
    
    /// Dynamic text primary color that adapts to light/dark mode
    static var dynamicTextPrimary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.918, green: 0.941, blue: 0.965, alpha: 1.0) // #EAF0F6
            default:
                return UIColor(red: 0.055, green: 0.067, blue: 0.086, alpha: 1.0) // #0E1116
            }
        })
    }
    
    /// Dynamic text secondary color that adapts to light/dark mode
    static var dynamicTextSecondary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.718, green: 0.765, blue: 0.812, alpha: 1.0) // #B7C3CF
            default:
                return UIColor(red: 0.165, green: 0.192, blue: 0.231, alpha: 1.0) // #2A313B
            }
        })
    }
    
    /// Dynamic surface base color that adapts to light/dark mode
    static var dynamicSurfaceBase: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.039, green: 0.051, blue: 0.071, alpha: 1.0) // #0A0D12
            default:
                return UIColor(red: 0.965, green: 0.973, blue: 0.984, alpha: 1.0) // #F6F8FB
            }
        })
    }
    
    /// Dynamic surface elevated color that adapts to light/dark mode
    static var dynamicSurfaceElevated: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.071, green: 0.086, blue: 0.110, alpha: 1.0) // #12161C
            default:
                return UIColor.white.withAlphaComponent(0.96) // #FFFFFF 96%
            }
        })
    }
    
    /// Dynamic divider color that adapts to light/dark mode
    static var dynamicBorderDivider: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.165, green: 0.192, blue: 0.231, alpha: 1.0) // #2A313B
            default:
                return UIColor(red: 0.910, green: 0.929, blue: 0.957, alpha: 1.0) // #E8EDF4
            }
        })
    }
}
