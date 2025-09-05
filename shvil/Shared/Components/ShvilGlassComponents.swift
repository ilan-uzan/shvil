//
//  ShvilGlassComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Shvil Brand Glass Components
// Enhanced glassmorphism components with icy ocean blue theme and wavy path motif

// MARK: - Wavy Path Motif Component

struct WavyPathMotif: View {
    let style: WavyStyle
    let color: Color
    
    enum WavyStyle {
        case subtle
        case medium
        case prominent
    }
    
    init(style: WavyStyle = .medium, color: Color = AppleColors.brandPrimary) {
        self.style = style
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Create wavy path inspired by the app icon's "S" curve
                path.move(to: CGPoint(x: 0, y: height * 0.3))
                
                // First curve (inspired by top of "S")
                path.addCurve(
                    to: CGPoint(x: width * 0.4, y: height * 0.1),
                    control1: CGPoint(x: width * 0.1, y: height * 0.05),
                    control2: CGPoint(x: width * 0.25, y: height * 0.02)
                )
                
                // Second curve (middle transition)
                path.addCurve(
                    to: CGPoint(x: width * 0.6, y: height * 0.5),
                    control1: CGPoint(x: width * 0.5, y: height * 0.2),
                    control2: CGPoint(x: width * 0.55, y: height * 0.35)
                )
                
                // Third curve (inspired by bottom of "S")
                path.addCurve(
                    to: CGPoint(x: width, y: height * 0.7),
                    control1: CGPoint(x: width * 0.75, y: height * 0.8),
                    control2: CGPoint(x: width * 0.9, y: height * 0.95)
                )
            }
            .stroke(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
    
    private var lineWidth: CGFloat {
        switch style {
        case .subtle: 1.5
        case .medium: 2.5
        case .prominent: 4.0
        }
    }
}

// MARK: - Enhanced Glass Button

struct ShvilGlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
    }
    
    @State private var isPressed = false
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppleSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(AppleTypography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, AppleSpacing.lg)
            .padding(.vertical, AppleSpacing.md)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(AppleAnimations.micro, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.round)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
            .overlay(
                // Inner highlight for depth
                RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                    .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                    .blendMode(.overlay)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: AppleColors.glassMedium
        case .secondary: AppleColors.glassLight
        case .tertiary: Color.clear
        case .destructive: AppleColors.danger.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: AppleColors.textPrimary
        case .secondary: AppleColors.textSecondary
        case .tertiary: AppleColors.brandPrimary
        case .destructive: AppleColors.danger
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary.opacity(0.3)
        case .secondary: AppleColors.strokeLight
        case .tertiary: AppleColors.brandPrimary
        case .destructive: AppleColors.danger.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        switch style {
        case .primary: 1.5
        case .secondary: 1.0
        case .tertiary: 1.5
        case .destructive: 1.0
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary.opacity(0.2)
        case .secondary: AppleColors.strokeHairline
        case .tertiary: Color.clear
        case .destructive: AppleColors.danger.opacity(0.2)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary: 12
        case .secondary: 6
        case .tertiary: 0
        case .destructive: 8
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .primary: 4
        case .secondary: 2
        case .tertiary: 0
        case .destructive: 3
        }
    }
}

// MARK: - Glass Search Field

struct ShvilSearchField: View {
    @Binding var text: String
    let placeholder: String
    let onVoiceSearch: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    init(text: Binding<String>, placeholder: String = "Search places...", onVoiceSearch: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onVoiceSearch = onVoiceSearch
    }
    
    var body: some View {
        HStack(spacing: AppleSpacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppleColors.textTertiary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textPrimary)
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppleColors.textTertiary)
                        .font(.system(size: 16))
                }
            }
            
            if let onVoiceSearch = onVoiceSearch {
                Button(action: onVoiceSearch) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(AppleColors.brandPrimary)
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.vertical, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                .fill(AppleColors.glassMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                        .stroke(isFocused ? AppleColors.brandPrimary : AppleColors.strokeHairline, lineWidth: isFocused ? 2 : 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                        .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                        .blendMode(.overlay)
                )
        )
        .shadow(color: AppleShadows.light.color, radius: AppleShadows.light.radius, x: AppleShadows.light.x, y: AppleShadows.light.y)
    }
}

// MARK: - Glass Chip Component

struct ShvilGlassChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(_ title: String, icon: String? = nil, isSelected: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppleSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(AppleTypography.callout)
                    .fontWeight(.medium)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.sm)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AppleAnimations.micro, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.round)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.round)
                    .stroke(AppleColors.glassInnerHighlight, lineWidth: 0.5)
                    .blendMode(.overlay)
            )
    }
    
    private var backgroundColor: Color {
        isSelected ? AppleColors.brandPrimary.opacity(0.15) : AppleColors.glassLight
    }
    
    private var textColor: Color {
        isSelected ? AppleColors.brandPrimary : AppleColors.textSecondary
    }
    
    private var strokeColor: Color {
        isSelected ? AppleColors.brandPrimary.opacity(0.3) : AppleColors.strokeHairline
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 1.5 : 1.0
    }
}

// MARK: - Glass Card Component

struct ShvilGlassCard<Content: View>: View {
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
            .padding(AppleSpacing.lg)
            .background(backgroundView)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                    .stroke(AppleColors.strokeHairline, lineWidth: 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                    .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                    .blendMode(.overlay)
            )
            .shadow(color: AppleShadows.medium.color, radius: AppleShadows.medium.radius, x: AppleShadows.medium.x, y: AppleShadows.medium.y)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated: AppleColors.glassMedium
        case .filled: AppleColors.glassHeavy
        case .outlined: Color.clear
        }
    }
}

// MARK: - Empty State Component

struct ShvilEmptyState: View {
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppleSpacing.lg) {
            // Wavy path illustration
            WavyPathMotif(style: .medium, color: AppleColors.brandPrimary)
                .frame(width: 120, height: 80)
                .opacity(0.6)
            
            VStack(spacing: AppleSpacing.sm) {
                Text(title)
                    .font(AppleTypography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppleColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            if let actionTitle = actionTitle, let action = action {
                ShvilGlassButton(actionTitle, style: .primary, action: action)
            }
        }
        .padding(AppleSpacing.xl)
    }
}

// MARK: - Loading Skeleton Component

struct ShvilLoadingSkeleton: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(width: CGFloat? = nil, height: CGFloat = 20, cornerRadius: CGFloat = AppleCornerRadius.sm) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        AppleColors.glassLight,
                        AppleColors.glassMedium,
                        AppleColors.glassLight
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Shimmer Effect

extension View {
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: UUID()
                )
        )
        .clipped()
    }
}
