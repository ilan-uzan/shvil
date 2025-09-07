//
//  Theme.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import Combine

// MARK: - Liquid Glass Design System 2.0
// Centralized design tokens and theme management for Shvil

// MARK: - Design Tokens

/// Centralized design tokens for the Shvil Liquid Glass design system
public struct DesignTokens {
    
    // MARK: - Color Tokens
    
    /// Brand color palette - Icy Turquoise to Deep Aqua gradient
    public struct Brand {
        public static let primary = Color(red: 0.4, green: 0.9, blue: 0.85) // #66E6D9 - Icy Turquoise
        public static let primaryMid = Color(red: 0.2, green: 0.7, blue: 0.8) // #33B3CC - Mid Aqua
        public static let primaryDark = Color(red: 0.1, green: 0.5, blue: 0.6) // #1A8099 - Deep Aqua
        
        public static let gradient = LinearGradient(
            colors: [primary, primaryMid, primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Semantic color tokens
    public struct Semantic {
        public static let success = Color(red: 0.137, green: 0.769, blue: 0.514) // #23C483
        public static let warning = Color(red: 1.0, green: 0.784, blue: 0.341) // #FFC857
        public static let error = Color(red: 1.0, green: 0.420, blue: 0.420) // #FF6B6B
        public static let info = Brand.primaryMid
        
        // High contrast variants for accessibility
        public static let successHighContrast = Color(red: 0.0, green: 0.6, blue: 0.3)
        public static let warningHighContrast = Color(red: 1.0, green: 0.6, blue: 0.0)
        public static let errorHighContrast = Color(red: 0.8, green: 0.2, blue: 0.2)
        public static let infoHighContrast = Color(red: 0.0, green: 0.4, blue: 0.8)
    }
    
    /// Surface color tokens for glass effects
    public struct Surface {
        public static let background = Color(red: 0.98, green: 0.98, blue: 0.99) // Near white
        public static let primary = Color.white.opacity(0.55) // Primary glass surface
        public static let secondary = Color.white.opacity(0.45) // Secondary glass
        public static let tertiary = Color.white.opacity(0.35) // Tertiary glass
        public static let quaternary = Color.white.opacity(0.25) // Quaternary glass
        
        // Dark mode variants
        public static let backgroundDark = Color(red: 0.05, green: 0.05, blue: 0.06) // Near black
        public static let primaryDark = Color.black.opacity(0.55)
        public static let secondaryDark = Color.black.opacity(0.45)
        public static let tertiaryDark = Color.black.opacity(0.35)
        public static let quaternaryDark = Color.black.opacity(0.25)
    }
    
    /// Text color tokens
    public struct Text {
        public static let primary = Color(red: 0.043, green: 0.043, blue: 0.047) // #0B0B0C
        public static let secondary = Color(red: 0.227, green: 0.227, blue: 0.251) // #3A3A40
        public static let tertiary = Color(red: 0.227, green: 0.227, blue: 0.251).opacity(0.6)
        public static let quaternary = Color(red: 0.227, green: 0.227, blue: 0.251).opacity(0.4)
        
        // Dark mode variants
        public static let primaryDark = Color.white
        public static let secondaryDark = Color.white.opacity(0.8)
        public static let tertiaryDark = Color.white.opacity(0.6)
        public static let quaternaryDark = Color.white.opacity(0.4)
    }
    
    /// Glass effect tokens for Liquid Glass design
    public struct Glass {
        public static let light = Color.white.opacity(0.45) // Frosted glass
        public static let medium = Color.white.opacity(0.55) // Medium glass
        public static let heavy = Color.white.opacity(0.65) // Heavy glass
        
        // Inner highlights for depth
        public static let innerHighlight = Color.white.opacity(0.08)
        public static let specular = Color.white.opacity(0.12)
        
        // Outer glow for Liquid Glass effect
        public static let outerGlow = Brand.primary.opacity(0.15)
        
        // Dark mode variants
        public static let lightDark = Color.black.opacity(0.45)
        public static let mediumDark = Color.black.opacity(0.55)
        public static let heavyDark = Color.black.opacity(0.65)
    }
    
    /// Stroke color tokens
    public struct Stroke {
        public static let hairline = Color.black.opacity(0.06)
        public static let light = Color.black.opacity(0.12)
        public static let medium = Color.black.opacity(0.18)
        public static let heavy = Color.black.opacity(0.24)
        
        // Dark mode variants
        public static let hairlineDark = Color.white.opacity(0.06)
        public static let lightDark = Color.white.opacity(0.12)
        public static let mediumDark = Color.white.opacity(0.18)
        public static let heavyDark = Color.white.opacity(0.24)
    }
    
    // MARK: - Typography Tokens
    
    /// Typography scale following Apple's Human Interface Guidelines
    public struct Typography {
        // Large titles
        public static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
        public static let largeTitle2 = Font.system(.largeTitle, design: .default).weight(.bold)
        
        // Titles
        public static let title = Font.system(.title, design: .default).weight(.bold)
        public static let title2 = Font.system(.title2, design: .default).weight(.bold)
        public static let title3 = Font.system(.title3, design: .default).weight(.semibold)
        
        // Headlines and body
        public static let headline = Font.system(.headline, design: .default).weight(.semibold)
        public static let body = Font.system(.body, design: .default)
        public static let bodyEmphasized = Font.system(.body, design: .default).weight(.medium)
        public static let bodySemibold = Font.system(.body, design: .default).weight(.semibold)
        
        // Callouts and subheadlines
        public static let callout = Font.system(.callout, design: .default)
        public static let subheadline = Font.system(.subheadline, design: .default)
        
        // Footnotes and captions
        public static let footnote = Font.system(.footnote, design: .default)
        public static let footnoteEmphasized = Font.system(.footnote, design: .default).weight(.medium)
        public static let caption1 = Font.system(.caption, design: .default)
        public static let caption1Medium = Font.system(.caption, design: .default).weight(.medium)
        public static let caption2 = Font.system(.caption2, design: .default)
        
        // Accessibility variants
        public static let accessibilityLargeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
        public static let accessibilityTitle = Font.system(.title, design: .default).weight(.bold)
        public static let accessibilityHeadline = Font.system(.headline, design: .default).weight(.semibold)
        public static let accessibilityBody = Font.system(.body, design: .default).weight(.regular)
    }
    
    // MARK: - Spacing Tokens
    
    /// Spacing scale based on 8pt grid system
    public struct Spacing {
        public static let xs: CGFloat = 4    // 4pt
        public static let sm: CGFloat = 8    // 8pt
        public static let md: CGFloat = 16   // 16pt
        public static let lg: CGFloat = 24   // 24pt
        public static let xl: CGFloat = 32   // 32pt
        public static let xxl: CGFloat = 40  // 40pt
        public static let xxxl: CGFloat = 48 // 48pt
        public static let xxxxl: CGFloat = 64 // 64pt
    }
    
    // MARK: - Corner Radius Tokens
    
    /// Corner radius scale for consistent rounded corners
    public struct CornerRadius {
        public static let xs: CGFloat = 4    // 4pt
        public static let sm: CGFloat = 8    // 8pt
        public static let md: CGFloat = 12   // 12pt
        public static let lg: CGFloat = 16   // 16pt
        public static let xl: CGFloat = 20   // 20pt - Card radius
        public static let xxl: CGFloat = 24  // 24pt - Large card radius
        public static let xxxl: CGFloat = 32 // 32pt - Modal radius
        public static let round: CGFloat = 50 // 50% for circular elements
    }
    
    // MARK: - Shadow Tokens
    
    /// Shadow system for depth and elevation
    public struct Shadow {
        public static let none = ShadowValue(color: Color.clear, radius: 0, x: 0, y: 0)
        public static let light = ShadowValue(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        public static let medium = ShadowValue(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        public static let heavy = ShadowValue(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 8)
        public static let glass = ShadowValue(color: Brand.primary.opacity(0.08), radius: 24, x: 0, y: 12)
        
        // Inner shadows for depth
        public static let innerLight = ShadowValue(color: Glass.innerHighlight, radius: 2, x: 0, y: 1)
        public static let innerMedium = ShadowValue(color: Glass.innerHighlight, radius: 4, x: 0, y: 2)
        
        // Dark mode variants
        public static let lightDark = ShadowValue(color: Color.white.opacity(0.06), radius: 6, x: 0, y: 2)
        public static let mediumDark = ShadowValue(color: Color.white.opacity(0.08), radius: 12, x: 0, y: 6)
        public static let heavyDark = ShadowValue(color: Color.white.opacity(0.12), radius: 18, x: 0, y: 8)
    }
    
    // MARK: - Animation Tokens
    
    /// Animation system for consistent motion
    public struct Animation {
        // Micro-interactions (100-200ms)
        public static let micro = SwiftUI.Animation.easeInOut(duration: 0.15)
        public static let microInteraction = SwiftUI.Animation.easeInOut(duration: 0.15)
        
        // Standard interactions (200-300ms)
        public static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        
        // Complex interactions (300-500ms)
        public static let complex = SwiftUI.Animation.easeInOut(duration: 0.4)
        
        // Spring animations
        public static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        public static let springBouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        
        // Page transitions
        public static let pageTransition = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        // Liquid Glass specific animations
        public static let ripple = SwiftUI.Animation.easeOut(duration: 0.4) // Micro-ripples on tap
        public static let glassFloat = SwiftUI.Animation.easeInOut(duration: 0.6) // Floating glass effects
        public static let parallax = SwiftUI.Animation.easeInOut(duration: 0.8) // Subtle parallax on scroll
        public static let liquidFlow = SwiftUI.Animation.easeInOut(duration: 0.5) // Liquid glass transitions
    }
    
    // MARK: - Blur Tokens
    
    /// Blur effects for glassmorphism
    public struct Blur {
        public static let light: Material = .ultraThinMaterial
        public static let medium: Material = .thinMaterial
        public static let heavy: Material = .regularMaterial
        public static let extraHeavy: Material = .thickMaterial
    }
}

// MARK: - Shadow Value Struct

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

// MARK: - Theme Manager

/// Centralized theme management with dark mode support
@MainActor
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @Published public var isDarkMode: Bool = false
    @Published public var isHighContrast: Bool = false
    @Published public var isReduceMotion: Bool = false
    @Published public var preferredColorScheme: ColorScheme = .light
    
    private init() {
        setupObservers()
        updateTheme()
    }
    
    private func setupObservers() {
        // Monitor system appearance changes
        NotificationCenter.default.publisher(for: NSNotification.Name("NSAppearanceChanged"))
            .sink { [weak self] _ in
                self?.updateTheme()
            }
            .store(in: &cancellables)
        
        // Monitor accessibility changes
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateAccessibilitySettings()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func updateTheme() {
        // Check system appearance
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            isDarkMode = windowScene.traitCollection.userInterfaceStyle == .dark
            preferredColorScheme = isDarkMode ? .dark : .light
        }
    }
    
    private func updateAccessibilitySettings() {
        isHighContrast = UIAccessibility.isDarkerSystemColorsEnabled
        isReduceMotion = UIAccessibility.isReduceMotionEnabled
    }
    
    public func toggleDarkMode() {
        isDarkMode.toggle()
        preferredColorScheme = isDarkMode ? .dark : .light
    }
}

// MARK: - Theme-Aware Color Extensions

extension Color {
    /// Returns the appropriate color based on current theme
    @MainActor
    public func themeAware(light: Color, dark: Color) -> Color {
        ThemeManager.shared.isDarkMode ? dark : light
    }
    
    /// Returns high contrast variant if enabled
    @MainActor
    public func highContrast(_ highContrastColor: Color) -> Color {
        ThemeManager.shared.isHighContrast ? highContrastColor : self
    }
}

// MARK: - Design System Constants

public struct DesignConstants {
    /// Minimum hit target size for accessibility
    public static let minimumHitTarget: CGFloat = 44
    
    /// Maximum content width for readability
    public static let maxContentWidth: CGFloat = 600
    
    /// Standard card padding
    public static let cardPadding: CGFloat = DesignTokens.Spacing.md
    
    /// Standard list item height
    public static let listItemHeight: CGFloat = 56
    
    /// Standard button height
    public static let buttonHeight: CGFloat = 44
    
    /// Standard input field height
    public static let inputHeight: CGFloat = 48
}
