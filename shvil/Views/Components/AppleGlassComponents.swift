//
//  AppleGlassComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Design System Integration
// Note: applePerformanceOptimized, appleAccessibility, and appleShadow are defined in DesignSystemViewModifiers.swift

public struct AppleAnimations {
    public static let micro = Animation.easeInOut(duration: 0.15)
    public static let microInteraction = Animation.easeInOut(duration: 0.15)
    public static let standard = Animation.easeInOut(duration: 0.25)
    public static let complex = Animation.easeInOut(duration: 0.4)
}

public struct AppleCornerRadius {
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let xxl: CGFloat = 24
}

// MARK: - Apple Glass Components Library
// Comprehensive glassmorphism components following Apple Design Guidelines

// MARK: - Type Aliases

typealias AppleButton = AppleGlassButton
typealias AppleTypography = DesignTokens.Typography

// MARK: - Apple List Row Component

struct AppleListRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Layout.cornerRadius)
                    .fill(DesignTokens.Surface.secondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Layout.cornerRadius)
                    .stroke(DesignTokens.Stroke.light, lineWidth: 0.5)
            )
    }
}

// MARK: - Glass Button Component

struct AppleGlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let size: ButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    
    @State private var isPressed = false
    
    enum ButtonStyle {
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
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: shvil.DesignTokens.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                } else if let icon {
                    Image(systemName: icon)
                        .font(iconFont)
                }
                
                Text(title)
                    .font(textFont)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: minHeight)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(shvil.DesignTokens.Animation.micro) {
                isPressed = pressing
            }
        }, perform: {})
        .appleAccessibility(
            label: title,
            hint: isLoading ? "Loading..." : "Double tap to activate"
        )
    }
    
    private var textFont: Font {
        switch size {
        case .small: AppleTypography.footnoteEmphasized
        case .medium: shvil.DesignTokens.Typography.bodyEmphasized
        case .large: shvil.DesignTokens.Typography.headline
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small: .system(size: 14, weight: .medium)
        case .medium: .system(size: 16, weight: .medium)
        case .large: .system(size: 18, weight: .medium)
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: shvil.DesignTokens.Text.primary
        case .destructive: .white
        case .ghost: shvil.DesignTokens.Brand.primary
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: shvil.DesignTokens.Spacing.md
        case .medium: shvil.DesignTokens.Spacing.lg
        case .large: shvil.DesignTokens.Spacing.xl
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small: shvil.DesignTokens.Spacing.sm
        case .medium: shvil.DesignTokens.Spacing.md
        case .large: shvil.DesignTokens.Spacing.lg
        }
    }
    
    private var minHeight: CGFloat {
        switch size {
        case .small: 32
        case .medium: 44
        case .large: 52
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
            .fill(backgroundColor)
            .overlay(overlayView)
            .appleShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: shvil.DesignTokens.Brand.primary
        case .secondary: shvil.DesignTokens.Surface.secondary
        case .destructive: shvil.DesignTokens.Semantic.error
        case .ghost: Color.clear
        }
    }
    
    private var overlayView: some View {
        Group {
            if style == .ghost {
                RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
                    .stroke(shvil.DesignTokens.Brand.primary, lineWidth: 1)
            } else if style == .secondary {
                RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
                    .stroke(shvil.DesignTokens.Stroke.light, lineWidth: 1)
            }
        }
    }
    
    private var shadow: ShadowValue {
        switch style {
        case .primary: shvil.DesignTokens.Shadow.medium
        case .secondary: shvil.DesignTokens.Shadow.light
        case .destructive: shvil.DesignTokens.Shadow.medium
        case .ghost: shvil.DesignTokens.Shadow.none
        }
    }
}

// MARK: - Glass Card Component

