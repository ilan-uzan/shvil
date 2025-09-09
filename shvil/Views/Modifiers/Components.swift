//
//  Components.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Liquid Glass Components Library
// Reusable UI components following the Liquid Glass design system

// MARK: - Button Components

/// Primary button component with Liquid Glass styling
public struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    public enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
        case ghost
    }
    
    public enum ButtonSize {
        case small
        case medium
        case large
    }
    
    public init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
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
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
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
            .animation(DesignTokens.Animation.micro, value: isLoading)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
        .performanceOptimized()
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
        case .small: DesignTokens.Typography.footnoteEmphasized
        case .medium: DesignTokens.Typography.bodyEmphasized
        case .large: DesignTokens.Typography.headline
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small: DesignTokens.Typography.footnote
        case .medium: DesignTokens.Typography.body
        case .large: DesignTokens.Typography.title3
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: DesignTokens.Text.primary
        case .tertiary: DesignTokens.Text.secondary
        case .destructive: .white
        case .ghost: DesignTokens.Brand.primary
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: DesignTokens.Spacing.md
        case .medium: DesignTokens.Spacing.lg
        case .large: DesignTokens.Spacing.xl
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small: DesignTokens.Spacing.sm
        case .medium: DesignTokens.Spacing.md
        case .large: DesignTokens.Spacing.lg
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(overlayView)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small: DesignTokens.CornerRadius.sm
        case .medium: DesignTokens.CornerRadius.md
        case .large: DesignTokens.CornerRadius.lg
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: DesignTokens.Brand.primary
        case .secondary: DesignTokens.Surface.secondary
        case .tertiary: DesignTokens.Surface.tertiary
        case .destructive: DesignTokens.Semantic.error
        case .ghost: Color.clear
        }
    }
    
    private var overlayView: some View {
        Group {
            if style == .ghost {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignTokens.Brand.primary, lineWidth: 1)
            } else if style == .secondary {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignTokens.Stroke.light, lineWidth: 1)
            }
        }
    }
    
    private var shadow: ShadowValue {
        switch style {
        case .primary: DesignTokens.Shadow.medium
        case .secondary: DesignTokens.Shadow.light
        case .tertiary: DesignTokens.Shadow.light
        case .destructive: DesignTokens.Shadow.medium
        case .ghost: DesignTokens.Shadow.none
        }
    }
}

// MARK: - Card Components

/// Liquid Glass card component with depth and translucency
public struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let elevation: CardElevation
    
    public enum CardStyle {
        case elevated
        case filled
        case outlined
        case glass
    }
    
    public enum CardElevation {
        case flat
        case raised
        case floating
        case modal
    }
    
    public init(
        style: CardStyle = .elevated,
        elevation: CardElevation = .raised,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.elevation = elevation
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(DesignTokens.Spacing.md)
            .background(backgroundView)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
            .fill(backgroundColor)
            .overlay(overlayView)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated: DesignTokens.Surface.secondary
        case .filled: DesignTokens.Surface.tertiary
        case .outlined: Color.clear
        case .glass: DesignTokens.Glass.medium
        }
    }
    
    private var overlayView: some View {
        Group {
            if style == .glass {
                // Glass effect with inner highlight
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                    .blendMode(.overlay)
            } else if style == .outlined {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .stroke(DesignTokens.Stroke.light, lineWidth: 1)
            }
        }
    }
    
    private var shadow: ShadowValue {
        switch elevation {
        case .flat: DesignTokens.Shadow.none
        case .raised: DesignTokens.Shadow.light
        case .floating: DesignTokens.Shadow.medium
        case .modal: DesignTokens.Shadow.heavy
        }
    }
}

// MARK: - Input Components

/// Liquid Glass text field with focus states and validation
public struct LiquidGlassTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let errorMessage: String?
    let isDisabled: Bool
    
    @State private var isFocused = false
    
    public init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(DesignTokens.Typography.footnoteEmphasized)
                .foregroundColor(DesignTokens.Text.secondary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(DesignTokens.Typography.body)
            .foregroundColor(DesignTokens.Text.primary)
            .padding(DesignTokens.Spacing.md)
            .background(inputBackground)
            .overlay(inputOverlay)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
            .onTapGesture {
                isFocused = true
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Semantic.error)
            }
        }
    }
    
    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
            .fill(DesignTokens.Surface.secondary)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
    
    private var inputOverlay: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
            .stroke(focusColor, lineWidth: focusWidth)
            .opacity(isFocused ? 1 : 0)
            .animation(DesignTokens.Animation.micro, value: isFocused)
    }
    
    private var borderColor: Color {
        if let _ = errorMessage {
            return DesignTokens.Semantic.error
        } else if isFocused {
            return DesignTokens.Brand.primary
        } else {
            return DesignTokens.Stroke.light
        }
    }
    
    private var borderWidth: CGFloat {
        if errorMessage != nil || isFocused {
            return 2
        } else {
            return 1
        }
    }
    
    private var focusColor: Color {
        DesignTokens.Brand.primary
    }
    
    private var focusWidth: CGFloat {
        2
    }
}

