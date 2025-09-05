//
//  AppleDesignSystem.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Apple Design System for Shvil
// Following Apple's Human Interface Guidelines and iOS Design Principles

// MARK: - Color System (Apple Compliant)

enum AppleColors {
    // Primary Colors - Following Apple's color guidelines
    static let primary = Color(red: 0.0, green: 0.48, blue: 0.55) // Deep Aqua
    static let primaryLight = Color(red: 0.24, green: 0.85, blue: 0.84) // Turquoise
    static let primaryDark = Color(red: 0.0, green: 0.35, blue: 0.4) // Darker Aqua
    
    // Semantic Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // Neutral Colors
    static let background = Color.black
    static let surface = Color(red: 0.05, green: 0.06, blue: 0.08) // #0D0F12
    static let surfaceSecondary = Color(red: 0.08, green: 0.09, blue: 0.12) // #14151F
    static let surfaceTertiary = Color(red: 0.12, green: 0.13, blue: 0.16) // #1F2029
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    static let textQuaternary = Color.white.opacity(0.3)
    
    // Glass Colors (for glassmorphism)
    static let glassLight = Color.white.opacity(0.1)
    static let glassMedium = Color.white.opacity(0.15)
    static let glassHeavy = Color.white.opacity(0.2)
    
    // Accent Colors
    static let accent = primaryLight
    static let accentSecondary = Color(red: 0.4, green: 0.7, blue: 0.9) // Light Blue
}

// MARK: - Typography System (Apple SF Pro)

enum AppleTypography {
    // Large Title (34pt, bold)
    static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    
    // Title 1 (28pt, bold)
    static let title1 = Font.system(.title, design: .default).weight(.bold)
    
    // Title 2 (22pt, bold)
    static let title2 = Font.system(.title2, design: .default).weight(.bold)
    
    // Title 3 (20pt, semibold)
    static let title3 = Font.system(.title3, design: .default).weight(.semibold)
    
    // Headline (17pt, semibold)
    static let headline = Font.system(.headline, design: .default).weight(.semibold)
    
    // Body (17pt, regular)
    static let body = Font.system(.body, design: .default)
    static let bodyEmphasized = Font.system(.body, design: .default).weight(.medium)
    
    // Callout (16pt, regular)
    static let callout = Font.system(.callout, design: .default)
    
    // Subheadline (15pt, regular)
    static let subheadline = Font.system(.subheadline, design: .default)
    
    // Footnote (13pt, regular)
    static let footnote = Font.system(.footnote, design: .default)
    static let footnoteEmphasized = Font.system(.footnote, design: .default).weight(.medium)
    
    // Caption 1 (12pt, regular)
    static let caption1 = Font.system(.caption, design: .default)
    
    // Caption 2 (11pt, regular)
    static let caption2 = Font.system(.caption2, design: .default)
}

// MARK: - Spacing System (8pt grid)

enum AppleSpacing {
    static let xs: CGFloat = 4    // 4pt
    static let sm: CGFloat = 8    // 8pt
    static let md: CGFloat = 16   // 16pt
    static let lg: CGFloat = 24   // 24pt
    static let xl: CGFloat = 32   // 32pt
    static let xxl: CGFloat = 40  // 40pt
    static let xxxl: CGFloat = 48 // 48pt
}

// MARK: - Corner Radius System

enum AppleCornerRadius {
    static let xs: CGFloat = 4    // 4pt
    static let sm: CGFloat = 8    // 8pt
    static let md: CGFloat = 12   // 12pt
    static let lg: CGFloat = 16   // 16pt
    static let xl: CGFloat = 20   // 20pt
    static let xxl: CGFloat = 24  // 24pt
    static let round: CGFloat = 50 // 50% for circular elements
}

// MARK: - Shadow System

enum AppleShadows {
    static let light = Shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    static let heavy = Shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    static let glass = Shadow(color: AppleColors.accent.opacity(0.1), radius: 12, x: 0, y: 0)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation System

enum AppleAnimations {
    // Micro-interactions (100-200ms)
    static let micro = Animation.easeInOut(duration: 0.15)
    
    // Standard interactions (200-300ms)
    static let standard = Animation.easeInOut(duration: 0.25)
    
    // Complex interactions (300-500ms)
    static let complex = Animation.easeInOut(duration: 0.4)
    