struct AppleGlassCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let isInteractive: Bool
    
    enum CardStyle {
        case elevated
        case filled
        case outlined
        case floating
    }
    
    init(style: CardStyle = .elevated, isInteractive: Bool = false, @ViewBuilder content: () -> Content) {
        self.style = style
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(shvil.DesignTokens.Spacing.md)
            .background(backgroundView)
            .appleShadow(shadow)
            .applePerformanceOptimized() // Add performance optimization
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xl)
            .fill(
                LinearGradient(
                    colors: [
                        backgroundColor,
                        backgroundColor.opacity(0.8),
                        backgroundColor
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(overlayView)
            .overlay(
                // Inner highlight for depth
                RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xl)
                    .stroke(shvil.DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                    .offset(x: 1, y: 1)
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated: shvil.DesignTokens.Surface.secondary
        case .filled: shvil.DesignTokens.Surface.tertiary
        case .outlined: Color.clear
        case .floating: shvil.DesignTokens.Surface.primary
        }
    }
    
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xl)
            .stroke(strokeColor, lineWidth: strokeWidth)
    }
    
    private var strokeColor: Color {
        switch style {
        case .elevated: shvil.DesignTokens.Glass.light
        case .filled: shvil.DesignTokens.Stroke.light
        case .outlined: shvil.DesignTokens.Brand.primary
        case .floating: shvil.DesignTokens.Stroke.hairline
        }
    }
    
    private var strokeWidth: CGFloat {
        switch style {
        case .elevated: 1
        case .filled: 1
        case .outlined: 2
        case .floating: 0.5
        }
    }
    
    private var shadow: ShadowValue {
        switch style {
        case .elevated: shvil.DesignTokens.Shadow.medium
        case .filled: shvil.DesignTokens.Shadow.light
        case .outlined: shvil.DesignTokens.Shadow.light
        case .floating: shvil.DesignTokens.Shadow.glass
        }
    }
}

// MARK: - Glass Chip Component

struct AppleGlassChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: shvil.DesignTokens.Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(AppleTypography.footnoteEmphasized)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, shvil.DesignTokens.Spacing.md)
            .padding(.vertical, shvil.DesignTokens.Spacing.sm)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(shvil.DesignTokens.Animation.micro) {
                isPressed = pressing
            }
        }, perform: {})
        .appleAccessibility(
            label: title,
            hint: isSelected ? "Selected" : "Double tap to select"
        )
    }
    
    private var textColor: Color {
        isSelected ? .white : shvil.DesignTokens.Text.primary
    }
    
    private var backgroundView: some View {
        Capsule()
            .fill(backgroundColor)
            .overlay(overlayView)
    }
    
    private var backgroundColor: Color {
        isSelected ? shvil.DesignTokens.Brand.primary : shvil.DesignTokens.Surface.secondary
    }
    
    private var overlayView: some View {
        Capsule()
            .stroke(shvil.DesignTokens.Brand.primary, lineWidth: isSelected ? 0 : 1)
    }
}

// MARK: - Glass Sheet Component

struct AppleGlassSheet<Content: View>: View {
    let content: Content
    let isPresented: Binding<Bool>
    let title: String?
    let height: SheetHeight
    
    enum SheetHeight {
        case small
        case medium
        case large
        case custom(CGFloat)
    }
    
    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        height: SheetHeight = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.title = title
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isPresented.wrappedValue {
                // Backdrop
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(shvil.DesignTokens.Animation.standard) {
                            isPresented.wrappedValue = false
                        }
                    }
                
                // Sheet Content
                VStack(spacing: 0) {
                    // Handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(shvil.DesignTokens.Text.tertiary)
                        .frame(width: 36, height: 4)
                        .padding(.top, shvil.DesignTokens.Spacing.sm)
                    
                    // Title
                    if let title {
                        Text(title)
                            .font(shvil.DesignTokens.Typography.title3)
                            .foregroundColor(shvil.DesignTokens.Text.primary)
                            .padding(.top, shvil.DesignTokens.Spacing.md)
                    }
                    
                    // Content
                    content
                        .padding(.horizontal, shvil.DesignTokens.Spacing.md)
                        .padding(.bottom, shvil.DesignTokens.Spacing.lg)
                }
                .frame(maxHeight: sheetHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xxl, style: .continuous)
                        .fill(shvil.DesignTokens.Surface.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xxl, style: .continuous)
                                .stroke(shvil.DesignTokens.Stroke.hairline, lineWidth: 0.5)
                        )
                )
                .appleShadow(shvil.DesignTokens.Shadow.glass)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(shvil.DesignTokens.Animation.spring, value: isPresented.wrappedValue)
            }
        }
    }
    
    private var sheetHeight: CGFloat {
        switch height {
        case .small: 300
        case .medium: 400
        case .large: 600
        case .custom(let height): height
        }
    }
}

// MARK: - Glass Navigation Bar Component

struct AppleGlassNavBar: View {
    let title: String
    let leadingButton: NavBarButton?
    let trailingButton: NavBarButton?
    
    struct NavBarButton {
        let icon: String
        let action: () -> Void
    }
    
    init(
        title: String,
        leadingButton: NavBarButton? = nil,
        trailingButton: NavBarButton? = nil
    ) {
        self.title = title
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
    }
    
