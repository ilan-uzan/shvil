//
//  AppleGlassComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Apple Glass Components
// Following Apple's design principles with glassmorphism effects

// MARK: - Glass Button

struct AppleGlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let size: ButtonSize
    
    @State private var isPressed = false
    
    enum ButtonStyle {
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
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
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
                    .font(size.font)
            }
            .foregroundColor(textColor)
            .padding(size.padding)
            .background(backgroundView)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.micro, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .appleAccessibility(label: title, hint: "Double tap to activate")
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: AppleColors.textPrimary
        case .tertiary: AppleColors.accent
        case .destructive: .white
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .stroke(highlightColor, lineWidth: 1)
            )
            .appleShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary
        case .secondary: AppleColors.glassMedium
        case .tertiary: Color.clear
        case .destructive: AppleColors.danger
        }
    }
    
    private var highlightColor: Color {
        switch style {
        case .primary: Color.white.opacity(0.2)
        case .secondary: Color.white.opacity(0.1)
        case .tertiary: AppleColors.accent.opacity(0.3)
        case .destructive: Color.white.opacity(0.2)
        }
    }
    
    private var shadow: Shadow {
        switch style {
        case .primary: AppleShadows.medium
        case .secondary: AppleShadows.light
        case .tertiary: AppleShadows.light
        case .destructive: AppleShadows.medium
        }
    }
}

// MARK: - Glass Card

struct AppleGlassCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let cornerRadius: CGFloat
    
    enum CardStyle {
        case elevated
        case filled
        case outlined
        case glassmorphism
    }
    
    init(
        style: CardStyle = .glassmorphism,
        cornerRadius: CGFloat = AppleCornerRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppleSpacing.md)
            .background(backgroundView)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(overlayView)
            .appleShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated: AppleColors.surfaceSecondary
        case .filled: AppleColors.surfaceTertiary
        case .outlined: Color.clear
        case .glassmorphism: AppleColors.glassMedium
        }
    }
    
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(AppleColors.glassLight, lineWidth: 1)
    }
    
    private var shadow: Shadow {
        switch style {
        case .elevated: AppleShadows.medium
        case .filled: AppleShadows.light
        case .outlined: AppleShadows.light
        case .glassmorphism: AppleShadows.glass
        }
    }
}

// MARK: - Glass FAB (Floating Action Button)

struct AppleGlassFAB: View {
    let icon: String
    let action: () -> Void
    let size: FABSize
    let style: FABStyle
    
    @State private var isPressed = false
    
    enum FABSize {
        case small
        case medium
        case large
        
        var frame: CGFloat {
            switch self {
            case .small: 44
            case .medium: 56
            case .large: 64
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: 16
            case .medium: 20
            case .large: 24
            }
        }
    }
    
    enum FABStyle {
        case primary
        case secondary
        case tertiary
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
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(textColor)
        }
        .frame(width: size.frame, height: size.frame)
        .background(backgroundView)
        .scaleEffect(isPressed ? 1.05 : 1.0)
        .animation(AppleAnimations.spring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .appleAccessibility(label: "Floating action button", hint: "Double tap to activate")
    }
    
    private var textColor: Color {
        switch style {
        case .primary: .white
        case .secondary: AppleColors.textPrimary
        case .tertiary: AppleColors.accent
        }
    }
    
    private var backgroundView: some View {
        Circle()
            .fill(backgroundColor)
            .overlay(
                Circle()
                    .stroke(highlightColor, lineWidth: 1)
            )
            .appleShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: AppleColors.brandPrimary
        case .secondary: AppleColors.glassMedium
        case .tertiary: Color.clear
        }
    }
    
    private var highlightColor: Color {
        switch style {
        case .primary: Color.white.opacity(0.2)
        case .secondary: Color.white.opacity(0.1)
        case .tertiary: AppleColors.accent.opacity(0.3)
        }
    }
    
    private var shadow: Shadow {
        switch style {
        case .primary: AppleShadows.medium
        case .secondary: AppleShadows.light
        case .tertiary: AppleShadows.light
        }
    }
}

// MARK: - Glass Bottom Sheet

