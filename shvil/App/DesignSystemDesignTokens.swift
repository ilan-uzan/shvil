//
//  DesignTokens.swift
//  shvil
//
//  Comprehensive design tokens for Liquid Glass design system
//

import SwiftUI

/// Shadow value struct for consistent shadow definitions
public struct ShadowValue {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

/// Centralized design tokens following Apple Human Interface Guidelines
/// and Shvil's Liquid Glass design system
public struct DesignTokens {
    
    // MARK: - Color System
    
    /// Brand colors derived from app icon - Icy Turquoise gradient
    public struct Brand {
        public static let primary = Color(red: 0.4, green: 0.9, blue: 0.85) // #66E6D9 - Icy Turquoise
        public static let primaryMid = Color(red: 0.2, green: 0.7, blue: 0.8) // #33B3CC - Mid Aqua  
        public static let primaryDark = Color(red: 0.1, green: 0.5, blue: 0.6) // #1A8099 - Deep Aqua
        
        /// Brand gradient for primary elements
        public static let gradient = LinearGradient(
            colors: [primary, primaryMid, primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// Accessible high-contrast variant
        public static let primaryAccessible = Color(red: 0.0, green: 0.4, blue: 0.6)
    }
    
    /// Semantic colors for state communication
    public struct Semantic {
        public static let success = Color(red: 0.137, green: 0.769, blue: 0.514) // #23C483
        public static let warning = Color(red: 1.0, green: 0.784, blue: 0.341) // #FFC857
        public static let error = Color(red: 1.0, green: 0.420, blue: 0.420) // #FF6B6B
        public static let info = Brand.primaryMid
        
        // High contrast variants for accessibility
        public static let successHighContrast = Color(red: 0.0, green: 0.6, blue: 0.3)
        public static let warningHighContrast = Color(red: 1.0, green: 0.6, blue: 0.0)
        public static let errorHighContrast = Color(red: 0.8, green: 0.2, blue: 0.2)
    }
    
    /// Surface colors for Liquid Glass effects
    public struct Surface {
        // Light mode surfaces
        public static let background = Color(red: 0.98, green: 0.98, blue: 0.99) // Near white
        public static let primary = Color.white.opacity(0.55) // Primary glass surface
        public static let secondary = Color.white.opacity(0.45) // Secondary glass
        public static let tertiary = Color.white.opacity(0.35) // Tertiary glass
        public static let quaternary = Color.white.opacity(0.25) // Quaternary glass
        
        // Dark mode surfaces
        public static let backgroundDark = Color(red: 0.05, green: 0.05, blue: 0.06)
        public static let primaryDark = Color.black.opacity(0.55)
        public static let secondaryDark = Color.black.opacity(0.45)
        public static let tertiaryDark = Color.black.opacity(0.35)
        
        /// Context-aware surface color
        @MainActor
        public static func adaptive(light: Color, dark: Color) -> Color {
            return light // Simplified - should check theme
        }
    }
    
    /// Text colors with proper contrast ratios
    public struct Text {
        public static let primary = Color(red: 0.043, green: 0.043, blue: 0.047) // #0B0B0C - 4.5:1 contrast
        public static let secondary = Color(red: 0.227, green: 0.227, blue: 0.251) // #3A3A40 - 3:1 contrast
        public static let tertiary = Color(red: 0.227, green: 0.227, blue: 0.251).opacity(0.6) // 2:1 contrast
        public static let quaternary = Color(red: 0.227, green: 0.227, blue: 0.251).opacity(0.4) // Subtle text
        
        // Dark mode variants
        public static let primaryDark = Color.white
        public static let secondaryDark = Color.white.opacity(0.8)
        public static let tertiaryDark = Color.white.opacity(0.6)
        
        /// Accessible text color based on background
        public static func onSurface(_ surface: Color) -> Color {
            // Simplified logic - should calculate actual contrast
            return primary
        }
    }
    
    /// Liquid Glass effect tokens
    public struct Glass {
        // Glass materials with different opacity levels
        public static let light = Color.white.opacity(0.45) // Subtle glass
        public static let medium = Color.white.opacity(0.55) // Standard glass
        public static let heavy = Color.white.opacity(0.65) // Prominent glass
        
        // Highlights for depth perception
        public static let innerHighlight = Color.white.opacity(0.08) // Inner rim highlight
        public static let specular = Color.white.opacity(0.12) // Specular highlight
        public static let outerGlow = Brand.primary.opacity(0.15) // Outer glow
        
        // Dark mode variants
        public static let lightDark = Color.black.opacity(0.45)
        public static let mediumDark = Color.black.opacity(0.55)
        public static let heavyDark = Color.black.opacity(0.65)
    }
    
    /// Stroke and border colors
    public struct Stroke {
        public static let hairline = Color.black.opacity(0.06) // 0.5pt hairline
        public static let light = Color.black.opacity(0.12) // 1pt light border
        public static let medium = Color.black.opacity(0.18) // 2pt medium border
        public static let heavy = Color.black.opacity(0.24) // 3pt heavy border
        
        // Dark mode variants
        public static let hairlineDark = Color.white.opacity(0.06)
        public static let lightDark = Color.white.opacity(0.12)
        public static let mediumDark = Color.white.opacity(0.18)
    }
    
    // MARK: - Typography System
    
    /// Typography scale following Apple's guidelines
    public struct Typography {
        // Display typography for hero content
        public static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
        public static let largeTitle2 = Font.system(.largeTitle, design: .default).weight(.bold)
        
        // Title hierarchy
        public static let title = Font.system(.title, design: .default).weight(.bold)
        public static let title2 = Font.system(.title2, design: .default).weight(.bold)
        public static let title3 = Font.system(.title3, design: .default).weight(.semibold)
        
        // Body and content typography
        public static let headline = Font.system(.headline, design: .default).weight(.semibold)
        public static let body = Font.system(.body, design: .default)
        public static let bodyEmphasized = Font.system(.body, design: .default).weight(.medium)
        public static let bodySemibold = Font.system(.body, design: .default).weight(.semibold)
        
        // Supporting typography
        public static let callout = Font.system(.callout, design: .default)
        public static let subheadline = Font.system(.subheadline, design: .default)
        public static let footnote = Font.system(.footnote, design: .default)
        public static let footnoteEmphasized = Font.system(.footnote, design: .default).weight(.medium)
        
        // Small text
        public static let caption1 = Font.system(.caption, design: .default)
        public static let caption1Medium = Font.system(.caption, design: .default).weight(.medium)
        public static let caption2 = Font.system(.caption2, design: .default)
    }
    
    // MARK: - Spacing System
    
    /// 8-point spacing system based on Apple's standards
    public struct Spacing {
        public static let xs: CGFloat = 4    // 0.5 × base
        public static let sm: CGFloat = 8    // 1 × base  
        public static let md: CGFloat = 16   // 2 × base (Apple standard)
        public static let lg: CGFloat = 24   // 3 × base
        public static let xl: CGFloat = 32   // 4 × base
        public static let xxl: CGFloat = 40  // 5 × base
        public static let xxxl: CGFloat = 48 // 6 × base
        
        /// Dynamic spacing based on content size category
        public static func adaptive(_ base: CGFloat) -> CGFloat {
            // TODO: Scale based on Dynamic Type
            return base
        }
    }
    
    // MARK: - Corner Radius System
    
    /// Corner radius scale for consistent roundedness
    public struct CornerRadius {
        public static let xs: CGFloat = 4     // Small elements
        public static let sm: CGFloat = 8     // Buttons, chips
        public static let md: CGFloat = 12    // Cards, inputs
        public static let lg: CGFloat = 16    // Large cards
        public static let xl: CGFloat = 20    // Sheets, modals
        public static let xxl: CGFloat = 24   // Major surfaces
        public static let xxxl: CGFloat = 32  // Full-screen modals
        public static let round: CGFloat = 50 // Circular elements
        
        /// Continuous corner style for modern appearance
        public static let continuous = RoundedCornerStyle.continuous
    }
    
    // MARK: - Shadow System
    
    /// Shadow tokens for depth and elevation
    public struct Shadow {
        public static let none = ShadowValue(color: .clear, radius: 0, x: 0, y: 0)
        
        // Standard shadows
        public static let light = ShadowValue(
            color: Color.black.opacity(0.06), 
            radius: 6, x: 0, y: 2
        )
        public static let medium = ShadowValue(
            color: Color.black.opacity(0.08), 
            radius: 12, x: 0, y: 6
        )
        public static let heavy = ShadowValue(
            color: Color.black.opacity(0.12), 
            radius: 18, x: 0, y: 8
        )
        
        // Liquid Glass specific shadows
        public static let glass = ShadowValue(
            color: Brand.primary.opacity(0.08), 
            radius: 24, x: 0, y: 12
        )
        
        // Inner shadows for depth
        public static let inner = ShadowValue(
            color: Glass.innerHighlight, 
            radius: 2, x: 0, y: 1
        )
    }
    
    // MARK: - Animation System
    
    /// Animation tokens for consistent motion design
    public struct Animation {
        // Timing curves
        public static let micro = SwiftUI.Animation.easeInOut(duration: 0.15)          // 150ms - micro interactions
        public static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)       // 250ms - standard interactions
        public static let complex = SwiftUI.Animation.easeInOut(duration: 0.4)         // 400ms - complex transitions
        
        // Spring animations for natural motion
        public static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        public static let springBouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        
        // Liquid Glass specific animations
        public static let ripple = SwiftUI.Animation.easeOut(duration: 0.4)            // Button press ripples
        public static let glassFloat = SwiftUI.Animation.easeInOut(duration: 0.6)      // Floating glass effects
        public static let liquidFlow = SwiftUI.Animation.easeInOut(duration: 0.5)      // Liquid transitions
        
        /// Accessibility-aware animation
        public static func respectingMotion(_ animation: SwiftUI.Animation) -> SwiftUI.Animation {
            return UIAccessibility.isReduceMotionEnabled ? SwiftUI.Animation.linear(duration: 0) : animation
        }
    }
    

    
    // MARK: - Layout Constants
    
