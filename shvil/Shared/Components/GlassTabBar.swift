//
//  GlassTabBar.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Apple Music-style Liquid Glass bottom navigation bar
/// Features: frosted glass, dynamic tinting, springy selection animation, and liquid capsule morphing
struct GlassTabBar: View {
    let tabs: [GlassTabItem]
    @Binding var selectedTab: Int
    let onSelect: (Int) -> Void
    
    @State private var dynamicTint: Color = DesignTokens.Brand.primary
    @State private var capsuleOffset: CGFloat = 0
    @State private var capsuleWidth: CGFloat = 0
    @State private var isAnimating = false
    @State private var scrollOffset: CGFloat = 0
    
    // Feature flag
    private let liquidGlassEnabled = FeatureFlags.shared.isEnabled(.liquidGlassNavV1)
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    GlassTabButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        dynamicTint: dynamicTint,
                        onTap: {
                            selectTab(index)
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                ZStack {
                    // Backdrop Blur Layer
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(.ultraThinMaterial)
                        .saturation(1.2) // Wet glass effect
                        .overlay(
                            // Film grain overlay
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.02),
                                            Color.black.opacity(0.01)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    
                    // Glass Body Layer
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(
                            LinearGradient(
                                colors: [
                                    dynamicTint.opacity(0.15),
                                    dynamicTint.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            // Inner specular gradient
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .offset(y: scrollOffset * 0.5) // Parallax effect
                        )
                    
                    // Border Highlight
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    
                    // Selection Capsule
                    if selectedTab < tabs.count {
                        LiquidCapsule(
                            offset: capsuleOffset,
                            width: capsuleWidth,
                            tint: dynamicTint,
                            isAnimating: isAnimating
                        )
                    }
                }
            )
            .shadow(
                color: DesignTokens.Shadow.heavy.color,
                radius: DesignTokens.Shadow.heavy.radius,
                x: DesignTokens.Shadow.heavy.x,
                y: DesignTokens.Shadow.heavy.y
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .onAppear {
            updateCapsulePosition()
        }
        .onChange(of: selectedTab) { _ in
            updateCapsulePosition()
        }
        .onChange(of: scrollOffset) { _ in
            // Update blur intensity based on scroll
            updateBlurIntensity()
        }
    }
    
    private func selectTab(_ index: Int) {
        guard index != selectedTab else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedTab = index
            onSelect(index)
        }
        
        // Haptic feedback
        HapticFeedback.shared.impact(style: .light)
        
        // Update dynamic tint based on selected tab
        updateDynamicTint(for: index)
    }
    
    private func updateCapsulePosition() {
        let tabWidth = (UIScreen.main.bounds.width - (DesignTokens.Spacing.lg * 2) - (DesignTokens.Spacing.md * 2)) / CGFloat(tabs.count)
        let newOffset = CGFloat(selectedTab) * tabWidth
        let newWidth = tabWidth - (DesignTokens.Spacing.sm * 2)
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            capsuleOffset = newOffset
            capsuleWidth = newWidth
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
    }
    
    private func updateDynamicTint(for tabIndex: Int) {
        let newTint = getTintForTab(tabIndex)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            dynamicTint = newTint
        }
    }
    
    private func getTintForTab(_ index: Int) -> Color {
        switch index {
        case 0: // Map
            return DesignTokens.Brand.primary
        case 1: // Socialize
            return DesignTokens.Semantic.success
        case 2: // Hunt
            return DesignTokens.Semantic.warning
        case 3: // Adventure
            return DesignTokens.Brand.primaryMid
        case 4: // Settings
            return DesignTokens.Text.primary
        default:
            return DesignTokens.Brand.primary
        }
    }
    
    private func updateBlurIntensity() {
        // Adjust blur based on scroll offset for better legibility
        // This would be implemented with a custom blur modifier if needed
    }
}

/// Individual tab button with liquid glass styling
struct GlassTabButton: View {
    let tab: GlassTabItem
    let isSelected: Bool
    let dynamicTint: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                ZStack {
                    // Icon background for selected state
                    if isSelected {
                        Circle()
                            .fill(dynamicTint.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(dynamicTint.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? dynamicTint : DesignTokens.Text.secondary)
                        .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.08 : 1.0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
                }
                
                Text(tab.title)
                    .font(DesignTokens.Typography.caption1)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? dynamicTint : DesignTokens.Text.tertiary)
                    .lineLimit(1)
                    .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            }
            .padding(.vertical, DesignTokens.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel(tab.title)
        .accessibilityHint(isSelected ? "Selected tab" : "Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Liquid capsule that morphs between tabs
struct LiquidCapsule: View {
    let offset: CGFloat
    let width: CGFloat
    let tint: Color
    let isAnimating: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
            .fill(
                LinearGradient(
                    colors: [
                        tint.opacity(0.25),
                        tint.opacity(0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                // Extra gloss stripe
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .overlay(
                // Micro-bloom effect
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .stroke(tint.opacity(0.3), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .frame(width: width, height: 40)
            .offset(x: offset)
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: offset)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: width)
    }
}

/// Tab item data structure
struct GlassTabItem: Identifiable {
    let id = UUID()
    let icon: String
    let selectedIcon: String
    let title: String
    let route: String
    
    init(icon: String, selectedIcon: String? = nil, title: String, route: String) {
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
        self.title = title
        self.route = route
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DesignTokens.Surface.background
            .ignoresSafeArea()
        
        GlassTabBar(
            tabs: [
                GlassTabItem(icon: "map", selectedIcon: "map.fill", title: "Map", route: "map"),
                GlassTabItem(icon: "person.3", selectedIcon: "person.3.fill", title: "Socialize", route: "socialize"),
                GlassTabItem(icon: "flag", selectedIcon: "flag.fill", title: "Hunt", route: "hunt"),
                GlassTabItem(icon: "sparkles", selectedIcon: "sparkles", title: "Adventure", route: "adventure"),
                GlassTabItem(icon: "gearshape", selectedIcon: "gearshape.fill", title: "Settings", route: "settings")
            ],
            selectedTab: .constant(0),
            onSelect: { _ in }
        )
    }
}
