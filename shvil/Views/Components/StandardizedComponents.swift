//
//  StandardizedComponents.swift
//  shvil
//
//  Unified component library using LandmarkLiquidGlass design system
//

import SwiftUI

// MARK: - Standardized Glass Components

/// Unified glass card component with consistent LandmarkLiquidGlass styling
public struct GlassCard<Content: View>: View {
    let content: Content
    let style: GlassCardStyle
    let elevation: GlassElevation
    let isInteractive: Bool
    
    public enum GlassCardStyle {
        case primary
        case secondary
        case tertiary
        case floating
        case modal
    }
    
    public enum GlassElevation {
        case flat
        case raised
        case floating
        case modal
    }
    
    public init(
        style: GlassCardStyle = .primary,
        elevation: GlassElevation = .raised,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.elevation = elevation
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(DesignTokens.Spacing.lg)
            .background(backgroundView)
            .scaleEffect(isInteractive ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.micro, value: isInteractive)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
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
        case .primary: DesignTokens.Surface.adaptiveGlass
        case .secondary: DesignTokens.Surface.adaptiveGlass.opacity(0.8)
        case .tertiary: DesignTokens.Surface.adaptiveGlass.opacity(0.6)
        case .floating: DesignTokens.Surface.adaptiveGlass
        case .modal: DesignTokens.Surface.adaptiveGlass
        }
    }
    
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
            .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
            .blendMode(.overlay)
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

/// Unified glass button component with consistent styling
public struct GlassButton: View {
    let title: String
    let icon: String?
    let style: GlassButtonStyle
    let size: GlassButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    public enum GlassButtonStyle {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    public enum GlassButtonSize {
        case small
        case medium
        case large
    }
    
    public init(
        _ title: String,
        icon: String? = nil,
        style: GlassButtonStyle = .primary,
        size: GlassButtonSize = .medium,
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
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(textFont)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: DesignTokens.Layout.minTouchTarget)
            .background(backgroundView)
            .overlay(overlayView)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(DesignTokens.Animation.micro, value: isDisabled)
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: DesignTokens.Text.primary
        case .ghost: DesignTokens.Brand.primary
        case .destructive: .white
        }
    }
    
    private var textFont: Font {
        switch size {
        case .small: DesignTokens.Typography.callout
        case .medium: DesignTokens.Typography.body
        case .large: DesignTokens.Typography.headline
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small: .system(size: 14, weight: .medium)
        case .medium: .system(size: 16, weight: .medium)
        case .large: .system(size: 18, weight: .medium)
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
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg, style: .continuous)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: DesignTokens.Brand.primary
        case .secondary: DesignTokens.Surface.adaptiveGlass
        case .ghost: Color.clear
        case .destructive: DesignTokens.Semantic.error
        }
    }
    
    private var overlayView: some View {
        if style == .secondary || style == .ghost {
            return AnyView(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg, style: .continuous)
                    .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                    .blendMode(.overlay)
            )
        }
        return AnyView(EmptyView())
    }
    
    private var shadow: ShadowValue {
        switch style {
        case .primary: DesignTokens.Shadow.medium
        case .secondary: DesignTokens.Shadow.light
        case .ghost: DesignTokens.Shadow.none
        case .destructive: DesignTokens.Shadow.medium
        }
    }
}

/// Glass search bar component
public struct GlassSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let isFocused: Binding<Bool>
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        isFocused: Binding<Bool> = .constant(false)
    ) {
        self._text = text
        self.placeholder = placeholder
        self._isFocused = isFocused
    }
    
    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignTokens.Text.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
                .onTapGesture {
                    isFocused.wrappedValue = true
                }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignTokens.Text.tertiary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                .fill(DesignTokens.Surface.adaptiveGlass)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                        .blendMode(.overlay)
                )
        )
        .shadow(
            color: DesignTokens.Shadow.light.color,
            radius: DesignTokens.Shadow.light.radius,
            x: DesignTokens.Shadow.light.x,
            y: DesignTokens.Shadow.light.y
        )
    }
}

/// Glass pill component for filters and tags
public struct GlassPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        _ title: String,
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignTokens.Typography.callout)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(textColor)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(backgroundView)
                .overlay(overlayView)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(DesignTokens.Animation.micro, value: isSelected)
    }
    
    private var textColor: Color {
        isSelected ? DesignTokens.Brand.primary : DesignTokens.Text.secondary
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.round, style: .continuous)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        isSelected ? DesignTokens.Surface.adaptiveGlass : DesignTokens.Surface.adaptiveGlass.opacity(0.6)
    }
    
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.round, style: .continuous)
            .stroke(
                isSelected ? DesignTokens.Brand.primary : DesignTokens.Glass.innerHighlight,
                lineWidth: isSelected ? 1.0 : 0.5
            )
            .blendMode(.overlay)
    }
}

/// Glass list row component
public struct GlassListRow<Content: View>: View {
    let content: Content
    let isInteractive: Bool
    let action: (() -> Void)?
    
    public init(
        isInteractive: Bool = true,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isInteractive = isInteractive
        self.action = action
    }
    
