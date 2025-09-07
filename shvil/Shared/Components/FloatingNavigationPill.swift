//
//  FloatingNavigationPill.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct FloatingNavigationPill: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    TabButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedTab = index
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .fill(DesignTokens.Surface.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                            .stroke(DesignTokens.Glass.light, lineWidth: 1)
                    )
                    .shadow(
                        color: DesignTokens.Shadow.light.color,
                        radius: DesignTokens.Shadow.light.radius,
                        x: DesignTokens.Shadow.light.x,
                        y: DesignTokens.Shadow.light.y
                    )
            )
            .background(
                // Sliding indicator
                HStack {
                    if selectedTab < tabs.count {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(DesignTokens.Brand.primary)
                            .frame(width: tabWidth, height: 40)
                            .offset(x: tabOffset + dragOffset)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
                    }
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold: CGFloat = 50
                        
                        if abs(value.translation.width) > threshold {
                            if value.translation.width > 0 && selectedTab > 0 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedTab -= 1
                                }
                            } else if value.translation.width < 0 && selectedTab < tabs.count - 1 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedTab += 1
                                }
                            }
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.lg)
        }
    }
    
    private var tabWidth: CGFloat {
        let totalWidth = UIScreen.main.bounds.width - (DesignTokens.Spacing.lg * 2) - (DesignTokens.Spacing.sm * 2)
        return totalWidth / CGFloat(tabs.count)
    }
    
    private var tabOffset: CGFloat {
        CGFloat(selectedTab) * tabWidth
    }
}

struct TabItem {
    let icon: String
    let selectedIcon: String
    let title: String
    let color: Color
    
    init(icon: String, selectedIcon: String? = nil, title: String, color: Color = DesignTokens.Brand.primary) {
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
        self.title = title
        self.color = color
    }
}

struct TabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : DesignTokens.Text.primary)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                Text(tab.title)
                    .font(DesignTokens.Typography.caption1)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : DesignTokens.Text.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DesignTokens.Surface.background
            .ignoresSafeArea()
        
        FloatingNavigationPill(
            selectedTab: .constant(0),
            tabs: [
                TabItem(icon: "person.3.fill", title: "Socialize"),
                TabItem(icon: "flag.fill", title: "Hunt"),
                TabItem(icon: "sparkles", title: "Adventure"),
                TabItem(icon: "gearshape.fill", title: "Settings")
            ]
        )
    }
}