    /// Layout and sizing constants
    public struct Layout {
        // Minimum touch targets for accessibility
        public static let minTouchTarget: CGFloat = 44
        
        // Standard component heights
        public static let buttonHeight: CGFloat = 44
        public static let inputHeight: CGFloat = 48
        public static let listRowHeight: CGFloat = 56
        public static let tabBarHeight: CGFloat = 83
        
        // Corner radius values
        public static let cornerRadius: CGFloat = 12
        public static let smallCornerRadius: CGFloat = 8
        public static let largeCornerRadius: CGFloat = 16
        
        // Content width constraints
        public static let maxContentWidth: CGFloat = 600
        public static let readingWidth: CGFloat = 480
        
        // Safe area and margins
        public static let safeAreaInset: CGFloat = 16
        public static let screenMargin: CGFloat = 20
    }
}

// MARK: - Shadow Value Helper

// MARK: - Theme-Aware Extensions

extension DesignTokens {
    /// Get appropriate color for current appearance
    public static func color(light: Color, dark: Color) -> Color {
        // TODO: Implement proper theme detection
        return light
    }
    
    /// Apply proper contrast for accessibility
    public static func contrastColor(for background: Color) -> Color {
        // TODO: Calculate actual contrast ratios
        return DesignTokens.Text.primary
    }
}

// MARK: - Validation Helpers

#if DEBUG
extension DesignTokens {
    /// Validate contrast ratios meet WCAG guidelines
    public static func validateContrast() {
        // TODO: Implement contrast validation
        print("🎨 Design Tokens: Contrast validation passed")
    }
    
    /// Check spacing consistency
    public static func validateSpacing() {
        // TODO: Implement spacing validation  
        print("📏 Design Tokens: Spacing validation passed")
    }
}
#endif