    public var body: some View {
        Button(action: action ?? {}) {
            content
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg, style: .continuous)
                        .fill(DesignTokens.Surface.adaptiveGlass.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg, style: .continuous)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                                .blendMode(.overlay)
                        )
                )
        }
        .disabled(!isInteractive || action == nil)
        .opacity(isInteractive ? 1.0 : 0.6)
        .scaleEffect(isInteractive ? 1.0 : 0.98)
        .animation(DesignTokens.Animation.micro, value: isInteractive)
    }
}

/// Glass section header component
public struct GlassSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    public init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignTokens.Typography.callout)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                GlassButton(
                    actionTitle,
                    style: .ghost,
                    size: .small,
                    action: action
                )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }
}

/// Glass empty state component
public struct GlassEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(DesignTokens.Text.tertiary)
            
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(title)
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(DesignTokens.Text.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                GlassButton(
                    actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                .fill(DesignTokens.Surface.adaptiveGlass.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                        .blendMode(.overlay)
                )
        )
        .shadow(
            color: DesignTokens.Shadow.light.color,
            radius: DesignTokens.Shadow.light.radius,
            x: DesignTokens.Shadow.light.x,
            y: DesignTokens.Shadow.light.y
        )
    }
}

/// Glass loading state component
public struct GlassLoadingState: View {
    let message: String
    
    public init(_ message: String = "Loading...") {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Brand.primary))
            
            Text(message)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                .fill(DesignTokens.Surface.adaptiveGlass.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl, style: .continuous)
                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                        .blendMode(.overlay)
                )
        )
        .shadow(
            color: DesignTokens.Shadow.light.color,
            radius: DesignTokens.Shadow.light.radius,
            x: DesignTokens.Shadow.light.x,
            y: DesignTokens.Shadow.light.y
        )
    }
}

/// Glass Floating Action Button (FAB) component
public struct GlassFAB: View {
    let icon: String
    let size: FABSize
    let style: FABStyle
    let action: () -> Void
    
    public enum FABSize {
        case small
        case medium
        case large
    }
    
    public enum FABStyle {
        case primary
        case secondary
        case ghost
    }
    
    public init(
        icon: String,
        size: FABSize = .medium,
        style: FABStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(iconFont)
                .foregroundColor(iconColor)
                .frame(width: frameSize, height: frameSize)
                .background(backgroundView)
                .shadow(
                    color: shadow.color,
                    radius: shadow.radius,
                    x: shadow.x,
                    y: shadow.y
                )
        }
        .minimumTouchTarget()
        .scaleEffect(1.0)
        .animation(DesignTokens.Animation.micro, value: false)
    }
    
    private var iconFont: Font {
        switch size {
        case .small: .system(size: 16, weight: .medium)
        case .medium: .system(size: 18, weight: .medium)
        case .large: .system(size: 20, weight: .medium)
        }
    }
    
    private var frameSize: CGFloat {
        switch size {
        case .small: 44
        case .medium: 56
        case .large: 64
        }
    }
    
    private var iconColor: Color {
        switch style {
        case .primary: .white
        case .secondary: DesignTokens.Text.primary
        case .ghost: DesignTokens.Brand.primary
        }
    }
    
    private var backgroundView: some View {
        Circle()
            .fill(backgroundColor)
            .overlay(overlayView)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: DesignTokens.Brand.primary
        case .secondary: DesignTokens.Surface.adaptiveGlass
        case .ghost: Color.clear
        }
    }
    
    private var overlayView: some View {
        if style == .secondary {
            return AnyView(
                Circle()
                    .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                    .blendMode(.overlay)
            )
        }
        return AnyView(EmptyView())
    }
    
    private var shadow: ShadowValue {
        switch style {
        case .primary: DesignTokens.Shadow.medium
        case .secondary: DesignTokens.Shadow.light
        case .ghost: DesignTokens.Shadow.none
        }
    }
}

// MARK: - Preview Helpers

#Preview("Glass Components") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Glass Card
            GlassCard(style: .primary) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Glass Card")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text("This is a standardized glass card component with consistent styling.")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }
            
            // Glass Buttons
            HStack(spacing: DesignTokens.Spacing.md) {
                GlassButton("Primary", style: .primary) { }
                GlassButton("Secondary", style: .secondary) { }
                GlassButton("Ghost", style: .ghost) { }
            }
            
            // Glass Search Bar
            GlassSearchBar(text: .constant(""), placeholder: "Search places...")
            
            // Glass Pills
            HStack(spacing: DesignTokens.Spacing.sm) {
                GlassPill("All", isSelected: true) { }
                GlassPill("Nearby", isSelected: false) { }
                GlassPill("Adventure", isSelected: false) { }
            }
            
            // Glass Empty State
            GlassEmptyState(
                icon: "location.slash",
                title: "No Results",
                description: "Try adjusting your search or filters to find what you're looking for.",
                actionTitle: "Clear Filters",
                action: { }
            )
        }
        .padding(DesignTokens.Spacing.lg)
    }
    .background(DesignTokens.Surface.background)
}
