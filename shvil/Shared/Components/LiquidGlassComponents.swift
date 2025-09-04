//
//  LiquidGlassComponents.swift
//  shvil
//
//  Created by Shvil Team on 2024.
//  Reusable Liquid Glass UI Components
//

import SwiftUI

// MARK: - Search Pill
struct SearchPill: View {
    @Binding var searchText: String
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LiquidGlassColors.secondaryText)
                .font(.system(size: 16, weight: .medium))
            
            if searchText.isEmpty {
                Text("Search places or address")
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .font(.system(size: LiquidGlassTypography.body))
            } else {
                Text(searchText)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .font(.system(size: LiquidGlassTypography.body))
            }
            
            Spacer()
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .font(.system(size: 16))
                }
                .rippleEffect()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(elevation: .light)
        .cornerRadius(25)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Floating Action Button
struct GlassFAB: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(LiquidGlassColors.primaryText)
        }
        .frame(width: 56, height: 56)
        .glassEffect(elevation: .medium)
        .clipShape(Circle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .rippleEffect()
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Instruction Card (Slab)
struct InstructionSlab: View {
    let instruction: String
    let distance: String
    let icon: String?
    
    init(instruction: String, distance: String, icon: String? = nil) {
        self.instruction = instruction
        self.distance = distance
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(instruction)
                    .font(.system(size: LiquidGlassTypography.headline, weight: LiquidGlassTypography.semibold))
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .multilineTextAlignment(.leading)
                
                Text(distance)
                    .font(.system(size: LiquidGlassTypography.subhead))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(20)
        .glassEffect(elevation: .high)
        .cornerRadius(16)
    }
}

// MARK: - Bottom Sheet
struct GlassBottomSheet<Content: View>: View {
    @Binding var isExpanded: Bool
    let collapsedContent: () -> Content
    let expandedContent: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(LiquidGlassColors.secondaryText)
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Content
            if isExpanded {
                expandedContent()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            } else {
                collapsedContent()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LiquidGlassGradients.glassGradient)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -10)
        .animation(LiquidGlassAnimations.transition, value: isExpanded)
    }
}

// MARK: - Route Card
struct RouteCard: View {
    let route: RouteInfo
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    struct RouteInfo {
        let duration: String
        let distance: String
        let type: String
        let isFastest: Bool
        let isSafest: Bool
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(route.type)
                            .font(.system(size: LiquidGlassTypography.headline, weight: LiquidGlassTypography.semibold))
                            .foregroundColor(LiquidGlassColors.primaryText)
                        
                        if route.isFastest {
                            Text("FASTEST")
                                .font(.system(size: LiquidGlassTypography.caption1, weight: LiquidGlassTypography.bold))
                                .foregroundColor(LiquidGlassColors.accentText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(LiquidGlassColors.accentText.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        if route.isSafest {
                            Text("SAFEST")
                                .font(.system(size: LiquidGlassTypography.caption1, weight: LiquidGlassTypography.bold))
                                .foregroundColor(LiquidGlassColors.deepAqua)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(LiquidGlassColors.deepAqua.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(route.distance)
                        .font(.system(size: LiquidGlassTypography.subhead))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                
                Spacer()
                
                Text(route.duration)
                    .font(.system(size: LiquidGlassTypography.title3, weight: LiquidGlassTypography.bold))
                    .foregroundColor(LiquidGlassColors.primaryText)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? LiquidGlassColors.accentText.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? LiquidGlassColors.accentText : Color.clear, lineWidth: 2)
                    )
            )
            .glassEffect(elevation: isSelected ? .high : .medium)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    @State private var isPressed = false
    
    init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(LiquidGlassColors.accentText)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: LiquidGlassTypography.body, weight: LiquidGlassTypography.medium))
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: LiquidGlassTypography.subhead))
                            .foregroundColor(LiquidGlassColors.secondaryText)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(16)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview
struct LiquidGlassComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search Pill
                SearchPill(searchText: .constant("")) {
                    print("Search tapped")
                }
                
                // FAB
                HStack {
                    GlassFAB(icon: "location.fill") {
                        print("Location tapped")
                    }
                    
                    GlassFAB(icon: "layers.fill") {
                        print("Layers tapped")
                    }
                }
                
                // Instruction Slab
                InstructionSlab(
                    instruction: "Turn right onto Main Street",
                    distance: "In 200 feet",
                    icon: "arrow.turn.up.right"
                )
                
                // Route Card
                RouteCard(
                    route: RouteCard.RouteInfo(
                        duration: "12 min",
                        distance: "2.3 miles",
                        type: "Drive",
                        isFastest: true,
                        isSafest: false
                    ),
                    isSelected: true
                ) {
                    print("Route selected")
                }
                
                // Settings Row
                SettingsRow(
                    icon: "person.fill",
                    title: "Profile",
                    subtitle: "Manage your account"
                ) {
                    print("Profile tapped")
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .previewDisplayName("Liquid Glass Components")
    }
}
