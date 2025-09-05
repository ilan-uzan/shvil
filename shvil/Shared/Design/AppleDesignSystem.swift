//
//  AppleDesignSystem.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Apple Design System for Shvil
// Following Apple's Human Interface Guidelines and iOS Design Principles

// MARK: - Shvil Brand Color System (Icy Ocean Blue Theme)

enum AppleColors {
    // Brand Primary - Icy Ocean Blue Gradient (from app icon)
    static let brandPrimary = Color(red: 0.498, green: 0.827, blue: 1.0) // #7FD3FF
    static let brandPrimaryMid = Color(red: 0.224, green: 0.663, blue: 0.973) // #39A9F8
    static let brandPrimaryDark = Color(red: 0.059, green: 0.498, blue: 0.871) // #0F7FDE
    
    // Brand Gradient
    static let brandGradient = LinearGradient(
        colors: [brandPrimary, brandPrimaryMid, brandPrimaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Semantic Colors
    static let success = Color(red: 0.137, green: 0.769, blue: 0.514) // #23C483
    static let warning = Color(red: 1.0, green: 0.784, blue: 0.341) // #FFC857
    static let danger = Color(red: 1.0, green: 0.420, blue: 0.420) // #FF6B6B
    static let error = Color(red: 1.0, green: 0.420, blue: 0.420) // #FF6B6B - Same as danger
    static let info = brandPrimaryMid
    
    // Surface Colors - Light, glassy theme
    static let background = Color(red: 0.98, green: 0.98, blue: 0.99) // Near white
    static let surface = Color.white.opacity(0.55) // Glass surface
    static let surfacePrimary = Color.white.opacity(0.55) // Primary glass surface
    static let surfaceSecondary = Color.white.opacity(0.45) // Secondary glass
    static let surfaceTertiary = Color.white.opacity(0.35) // Tertiary glass
    
    // Text Colors - Near black on light
    static let textPrimary = Color(red: 0.043, green: 0.043, blue: 0.047) // #0B0B0C at 80-90%
    static let textSecondary = Color(red: 0.227, green: 0.227, blue: 0.251) // #3A3A40 at 70%
    static let textTertiary = Color(red: 0.227, green: 0.227, blue: 0.251).opacity(0.6)
    static let textQuaternary = Color(red: 0.227, green: 0.227, blue: 0.251).opacity(0.4)
    
    // Glass Colors - Enhanced glassmorphism
    static let glassLight = Color.white.opacity(0.55) // Frosted glass
    static let glassMedium = Color.white.opacity(0.65) // Medium glass
    static let glassHeavy = Color.white.opacity(0.75) // Heavy glass
    static let glassInnerHighlight = Color.white.opacity(0.06) // Inner highlight
    
    // Stroke Colors
    static let strokeHairline = Color.black.opacity(0.06) // Hairline stroke
    static let strokeLight = Color.black.opacity(0.12) // Light stroke
    static let strokeMedium = Color.black.opacity(0.18) // Medium stroke
    
    // Accent Colors
    static let accent = brandPrimary
    static let accentSecondary = brandPrimaryMid
    
    // Accessibility Colors
    static let accessibilitySuccess = Color(red: 0.137, green: 0.769, blue: 0.514) // High contrast green
    static let accessibilityWarning = Color(red: 1.0, green: 0.784, blue: 0.341) // High contrast orange
    static let accessibilityDanger = Color(red: 1.0, green: 0.420, blue: 0.420) // High contrast red
    static let accessibilityInfo = brandPrimaryMid // High contrast blue
    
    // High Contrast Colors
    static let highContrastPrimary = Color.primary
    static let highContrastSecondary = Color.secondary
    static let highContrastBackground = Color(.systemBackground)
    static let highContrastSurface = Color(.secondarySystemBackground)
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
    static let bodySemibold = Font.system(.body, design: .default).weight(.semibold)
    
    // Callout (16pt, regular)
    static let callout = Font.system(.callout, design: .default)
    
    // Subheadline (15pt, regular)
    static let subheadline = Font.system(.subheadline, design: .default)
    
    // Footnote (13pt, regular)
    static let footnote = Font.system(.footnote, design: .default)
    static let footnoteEmphasized = Font.system(.footnote, design: .default).weight(.medium)
    
    // Caption 1 (12pt, regular)
    static let caption1 = Font.system(.caption, design: .default)
    static let caption1Medium = Font.system(.caption, design: .default).weight(.medium)
    
    // Caption 2 (11pt, regular)
    static let caption2 = Font.system(.caption2, design: .default)
    
    // Accessibility Typography - Enhanced for better readability
    static let accessibilityLargeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    static let accessibilityTitle1 = Font.system(.title, design: .default).weight(.bold)
    static let accessibilityTitle2 = Font.system(.title2, design: .default).weight(.bold)
    static let accessibilityTitle3 = Font.system(.title3, design: .default).weight(.bold)
    static let accessibilityHeadline = Font.system(.headline, design: .default).weight(.semibold)
    static let accessibilityBody = Font.system(.body, design: .default).weight(.regular)
    static let accessibilityCallout = Font.system(.callout, design: .default).weight(.regular)
    static let accessibilitySubheadline = Font.system(.subheadline, design: .default).weight(.regular)
    static let accessibilityFootnote = Font.system(.footnote, design: .default).weight(.regular)
    static let accessibilityCaption1 = Font.system(.caption, design: .default).weight(.regular)
    static let accessibilityCaption2 = Font.system(.caption2, design: .default).weight(.regular)
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

// MARK: - Corner Radius System (20-24pt for cards)

enum AppleCornerRadius {
    static let xs: CGFloat = 4    // 4pt
    static let sm: CGFloat = 8    // 8pt
    static let md: CGFloat = 12   // 12pt
    static let lg: CGFloat = 16   // 16pt
    static let xl: CGFloat = 20   // 20pt - Card radius
    static let xxl: CGFloat = 24  // 24pt - Large card radius
    static let round: CGFloat = 50 // 50% for circular elements
}

// MARK: - Shadow System (Soft multi-layer shadows)

enum AppleShadows {
    // No shadow
    static let none = Shadow(color: Color.clear, radius: 0, x: 0, y: 0)
    
    // Soft shadows for glassmorphism
    static let light = Shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    static let medium = Shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    static let heavy = Shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 8)
    static let glass = Shadow(color: AppleColors.brandPrimary.opacity(0.08), radius: 24, x: 0, y: 12)
    
    // Inner shadows for depth
    static let innerLight = Shadow(color: AppleColors.glassInnerHighlight, radius: 2, x: 0, y: 1)
    static let innerMedium = Shadow(color: AppleColors.glassInnerHighlight, radius: 4, x: 0, y: 2)
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
    static let microInteraction = Animation.easeInOut(duration: 0.15)
    
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

// MARK: - Enhanced Glassmorphism Modifier
// Following Apple's Human Interface Guidelines for glassmorphism

struct GlassmorphismModifier: ViewModifier {
    let intensity: GlassIntensity
    let cornerRadius: CGFloat
    let isInteractive: Bool
    let elevation: GlassElevation
    
    enum GlassIntensity {
        case light
        case medium
        case heavy
    }
    
    enum GlassElevation {
        case flat
        case raised
        case floating
        case modal
    }
    
    init(intensity: GlassIntensity = .medium, cornerRadius: CGFloat = AppleCornerRadius.xl, isInteractive: Bool = false, elevation: GlassElevation = .raised) {
        self.intensity = intensity
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.elevation = elevation
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Backdrop blur effect - Apple's recommended approach
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(backdropOpacity)
                    
                    // Glass surface with proper layering
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(glassColor)
                        .overlay(
                            // Inner highlight for depth - Apple's specular highlight
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                        .overlay(
                            // Outer stroke for definition
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(AppleColors.strokeHairline, lineWidth: 0.5)
                        )
                        .overlay(
                            // Interactive state overlay
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(isInteractive ? Color.white.opacity(0.1) : Color.clear)
                                .opacity(isInteractive ? 1 : 0)
                        )
                }
            )
            .shadow(color: AppleShadows.glass.color, radius: AppleShadows.glass.radius, x: AppleShadows.glass.x, y: AppleShadows.glass.y)
            .shadow(color: AppleShadows.medium.color, radius: AppleShadows.medium.radius, x: AppleShadows.medium.x, y: AppleShadows.medium.y)
            .shadow(color: elevationShadow.color, radius: elevationShadow.radius, x: elevationShadow.x, y: elevationShadow.y)
    }
    
    private var glassColor: Color {
        switch intensity {
        case .light: AppleColors.glassLight
        case .medium: AppleColors.glassMedium
        case .heavy: AppleColors.glassHeavy
        }
    }
    
    private var backdropOpacity: Double {
        switch intensity {
        case .light: 0.6
        case .medium: 0.8
        case .heavy: 0.9
        }
    }
    
    private var elevationShadow: Shadow {
        switch elevation {
        case .flat: AppleShadows.none
        case .raised: AppleShadows.light
        case .floating: AppleShadows.medium
        case .modal: AppleShadows.heavy
        }
    }
}

// MARK: - View Extensions

extension View {
    func glassmorphism(intensity: GlassmorphismModifier.GlassIntensity = .medium, cornerRadius: CGFloat = AppleCornerRadius.xl, isInteractive: Bool = false, elevation: GlassmorphismModifier.GlassElevation = .raised) -> some View {
        modifier(GlassmorphismModifier(intensity: intensity, cornerRadius: cornerRadius, isInteractive: isInteractive, elevation: elevation))
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

// MARK: - Button Components

struct AppleButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyleType
    let size: ButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    enum ButtonStyleType {
        case primary
        case secondary
        case destructive
        case ghost
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyleType = .primary,
        size: ButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppleSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(iconFont)
                        .fontWeight(.medium)
                }
                
                Text(title)
                    .font(buttonFont)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView)
            .opacity(isDisabled ? 0.6 : 1.0)
            .disabled(isDisabled || isLoading)
            .scaleEffect(isLoading ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isLoading)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
    }
    
    private var accessibilityHint: String {
        if isLoading {
            return "Loading"
        } else if isDisabled {
            return "Disabled"
        } else {
            return "Button"
        }
    }
    
    private var buttonFont: Font {
        switch size {
        case .small: AppleTypography.footnoteEmphasized
        case .medium: AppleTypography.bodyEmphasized
        case .large: AppleTypography.headline
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small: AppleTypography.footnote
        case .medium: AppleTypography.body
        case .large: AppleTypography.title3
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: AppleColors.textPrimary
        case .destructive: .white
        case .ghost: AppleColors.brandPrimary
        }
    }
    
    private var pressedTextColor: Color {
        switch style {
        case .primary: .white.opacity(0.8)
        case .secondary: AppleColors.textSecondary
        case .destructive: .white.opacity(0.8)
        case .ghost: AppleColors.brandPrimary.opacity(0.8)
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: AppleSpacing.md
        case .medium: AppleSpacing.lg
        case .large: AppleSpacing.xl
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small: AppleSpacing.sm
        case .medium: AppleSpacing.md
        case .large: AppleSpacing.lg
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(overlayView)
            .appleShadow(shadow)
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small: AppleCornerRadius.sm
        case .medium: AppleCornerRadius.md
        case .large: AppleCornerRadius.lg
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary
        case .secondary: AppleColors.surfaceSecondary
        case .destructive: AppleColors.danger
        case .ghost: Color.clear
        }
    }
    
    private var pressedBackgroundColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary.opacity(0.8)
        case .secondary: AppleColors.surfaceTertiary
        case .destructive: AppleColors.danger.opacity(0.8)
        case .ghost: AppleColors.brandPrimary.opacity(0.1)
        }
    }
    
    private var overlayView: some View {
        Group {
            if style == .ghost {
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .stroke(AppleColors.brandPrimary, lineWidth: 1)
            } else if style == .secondary {
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .stroke(AppleColors.strokeLight, lineWidth: 1)
            }
        }
    }
    
    private var shadow: Shadow {
        switch style {
        case .primary: AppleShadows.medium
        case .secondary: AppleShadows.light
        case .destructive: AppleShadows.medium
        case .ghost: AppleShadows.none
        }
    }
    
    private var pressedShadow: Shadow {
        switch style {
        case .primary: AppleShadows.light
        case .secondary: AppleShadows.none
        case .destructive: AppleShadows.light
        case .ghost: AppleShadows.none
        }
    }
    
    private func paddingForSize(_ size: ButtonSize) -> (horizontal: CGFloat, vertical: CGFloat) {
        switch size {
        case .small: return (AppleSpacing.md, AppleSpacing.sm)
        case .medium: return (AppleSpacing.lg, AppleSpacing.md)
        case .large: return (AppleSpacing.xl, AppleSpacing.lg)
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
    
    func appleAccessibilityButton(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    func appleAccessibilityHeader(
        label: String,
        level: Int = 1
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }
    
    func appleAccessibilityImage(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isImage)
    }
    
    func appleAccessibilityToggle(
        label: String,
        hint: String? = nil,
        isOn: Bool
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(isOn ? "On" : "Off")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Dynamic Type Support

extension View {
    func appleDynamicType() -> some View {
        dynamicTypeSize(.small ... .accessibility3)
    }
    
    func appleDynamicTypeLimited() -> some View {
        dynamicTypeSize(.small ... .large)
    }
    
    func appleDynamicTypeAccessibility() -> some View {
        dynamicTypeSize(.small ... .accessibility5)
    }
}

// MARK: - RTL Support

extension View {
    func appleRTL() -> some View {
        environment(\.layoutDirection, .leftToRight)
    }
    
    func appleRTLSupport() -> some View {
        environment(\.layoutDirection, .leftToRight)
            .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - VoiceOver Support

extension View {
    func appleVoiceOverHint(_ hint: String) -> some View {
        self
            .accessibilityHint(hint)
    }
}

// MARK: - Accessibility Extensions

extension View {
    func buttonAccessibility(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Glass Elevation

enum GlassElevation {
    case light
    case low
    case medium
    case high
    
    var opacity: Double {
        switch self {
        case .light: return 0.05
        case .low: return 0.1
        case .medium: return 0.2
        case .high: return 0.3
        }
    }
}
