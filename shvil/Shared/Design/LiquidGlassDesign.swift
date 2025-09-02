//
//  LiquidGlassDesign.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Liquid Glass Design System
struct LiquidGlassDesign {
    
    // MARK: - Colors
    struct Colors {
        // Primary liquid glass blue (matching the logo)
        static let liquidBlue = Color(red: 0.0, green: 0.5, blue: 1.0)
        static let liquidBlueLight = Color(red: 0.2, green: 0.7, blue: 1.0)
        static let liquidBlueDark = Color(red: 0.0, green: 0.3, blue: 0.8)
        
        // Glass materials
        static let glassWhite = Color.white.opacity(0.9)
        static let glassLight = Color.white.opacity(0.8)
        static let glassMedium = Color.white.opacity(0.6)
        static let glassDark = Color.black.opacity(0.1)
        
        // Background colors
        static let backgroundPrimary = Color(red: 0.95, green: 0.95, blue: 0.97)
        static let backgroundSecondary = Color(red: 0.98, green: 0.98, blue: 0.99)
        static let backgroundDark = Color(red: 0.1, green: 0.1, blue: 0.12)
        
        // Accent colors
        static let accentGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
        static let accentRed = Color(red: 1.0, green: 0.3, blue: 0.3)
        static let accentPurple = Color(red: 0.6, green: 0.4, blue: 1.0)
        
        // Text colors
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(UIColor.tertiaryLabel)
        static let textInverse = Color.white
    }
    
    // MARK: - Typography
    struct Typography {
        // Display fonts
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Body fonts
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        
        // Special fonts
        static let navigationTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let tabBar = Font.system(size: 10, weight: .medium, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
        static let heavy = Color.black.opacity(0.25)
        static let glow = Color.blue.opacity(0.3)
    }
    
    // MARK: - Animations
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let fluid = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.6)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Liquid Glass View Modifiers
extension View {
    
    // MARK: - Glass Background
    func liquidGlassBackground(
        color: Color = LiquidGlassDesign.Colors.glassWhite,
        cornerRadius: CGFloat = LiquidGlassDesign.CornerRadius.lg,
        shadow: Color = LiquidGlassDesign.Shadows.light,
        shadowRadius: CGFloat = 10
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .shadow(color: shadow, radius: shadowRadius, x: 0, y: 4)
            )
    }
    
    // MARK: - Liquid Glass Card
    func liquidGlassCard(
        padding: CGFloat = LiquidGlassDesign.Spacing.md,
        cornerRadius: CGFloat = LiquidGlassDesign.CornerRadius.lg
    ) -> some View {
        self
            .padding(padding)
            .liquidGlassBackground(cornerRadius: cornerRadius)
    }
    
    // MARK: - Liquid Glass Button
    func liquidGlassButton(
        color: Color = LiquidGlassDesign.Colors.liquidBlue,
        cornerRadius: CGFloat = LiquidGlassDesign.CornerRadius.md,
        padding: CGFloat = LiquidGlassDesign.Spacing.md
    ) -> some View {
        self
            .padding(.horizontal, padding)
            .padding(.vertical, padding * 0.75)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .foregroundColor(.white)
            .font(LiquidGlassDesign.Typography.button)
    }
    
    // MARK: - Liquid Glass Glow
    func liquidGlassGlow(
        color: Color = LiquidGlassDesign.Colors.liquidBlue,
        radius: CGFloat = 20,
        intensity: CGFloat = 0.6
    ) -> some View {
        self
            .shadow(color: color.opacity(intensity), radius: radius, x: 0, y: 0)
    }
    
    // MARK: - Liquid Glass Border
    func liquidGlassBorder(
        color: Color = LiquidGlassDesign.Colors.liquidBlue,
        width: CGFloat = 1,
        cornerRadius: CGFloat = LiquidGlassDesign.CornerRadius.md
    ) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
    }
    
    // MARK: - Liquid Glass Blur
    func liquidGlassBlur(
        style: UIBlurEffect.Style = .systemUltraThinMaterial,
        cornerRadius: CGFloat = LiquidGlassDesign.CornerRadius.lg
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
    }
}

// MARK: - Liquid Glass Components
struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary
        case secondary
        case ghost
        case danger
    }
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(LiquidGlassDesign.Typography.button)
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            .padding(.vertical, LiquidGlassDesign.Spacing.sm)
            .background(backgroundView)
            .cornerRadius(LiquidGlassDesign.CornerRadius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary, .ghost:
            return LiquidGlassDesign.Colors.liquidBlue
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                .fill(LiquidGlassDesign.Colors.liquidBlue)
                .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 8, x: 0, y: 4)
        case .secondary:
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                .fill(LiquidGlassDesign.Colors.glassWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                        .stroke(LiquidGlassDesign.Colors.liquidBlue, lineWidth: 1)
                )
        case .ghost:
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                .fill(Color.clear)
        case .danger:
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                .fill(LiquidGlassDesign.Colors.accentRed)
                .shadow(color: LiquidGlassDesign.Colors.accentRed.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Liquid Glass Card
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    init(
        padding: CGFloat = LiquidGlassDesign.Spacing.md,
        cornerRadius: CGFloat = LiquidGlassDesign.CornerRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 10, x: 0, y: 4)
            )
    }
}

// MARK: - Liquid Glass Tab Bar
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    struct TabItem {
        let icon: String
        let title: String
        let badge: String?
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    tab: tabs[index],
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
            }
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
        .padding(.vertical, LiquidGlassDesign.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .shadow(color: LiquidGlassDesign.Shadows.medium, radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
    }
}

struct TabBarButton: View {
    let tab: LiquidGlassTabBar.TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.textSecondary)
                    
                    if let badge = tab.badge, !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(LiquidGlassDesign.Colors.accentRed)
                            )
                            .offset(x: 12, y: -8)
                    }
                }
                
                Text(tab.title)
                    .font(LiquidGlassDesign.Typography.tabBar)
                    .foregroundColor(isSelected ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LiquidGlassDesign.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(isSelected ? LiquidGlassDesign.Colors.liquidBlue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        LiquidGlassButton("Primary Button", icon: "star.fill", style: .primary) { }
        LiquidGlassButton("Secondary Button", icon: "heart.fill", style: .secondary) { }
        LiquidGlassButton("Ghost Button", icon: "gear", style: .ghost) { }
        
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Liquid Glass Card")
                    .font(LiquidGlassDesign.Typography.headline)
                Text("This is a beautiful liquid glass card with subtle shadows and transparency.")
                    .font(LiquidGlassDesign.Typography.body)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
        }
        
        LiquidGlassTabBar(
            selectedTab: .constant(0),
            tabs: [
                LiquidGlassTabBar.TabItem(icon: "map.fill", title: "Map", badge: nil),
                LiquidGlassTabBar.TabItem(icon: "magnifyingglass", title: "Search", badge: "3"),
                LiquidGlassTabBar.TabItem(icon: "bookmark.fill", title: "Saved", badge: nil),
                LiquidGlassTabBar.TabItem(icon: "person.fill", title: "Profile", badge: nil)
            ]
        )
    }
    .padding()
    .background(LiquidGlassDesign.Colors.backgroundPrimary)
}