    // Spring animations
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    
    // Page transitions
    static let pageTransition = Animation.easeInOut(duration: 0.3)
}

// MARK: - Glassmorphism Modifier

struct GlassmorphismModifier: ViewModifier {
    let intensity: GlassIntensity
    let cornerRadius: CGFloat
    
    enum GlassIntensity {
        case light
        case medium
        case heavy
    }
    
    init(intensity: GlassIntensity = .medium, cornerRadius: CGFloat = AppleCornerRadius.md) {
        self.intensity = intensity
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(glassColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(highlightColor, lineWidth: 1)
                    )
                    .shadow(color: AppleShadows.glass.color, radius: AppleShadows.glass.radius, x: AppleShadows.glass.x, y: AppleShadows.glass.y)
            )
    }
    
    private var glassColor: Color {
        switch intensity {
        case .light: AppleColors.glassLight
        case .medium: AppleColors.glassMedium
        case .heavy: AppleColors.glassHeavy
        }
    }
    
    private var highlightColor: Color {
        Color.white.opacity(0.2)
    }
}

// MARK: - View Extensions

extension View {
    func glassmorphism(intensity: GlassmorphismModifier.GlassIntensity = .medium, cornerRadius: CGFloat = AppleCornerRadius.md) -> some View {
        modifier(GlassmorphismModifier(intensity: intensity, cornerRadius: cornerRadius))
    }
    
    func appleShadow(_ shadow: Shadow = AppleShadows.medium) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func applePadding(_ spacing: CGFloat = AppleSpacing.md) -> some View {
        padding(spacing)
    }
    
    func appleCornerRadius(_ radius: CGFloat = AppleCornerRadius.md) -> some View {
        cornerRadius(radius)
    }
}

// MARK: - Button Styles

struct AppleButtonStyle: ButtonStyle {
    let variant: ButtonVariant
    let size: ButtonSize
    
    enum ButtonVariant {
        case primary
        case secondary
        case tertiary
        case destructive
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium: EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large: EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            }
        }
        
        var font: Font {
            switch self {
            case .small: AppleTypography.footnoteEmphasized
            case .medium: AppleTypography.bodyEmphasized
            case .large: AppleTypography.headline
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(textColor)
            .padding(size.padding)
            .background(backgroundView)
            .scaleEffect(1.0)
    }
    
    private var textColor: Color {
        switch variant {
        case .primary: .white
        case .secondary: AppleColors.textPrimary
        case .tertiary: AppleColors.accent
        case .destructive: .white
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
            .fill(backgroundColor)
            .appleShadow()
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary: AppleColors.primary
        case .secondary: AppleColors.surfaceSecondary
        case .tertiary: Color.clear
        case .destructive: AppleColors.error
        }
    }
}

// MARK: - Card Component

struct AppleCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    
    enum CardStyle {
        case elevated
        case filled
        case outlined
    }
    
    init(style: CardStyle = .elevated, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppleSpacing.md)
            .background(backgroundView)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
            .fill(backgroundColor)
            .overlay(overlayView)
            .appleShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated: AppleColors.surfaceSecondary
        case .filled: AppleColors.surfaceTertiary
        case .outlined: Color.clear
        }
    }
    
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
            .stroke(AppleColors.glassLight, lineWidth: 1)
    }
    
    private var shadow: Shadow {
        switch style {
        case .elevated: AppleShadows.medium
        case .filled: AppleShadows.light
        case .outlined: AppleShadows.light
        }
    }
}

// MARK: - List Row Component

struct AppleListRow<Content: View>: View {
    let content: Content
    let action: (() -> Void)?
    
    init(action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: AppleSpacing.md) {
                content
                
                if action != nil {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.textTertiary)
                }
            }
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(AppleColors.textPrimary)
    }
}

// MARK: - Navigation Bar Style

struct AppleNavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppleColors.surface, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func appleNavigationBar() -> some View {
        modifier(AppleNavigationBarStyle())
    }
}

// MARK: - Tab Bar Style

struct AppleTabBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(AppleColors.surface, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
    }
}

extension View {
    func appleTabBar() -> some View {
        modifier(AppleTabBarStyle())
    }
}

// MARK: - Accessibility Extensions

extension View {
    func appleAccessibility(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label ?? "")
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
}

// MARK: - Dynamic Type Support

extension View {
    func appleDynamicType() -> some View {
        dynamicTypeSize(.small ... .accessibility3)
    }
}

// MARK: - RTL Support

extension View {
    func appleRTL() -> some View {
        environment(\.layoutDirection, .leftToRight)
    }
}
