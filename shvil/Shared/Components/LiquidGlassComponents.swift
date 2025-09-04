//
//  LiquidGlassComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Search Pill Component (Glass Pill)
struct SearchPill: View {
    @Binding var searchText: String
    let onTap: () -> Void
    @State private var isFocused = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LiquidGlassColors.secondaryText)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search places or address", text: $searchText)
                .font(LiquidGlassTypography.body)
                .foregroundColor(LiquidGlassColors.primaryText)
                .textFieldStyle(PlainTextFieldStyle())
                .onTapGesture {
                    onTap()
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(LiquidGlassColors.glassSurface1)
                .overlay(
                    Capsule()
                        .stroke(isFocused ? LiquidGlassColors.accentText : Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            onTap()
        }
        .buttonAccessibility(
            label: "Search places or address",
            hint: "Double tap to open search"
        )
        .dynamicTypeSupport()
    }
}

// MARK: - Glass Button Component
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: GlassButtonStyle
    @State private var isPressed = false
    
    enum GlassButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(LiquidGlassTypography.bodySemibold)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(buttonBackground)
            .cornerRadius(12)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .buttonAccessibility(
            label: title,
            hint: "Double tap to activate"
        )
        .dynamicTypeSupport()
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return LiquidGlassColors.primaryText
        case .destructive:
            return .white
        }
    }
    
    private var buttonBackground: some View {
        Group {
            switch style {
            case .primary:
                LiquidGlassGradients.primaryGradient
            case .secondary:
                LiquidGlassColors.glassSurface1
            case .destructive:
                Color.red
            }
        }
    }
}

// MARK: - Glass Card Component
struct GlassCard<Content: View>: View {
    let content: Content
    let elevation: GlassElevation
    
    init(elevation: GlassElevation = .medium, @ViewBuilder content: () -> Content) {
        self.elevation = elevation
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .glassEffect(elevation: elevation)
    }
}

// MARK: - Glass Bottom Sheet
struct GlassBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    let height: CGFloat
    
    init(isPresented: Binding<Bool>, height: CGFloat = 300, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(LiquidGlassColors.secondaryText)
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                content
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LiquidGlassColors.glassSurface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: -10)
        }
        .background(
            Color.black.opacity(isPresented ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
        )
        .opacity(isPresented ? 1 : 0)
        .animation(LiquidGlassAnimations.pourAnimation, value: isPresented)
    }
}

// MARK: - Route Card Component
struct RouteCard: View {
    let route: RouteInfo
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(route.type)
                            .font(LiquidGlassTypography.body)
                            .foregroundColor(LiquidGlassColors.primaryText)
                        
                        Text(route.isFastest ? "Fastest" : route.isSafest ? "Safest" : "Route")
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(route.duration)
                            .font(LiquidGlassTypography.bodySemibold)
                            .foregroundColor(LiquidGlassColors.accentText)
                        
                        Text(route.distance)
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                }
                
                // Route preview line
                HStack(spacing: 4) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(LiquidGlassColors.accentText)
                            .frame(height: 3)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? LiquidGlassColors.glassSurface2 : LiquidGlassColors.glassSurface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? LiquidGlassColors.accentText : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Glass FAB Component (56×56pt, circular)
struct GlassFAB: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: 56, height: 56)
        .background(
            Circle()
                .fill(LiquidGlassGradients.primaryGradient)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: LiquidGlassColors.accentTurquoise.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 1.05 : 1.0)
        .animation(LiquidGlassAnimations.fabPress, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(LiquidGlassTypography.bodyMedium)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    Text(subtitle)
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface1)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .listItemAccessibility(
            label: "\(title), \(subtitle)",
            hint: "Double tap to open settings"
        )
        .dynamicTypeSupport()
    }
}

// RouteInfo is defined in SupabaseService

// MARK: - Preview
struct LiquidGlassComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Search Pill
            SearchPill(searchText: .constant("")) {
                print("Search tapped")
            }
            
            // Glass Button
            GlassButton(title: "Start Navigation", icon: "play.fill", action: {
                print("Button tapped")
            }, style: .primary)
            
            // Glass Card
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Route Options")
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    Text("Choose your preferred route")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
            }
            
            // Glass FAB
            GlassFAB(icon: "location.fill") {
                print("FAB tapped")
            }
        }
        .padding()
        .background(LiquidGlassColors.background)
        .previewDisplayName("Liquid Glass Components")
    }
}