    var body: some View {
        HStack {
            // Leading Button
            if let leadingButton {
                Button(action: leadingButton.action) {
                    Image(systemName: leadingButton.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(shvil.DesignTokens.Text.primary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
            
            // Title
            Text(title)
                .font(shvil.DesignTokens.Typography.title3)
                .foregroundColor(shvil.DesignTokens.Text.primary)
                .frame(maxWidth: .infinity)
            
            // Trailing Button
            if let trailingButton {
                Button(action: trailingButton.action) {
                    Image(systemName: trailingButton.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(shvil.DesignTokens.Text.primary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
        }
        .padding(.horizontal, shvil.DesignTokens.Spacing.md)
        .padding(.vertical, shvil.DesignTokens.Spacing.sm)
        .background(
            Rectangle()
                .fill(shvil.DesignTokens.Surface.primary)
                .overlay(
                    Rectangle()
                        .fill(shvil.DesignTokens.Stroke.hairline)
                        .frame(height: 0.5),
                    alignment: .bottom
                )
        )
        .appleShadow(shvil.DesignTokens.Shadow.light)
    }
}

// MARK: - Glass Status Indicator

struct AppleGlassStatusIndicator: View {
    let status: Status
    let message: String?
    
    enum Status {
        case success
        case warning
        case error
        case info
        case loading
    }
    
    init(status: Status, message: String? = nil) {
        self.status = status
        self.message = message
    }
    
    var body: some View {
        HStack(spacing: shvil.DesignTokens.Spacing.sm) {
            // Status Icon
            Group {
                if status == .loading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: iconColor))
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                }
            }
            
            // Message
            if let message {
                Text(message)
                    .font(AppleTypography.footnote)
                    .foregroundColor(shvil.DesignTokens.Text.primary)
            }
        }
        .padding(.horizontal, shvil.DesignTokens.Spacing.md)
        .padding(.vertical, shvil.DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
                        .stroke(shvil.DesignTokens.Stroke.light, lineWidth: 1)
                )
        )
        .appleShadow(shvil.DesignTokens.Shadow.light)
    }
    
    private var iconName: String {
        switch status {
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.circle.fill"
        case .info: "info.circle.fill"
        case .loading: ""
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .success: shvil.DesignTokens.Semantic.success
        case .warning: shvil.DesignTokens.Semantic.warning
        case .error: shvil.DesignTokens.Semantic.error
        case .info: shvil.DesignTokens.Semantic.info
        case .loading: shvil.DesignTokens.Brand.primary
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .success: shvil.DesignTokens.Semantic.success.opacity(0.1)
        case .warning: shvil.DesignTokens.Semantic.warning.opacity(0.1)
        case .error: shvil.DesignTokens.Semantic.error.opacity(0.1)
        case .info: shvil.DesignTokens.Semantic.info.opacity(0.1)
        case .loading: shvil.DesignTokens.Brand.primary.opacity(0.1)
        }
    }
}

// MARK: - Glass Loading Indicator

struct AppleGlassLoadingIndicator: View {
    let message: String?
    let style: LoadingStyle
    
    enum LoadingStyle {
        case circular
        case linear
        case dots
    }
    
    init(message: String? = nil, style: LoadingStyle = .circular) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: shvil.DesignTokens.Spacing.md) {
            // Loading Indicator
            Group {
                switch style {
                case .circular:
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: shvil.DesignTokens.Brand.primary))
                case .linear:
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: shvil.DesignTokens.Brand.primary))
                case .dots:
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(shvil.DesignTokens.Brand.primary)
                                .frame(width: 8, height: 8)
                                .scaleEffect(animationScale(for: index))
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: animationScale(for: index)
                                )
                        }
                    }
                }
            }
            
            // Message
            if let message {
                Text(message)
                    .font(AppleTypography.footnote)
                    .foregroundColor(shvil.DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(shvil.DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.lg)
                .fill(shvil.DesignTokens.Surface.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.lg)
                        .stroke(shvil.DesignTokens.Stroke.hairline, lineWidth: 0.5)
                )
        )
        .appleShadow(shvil.DesignTokens.Shadow.light)
    }
    
    private func animationScale(for index: Int) -> CGFloat {
        // This would be animated in a real implementation
        1.0
    }
}

// MARK: - Glass Progress Bar

struct AppleGlassProgressBar: View {
    let progress: Double
    let total: Double
    let style: ProgressStyle
    
    enum ProgressStyle {
        case linear
        case circular
    }
    