struct AppleGlassBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(
        isPresented: Binding<Bool>,
        height: CGFloat = 300,
        cornerRadius: CGFloat = AppleCornerRadius.xl,
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        self.height = height
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppleColors.textTertiary)
                    .frame(width: 40, height: 4)
                    .padding(.top, AppleSpacing.sm)
                    .padding(.bottom, AppleSpacing.md)
                
                content
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.bottom, AppleSpacing.md)
            }
            .frame(height: height)
            .background(backgroundView)
        }
        .background(
            Color.black.opacity(isPresented ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
        )
        .opacity(isPresented ? 1 : 0)
        .animation(AppleAnimations.complex, value: isPresented)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppleColors.surfaceSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppleColors.glassLight, lineWidth: 1)
            )
            .appleShadow(AppleShadows.heavy)
    }
}

// MARK: - Glass Search Bar

struct AppleGlassSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearchButtonClicked: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    init(
        text: Binding<String>,
        placeholder: String = "Search",
        onSearchButtonClicked: (() -> Void)? = nil
    ) {
        _text = text
        self.placeholder = placeholder
        self.onSearchButtonClicked = onSearchButtonClicked
    }
    
    var body: some View {
        HStack(spacing: AppleSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppleColors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textPrimary)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .onSubmit {
                    onSearchButtonClicked?()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppleColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .background(backgroundView)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
            .fill(AppleColors.glassMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .stroke(AppleColors.glassLight, lineWidth: 1)
            )
            .appleShadow(AppleShadows.light)
    }
}

// MARK: - Glass List Row

struct AppleGlassListRow<Content: View>: View {
    let content: Content
    let action: (() -> Void)?
    let showChevron: Bool
    
    init(
        showChevron: Bool = true,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showChevron = showChevron
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: AppleSpacing.md) {
                content
                
                if showChevron && action != nil {
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

// MARK: - Glass Progress Bar

struct AppleGlassProgressBar: View {
    let progress: Double
    let height: CGFloat
    let color: Color
    let showPercentage: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        height: CGFloat = 8,
        color: Color = AppleColors.accent,
        showPercentage: Bool = false
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.color = color
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        VStack(spacing: AppleSpacing.xs) {
            if showPercentage {
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                    Spacer()
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(AppleColors.surfaceTertiary)
                        .frame(height: height)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress, height: height)
                        .appleShadow(AppleShadows.light)
                }
            }
            .frame(height: height)
        }
        .onAppear {
            withAnimation(AppleAnimations.complex) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(AppleAnimations.standard) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Glass Loading Indicator

struct AppleGlassLoadingIndicator: View {
    let size: CGFloat
    let color: Color
    let lineWidth: CGFloat
    
    @State private var isAnimating = false
    
    init(
        size: CGFloat = 24,
        color: Color = AppleColors.accent,
        lineWidth: CGFloat = 3
    ) {
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                LinearGradient(
                    colors: [color, color.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Glass Status Indicator

struct AppleGlassStatusIndicator: View {
    let status: Status
    let size: CGFloat
    
    @State private var isPulsing = false
    
    enum Status {
        case success
        case warning
        case error
        case info
        
        var color: Color {
            switch self {
            case .success: AppleColors.success
            case .warning: AppleColors.warning
            case .error: AppleColors.danger
            case .info: AppleColors.info
            }
        }
        
        var icon: String {
            switch self {
            case .success: "checkmark.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            case .error: "xmark.circle.fill"
            case .info: "info.circle.fill"
            }
        }
    }
    
    init(status: Status, size: CGFloat = 20) {
        self.status = status
        self.size = size
    }
    
    var body: some View {
        Image(systemName: status.icon)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(status.color)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Glass Empty State

struct AppleGlassEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
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
    
    var body: some View {
        VStack(spacing: AppleSpacing.lg) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppleColors.glassMedium)
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(AppleColors.textSecondary)
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
                    .padding(.horizontal, AppleSpacing.xl)
            }
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                AppleGlassButton(
                    title: actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
            }
        }
        .padding(.horizontal, AppleSpacing.xl)
        .padding(.vertical, AppleSpacing.xxl)
    }
}
