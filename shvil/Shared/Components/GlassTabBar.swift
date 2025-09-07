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
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var dragScale: CGFloat = 1.0
    
    // Feature flag
    private let liquidGlassEnabled = FeatureFlags.shared.isEnabled(.liquidGlassNavV1)
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Apple Music-style Navigation Bar
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    AppleMusicTabButton(
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
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        print("🎯 Drag gesture detected! Location: \(value.location)")
                        if !isDragging {
                            isDragging = true
                            dragScale = 1.1 // Zoom in when dragging starts
                            print("🎯 Started dragging, scale: \(dragScale)")
                        }
                        
                        // Simplified calculation using screen width and tab count
                        let screenWidth = UIScreen.main.bounds.width
                        let hStackPadding = 32.0 // 16pt padding on each side
                        let availableWidth = screenWidth - hStackPadding
                        let tabWidth = availableWidth / CGFloat(tabs.count)
                        
                        // Calculate which tab the finger is over
                        let touchX = value.location.x
                        let tabIndex = Int(touchX / tabWidth)
                        
                        print("🎯 Touch X: \(touchX), Tab Width: \(tabWidth), Tab Index: \(tabIndex)")
                        
                        if tabIndex >= 0 && tabIndex < tabs.count {
                            // Update capsule position to follow finger
                            let tabCenter = CGFloat(tabIndex) * tabWidth + tabWidth / 2
                            let containerCenter = availableWidth / 2
                            dragOffset = tabCenter - containerCenter
                            print("🎯 Tab Center: \(tabCenter), Container Center: \(containerCenter), Drag Offset: \(dragOffset)")
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        dragScale = 1.0 // Zoom out when released
                        
                        // Simplified calculation using screen width and tab count
                        let screenWidth = UIScreen.main.bounds.width
                        let hStackPadding = 32.0
                        let availableWidth = screenWidth - hStackPadding
                        let tabWidth = availableWidth / CGFloat(tabs.count)
                        let touchX = value.location.x
                        let tabIndex = Int(touchX / tabWidth)
                        
                        print("🎯 Drag ended at X: \(touchX), Tab Index: \(tabIndex)")
                        
                        if tabIndex >= 0 && tabIndex < tabs.count && tabIndex != selectedTab {
                            selectTab(tabIndex)
                        } else {
                            // Reset to current tab position
                            updateCapsulePosition()
                        }
                    }
            )
            .background(
                ZStack {
                    // Apple Music-style frosted glass background - more rounded
                    RoundedRectangle(cornerRadius: 35)
                        .fill(.ultraThinMaterial)
                        .saturation(1.2)
                        .overlay(
                            // Subtle tint overlay
                            RoundedRectangle(cornerRadius: 35)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            dynamicTint.opacity(0.1),
                                            dynamicTint.opacity(0.05)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .overlay(
                            // Subtle border
                            RoundedRectangle(cornerRadius: 35)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.2)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                    
                    // Floating Lens Effect for Selected Tab
                    if selectedTab < tabs.count {
                        AppleMusicLens(
                            offset: isDragging ? dragOffset : capsuleOffset,
                            width: capsuleWidth,
                            tint: dynamicTint,
                            isAnimating: isAnimating,
                            scale: dragScale
                        )
                    }
                }
            )
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 15,
                x: 0,
                y: 8
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 2) // Right above iPhone homescreen bar
        }
        .onAppear {
            // Small delay to ensure view is fully rendered
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateCapsulePosition()
            }
        }
        .onChange(of: selectedTab) { _ in
            updateCapsulePosition()
            HapticFeedback.shared.selection()
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
        // Simplified calculation using screen width and tab count
        let screenWidth = UIScreen.main.bounds.width
        let hStackPadding = 32.0 // 16pt padding on each side
        let availableWidth = screenWidth - hStackPadding
        let tabWidth = availableWidth / CGFloat(tabs.count)
        let newWidth = tabWidth * 0.85 // 85% of tab width for proper fit
        
        // Calculate the center position of the selected tab
        // Each tab takes up equal space, so center is: (selectedTab * tabWidth) + (tabWidth / 2)
        let tabCenter = CGFloat(selectedTab) * tabWidth + tabWidth / 2
        let containerCenter = availableWidth / 2
        let newOffset = tabCenter - containerCenter
        
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

/// Apple Music-style tab button
struct AppleMusicTabButton: View {
    let tab: GlassTabItem
    let isSelected: Bool
    let dynamicTint: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                // Icon
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? dynamicTint : Color.white.opacity(0.7))
                    .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.1 : 1.0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
                
                // Label
                Text(tab.title)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? dynamicTint : Color.white.opacity(0.7))
                    .lineLimit(1)
                    .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            }
            .padding(.vertical, 10)
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

/// Apple Music-style floating lens effect
struct AppleMusicLens: View {
    let offset: CGFloat
    let width: CGFloat
    let tint: Color
    let isAnimating: Bool
    let scale: CGFloat
    
    var body: some View {
        ZStack {
            // Main lens background with Apple Music styling - more rounded
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    RadialGradient(
                        colors: [
                            tint.opacity(0.3),
                            tint.opacity(0.15),
                            tint.opacity(0.05)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .overlay(
                    // Apple Music-style lens reflection
                    RoundedRectangle(cornerRadius: 30)
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
                    // Subtle border like Apple Music
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    tint.opacity(0.4),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    // Soft glow effect
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(tint.opacity(0.4), lineWidth: 0.5)
                        .blur(radius: 1)
                )
            
            // Inner highlight for lens effect
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 18
                    )
                )
                .blendMode(.overlay)
        }
        .frame(width: width, height: 55)
        .offset(x: offset)
        .scaleEffect(scale)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: offset)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: width)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: scale)
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
