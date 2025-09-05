//
//  AppleGlassComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Apple Glass Components Library
// Comprehensive glassmorphism components following Apple Design Guidelines

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
            HStack(spacing: AppleSpacing.sm) {
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
            withAnimation(AppleAnimations.micro) {
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
        case .medium: AppleTypography.bodyEmphasized
        case .large: AppleTypography.headline
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
        case .secondary: AppleColors.textPrimary
        case .destructive: .white
        case .ghost: AppleColors.brandPrimary
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
    
    private var minHeight: CGFloat {
        switch size {
        case .small: 32
        case .medium: 44
        case .large: 52
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
            .fill(backgroundColor)
            .overlay(overlayView)
            .appleShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary
        case .secondary: AppleColors.surfaceSecondary
        case .destructive: AppleColors.danger
        case .ghost: Color.clear
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
            .padding(AppleSpacing.md)
            .background(backgroundView)
            .appleShadow(shadow)
            .applePerformanceOptimized() // Add performance optimization
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
            .fill(backgroundColor)
            .overlay(overlayView)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated: AppleColors.surfaceSecondary
        case .filled: AppleColors.surfaceTertiary
        case .outlined: Color.clear
        case .floating: AppleColors.surface
        }
    }
    
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
            .stroke(strokeColor, lineWidth: strokeWidth)
    }
    
    private var strokeColor: Color {
        switch style {
        case .elevated: AppleColors.glassLight
        case .filled: AppleColors.strokeLight
        case .outlined: AppleColors.brandPrimary
        case .floating: AppleColors.strokeHairline
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
    
    private var shadow: Shadow {
        switch style {
        case .elevated: AppleShadows.medium
        case .filled: AppleShadows.light
        case .outlined: AppleShadows.light
        case .floating: AppleShadows.glass
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
            HStack(spacing: AppleSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(AppleTypography.footnoteEmphasized)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.sm)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(AppleAnimations.micro) {
                isPressed = pressing
            }
        }, perform: {})
        .appleAccessibility(
            label: title,
            hint: isSelected ? "Selected" : "Double tap to select"
        )
    }
    
    private var textColor: Color {
        isSelected ? .white : AppleColors.textPrimary
    }
    
    private var backgroundView: some View {
        Capsule()
            .fill(backgroundColor)
            .overlay(overlayView)
    }
    
    private var backgroundColor: Color {
        isSelected ? AppleColors.brandPrimary : AppleColors.surfaceSecondary
    }
    
    private var overlayView: some View {
        Capsule()
            .stroke(AppleColors.brandPrimary, lineWidth: isSelected ? 0 : 1)
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
                        withAnimation(AppleAnimations.standard) {
                            isPresented.wrappedValue = false
                        }
                    }
                
                // Sheet Content
                VStack(spacing: 0) {
                    // Handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppleColors.textTertiary)
                        .frame(width: 36, height: 4)
                        .padding(.top, AppleSpacing.sm)
                    
                    // Title
                    if let title {
                        Text(title)
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)
                            .padding(.top, AppleSpacing.md)
                    }
                    
                    // Content
                    content
                        .padding(.horizontal, AppleSpacing.md)
                        .padding(.bottom, AppleSpacing.lg)
                }
                .frame(maxHeight: sheetHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xxl, style: .continuous)
                        .fill(AppleColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xxl, style: .continuous)
                                .stroke(AppleColors.strokeHairline, lineWidth: 0.5)
                        )
                )
                .appleShadow(AppleShadows.glass)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(AppleAnimations.spring, value: isPresented.wrappedValue)
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
                        .foregroundColor(AppleColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
            
            // Title
            Text(title)
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)
                .frame(maxWidth: .infinity)
            
            // Trailing Button
            if let trailingButton {
                Button(action: trailingButton.action) {
                    Image(systemName: trailingButton.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppleColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .background(
            Rectangle()
                .fill(AppleColors.surface)
                .overlay(
                    Rectangle()
                        .fill(AppleColors.strokeHairline)
                        .frame(height: 0.5),
                    alignment: .bottom
                )
        )
        .appleShadow(AppleShadows.light)
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
        HStack(spacing: AppleSpacing.sm) {
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
                    .foregroundColor(AppleColors.textPrimary)
            }
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                        .stroke(AppleColors.strokeLight, lineWidth: 1)
                )
        )
        .appleShadow(AppleShadows.light)
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
        case .success: AppleColors.success
        case .warning: AppleColors.warning
        case .error: AppleColors.danger
        case .info: AppleColors.info
        case .loading: AppleColors.brandPrimary
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .success: AppleColors.success.opacity(0.1)
        case .warning: AppleColors.warning.opacity(0.1)
        case .error: AppleColors.danger.opacity(0.1)
        case .info: AppleColors.info.opacity(0.1)
        case .loading: AppleColors.brandPrimary.opacity(0.1)
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
        VStack(spacing: AppleSpacing.md) {
            // Loading Indicator
            Group {
                switch style {
                case .circular:
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: AppleColors.brandPrimary))
                case .linear:
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: AppleColors.brandPrimary))
                case .dots:
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(AppleColors.brandPrimary)
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
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(AppleColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .stroke(AppleColors.strokeHairline, lineWidth: 0.5)
                )
        )
        .appleShadow(AppleShadows.light)
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
                RoundedRectangle(cornerRadius: AppleCornerRadius.sm)
                    .fill(AppleColors.surfaceSecondary)
                
                // Progress
                RoundedRectangle(cornerRadius: AppleCornerRadius.sm)
                    .fill(AppleColors.brandPrimary)
                    .frame(width: geometry.size.width * progressRatio)
                    .animation(AppleAnimations.standard, value: progressRatio)
            }
        }
        .frame(height: 8)
    }
    
    private var circularProgress: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(AppleColors.surfaceSecondary, lineWidth: 4)
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: progressRatio)
                .stroke(
                    AppleColors.brandPrimary,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(AppleAnimations.standard, value: progressRatio)
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
        VStack(spacing: AppleSpacing.lg) {
            // Icon
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(AppleColors.textTertiary)
            }
            
            // Content
            VStack(spacing: AppleSpacing.sm) {
                Text(title)
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
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
        .padding(AppleSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                .fill(AppleColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .stroke(AppleColors.strokeHairline, lineWidth: 0.5)
                )
        )
        .appleShadow(AppleShadows.light)
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
        case .secondary: AppleColors.textPrimary
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
        case .primary: AppleColors.brandPrimary
        case .secondary: AppleColors.surfaceSecondary
        case .destructive: AppleColors.danger
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .primary: .clear
        case .secondary: AppleColors.strokeLight
        case .destructive: .clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary.opacity(0.3)
        case .secondary: AppleShadows.light.color
        case .destructive: AppleColors.danger.opacity(0.3)
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
                        .foregroundColor(AppleColors.brandPrimary)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let trailing = trailing {
                    trailing
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .fill(AppleColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                            .stroke(AppleColors.strokeLight, lineWidth: 0.5)
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