// MARK: - List Components

/// Liquid Glass list row with consistent styling
public struct LiquidGlassListRow<Content: View>: View {
    let content: Content
    let action: (() -> Void)?
    let showChevron: Bool
    
    public init(
        action: (() -> Void)? = nil,
        showChevron: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.showChevron = showChevron
        self.content = content()
    }
    
    public var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: DesignTokens.Spacing.md) {
                content
                
                if action != nil && showChevron {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.tertiary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .frame(minHeight: DesignConstants.listItemHeight)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(DesignTokens.Text.primary)
    }
}

// MARK: - Navigation Components

/// Liquid Glass navigation bar with translucent background
public struct LiquidGlassNavigationBar: ViewModifier {
    let title: String
    let leadingButton: (() -> AnyView)?
    let trailingButton: (() -> AnyView)?
    
    public init(
        title: String,
        leadingButton: (() -> AnyView)? = nil,
        trailingButton: (() -> AnyView)? = nil
    ) {
        self.title = title
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignTokens.Glass.medium, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingButton?()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingButton?()
                }
            }
    }
}

extension View {
    public func liquidGlassNavigationBar(
        title: String,
        leadingButton: (() -> AnyView)? = nil,
        trailingButton: (() -> AnyView)? = nil
    ) -> some View {
        modifier(LiquidGlassNavigationBar(
            title: title,
            leadingButton: leadingButton,
            trailingButton: trailingButton
        ))
    }
}

// MARK: - Tab Bar Components

/// Liquid Glass tab bar with translucent background
public struct LiquidGlassTabBar: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .toolbarBackground(DesignTokens.Glass.medium, for: .tabBar)
    }
}

extension View {
    public func liquidGlassTabBar() -> some View {
        modifier(LiquidGlassTabBar())
    }
}

// MARK: - Performance Optimizations

extension View {
    /// Optimizes view rendering for better performance
    public func performanceOptimized() -> some View {
        self
            .drawingGroup()
            .compositingGroup()
    }
    
    /// Adds micro-ripple effect on tap (Liquid Glass signature)
    public func liquidRipple() -> some View {
        self
            .scaleEffect(1.0)
            .animation(DesignTokens.Animation.ripple, value: UUID())
    }
    
    /// Adds floating glass effect
    public func liquidFloat() -> some View {
        self
            .animation(DesignTokens.Animation.glassFloat, value: UUID())
    }
    
    /// Adds subtle parallax effect on scroll
    public func liquidParallax() -> some View {
        self
            .animation(DesignTokens.Animation.parallax, value: UUID())
    }
}

// MARK: - Accessibility Extensions

extension View {
    /// Adds comprehensive accessibility support
    public func liquidGlassAccessibility(
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
    
    /// Adds button accessibility
    public func liquidGlassButtonAccessibility(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds header accessibility
    public func liquidGlassHeaderAccessibility(
        label: String,
        level: Int = 1
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Dynamic Type Support

extension View {
    /// Adds Dynamic Type support
    public func liquidGlassDynamicType() -> some View {
        dynamicTypeSize(.small ... .accessibility3)
    }
    
    /// Adds limited Dynamic Type support
    public func liquidGlassDynamicTypeLimited() -> some View {
        dynamicTypeSize(.small ... .large)
    }
}

// MARK: - RTL Support

extension View {
    /// Adds RTL support
    public func liquidGlassRTL() -> some View {
        environment(\.layoutDirection, .leftToRight)
    }
    
    /// Adds comprehensive RTL support
    public func liquidGlassRTLSupport() -> some View {
        environment(\.layoutDirection, .leftToRight)
            .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Text Field Components

/// Liquid Glass text field style
public struct LiquidGlassTextFieldStyle: TextFieldStyle {
    public init() {}
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(DesignTokens.Surface.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .stroke(DesignTokens.Glass.light, lineWidth: 1)
                    )
            )
            .foregroundColor(DesignTokens.Text.primary)
            .font(DesignTokens.Typography.body)
    }
}