    init(progress: Double, total: Double = 1.0, style: ProgressStyle = .linear) {
        self.progress = progress
        self.total = total
        self.style = style
    }
    
    var body: some View {
        Group {
            switch style {
            case .linear:
                linearProgress
            case .circular:
                circularProgress
            }
        }
    }
    
    private var linearProgress: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.sm)
                    .fill(shvil.DesignTokens.Surface.secondary)
                
                // Progress
                RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.sm)
                    .fill(shvil.DesignTokens.Brand.primary)
                    .frame(width: geometry.size.width * progressRatio)
                    .animation(shvil.DesignTokens.Animation.standard, value: progressRatio)
            }
        }
        .frame(height: 8)
    }
    
    private var circularProgress: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(shvil.DesignTokens.Surface.secondary, lineWidth: 4)
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: progressRatio)
                .stroke(
                    shvil.DesignTokens.Brand.primary,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(shvil.DesignTokens.Animation.standard, value: progressRatio)
        }
        .frame(width: 40, height: 40)
    }
    
    private var progressRatio: Double {
        min(max(progress / total, 0), 1)
    }
}

// MARK: - Glass Empty State

struct AppleGlassEmptyState: View {
    let title: String
    let description: String
    let icon: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        description: String,
        icon: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: shvil.DesignTokens.Spacing.lg) {
            // Icon
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(shvil.DesignTokens.Text.tertiary)
            }
            
            // Content
            VStack(spacing: shvil.DesignTokens.Spacing.sm) {
                Text(title)
                    .font(shvil.DesignTokens.Typography.title3)
                    .foregroundColor(shvil.DesignTokens.Text.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(shvil.DesignTokens.Typography.body)
                    .foregroundColor(shvil.DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Action Button
            if let actionTitle, let action {
                AppleGlassButton(
                    actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
            }
        }
        .padding(shvil.DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xl)
                .fill(shvil.DesignTokens.Surface.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.xl)
                        .stroke(shvil.DesignTokens.Stroke.hairline, lineWidth: 0.5)
                )
        )
        .appleShadow(shvil.DesignTokens.Shadow.light)
    }
}

// MARK: - Floating Action Button (FAB)

struct AppleGlassFAB: View {
    let icon: String
    let size: FABSize
    let style: FABStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum FABSize {
        case small
        case medium
        case large
    }
    
    enum FABStyle {
        case primary
        case secondary
        case destructive
    }
    
    init(
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
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(iconFont)
                .foregroundColor(textColor)
                .frame(width: buttonSize, height: buttonSize)
                .background(backgroundView)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var buttonSize: CGFloat {
        switch size {
        case .small: return 44
        case .medium: return 56
        case .large: return 64
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small: return .system(size: 16, weight: .semibold)
        case .medium: return .system(size: 20, weight: .semibold)
        case .large: return .system(size: 24, weight: .semibold)
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: shvil.DesignTokens.Text.primary
        case .destructive: .white
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: buttonSize / 2)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: buttonSize / 2)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: shvil.DesignTokens.Brand.primary
        case .secondary: shvil.DesignTokens.Surface.secondary
        case .destructive: shvil.DesignTokens.Semantic.error
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .primary: .clear
        case .secondary: shvil.DesignTokens.Stroke.light
        case .destructive: .clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: shvil.DesignTokens.Brand.primary.opacity(0.3)
        case .secondary: shvil.DesignTokens.Shadow.light.color
        case .destructive: shvil.DesignTokens.Semantic.error.opacity(0.3)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch size {
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        }
    }
    
    private var shadowOffset: CGFloat {
        switch size {
        case .small: return 2
        case .medium: return 4
        case .large: return 6
        }
    }
}


// MARK: - List Row Component

struct AppleGlassListRow: View {
    let icon: String?
    let title: String
    let subtitle: String?
    let trailing: AnyView?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        trailing: AnyView? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(shvil.DesignTokens.Brand.primary)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(shvil.DesignTokens.Typography.body)
                        .foregroundColor(shvil.DesignTokens.Text.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(shvil.DesignTokens.Typography.caption1)
                            .foregroundColor(shvil.DesignTokens.Text.secondary)
                    }
                }
                
                Spacer()
                
                if let trailing = trailing {
                    trailing
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(shvil.DesignTokens.Text.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
                    .fill(shvil.DesignTokens.Surface.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: shvil.DesignTokens.CornerRadius.md)
                            .stroke(shvil.DesignTokens.Stroke.light, lineWidth: 0.5)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}