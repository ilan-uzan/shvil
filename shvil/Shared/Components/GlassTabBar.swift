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
            
            // Floating Navigation Pill with Magnifier Effect
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
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                ZStack {
                    // Magnifier Lens Effect with Colored Reflections
                    RoundedRectangle(cornerRadius: 25) // More rounded
                        .fill(.ultraThinMaterial)
                        .saturation(1.25) // Enhanced wet glass effect
                        .overlay(
                            // Colored lens reflections
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            dynamicTint.opacity(0.2),
                                            dynamicTint.opacity(0.05),
                                            Color.clear
                                        ],
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 60
                                    )
                                )
                        )
                        .overlay(
                            // Corner reflections like a real lens
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            dynamicTint.opacity(0.3),
                                            Color.white.opacity(0.2),
                                            Color.black.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            // Micro-bloom effect around edges
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(dynamicTint.opacity(0.4), lineWidth: 0.5)
                                .blur(radius: 1)
                        )
                    
                    // Floating Selection Capsule with Magnifier Effect
                    if selectedTab < tabs.count {
                        MagnifierCapsule(
                            offset: capsuleOffset,
                            width: capsuleWidth,
                            tint: dynamicTint,
                            isAnimating: isAnimating
                        )
                    }
                }
            )
            .shadow(
                color: dynamicTint.opacity(0.3),
                radius: 20,
                x: 0,
                y: 8
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .padding(.horizontal, DesignTokens.Spacing.xl)
            .padding(.bottom, 34) // Lower positioning above home indicator
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

/// Magnifier-style floating capsule with lens effects
struct MagnifierCapsule: View {
    let offset: CGFloat
    let width: CGFloat
    let tint: Color
    let isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Main capsule with magnifier lens effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            tint.opacity(0.3),
                            tint.opacity(0.15),
                            tint.opacity(0.05)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .overlay(
                    // Lens reflection gradient
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2),
                                    Color.clear,
                                    tint.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    // Corner lens reflections
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    tint.opacity(0.4),
                                    Color.white.opacity(0.3),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    // Micro-bloom lens effect
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(tint.opacity(0.5), lineWidth: 1)
                        .blur(radius: 1.5)
                )
            
            // Inner lens highlight
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .blendMode(.overlay)
        }
        .frame(width: width, height: 44)
        .offset(x: offset)
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: offset)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: width)
        .shadow(
            color: tint.opacity(0.4),
            radius: 8,
            x: 0,
            y: 4
        )
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
