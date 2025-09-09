//
//  PopularDestinationsPills.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Small separate pills for popular destinations with minimalistic icons
struct PopularDestinationsPills: View {
    @State private var selectedDestination: PopularDestination?
    @State private var scrollOffset: CGFloat = 0
    
    let onDestinationSelected: (PopularDestination) -> Void
    let dynamicIconColor: Color
    let dynamicTextColor: Color
    
    init(onDestinationSelected: @escaping (PopularDestination) -> Void, 
         dynamicIconColor: Color = Color.gray.opacity(0.6),
         dynamicTextColor: Color = Color.gray.opacity(0.6)) {
        self.onDestinationSelected = onDestinationSelected
        self.dynamicIconColor = dynamicIconColor
        self.dynamicTextColor = dynamicTextColor
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PopularDestination.allCases, id: \.self) { destination in
                    PopularDestinationPill(
                        destination: destination,
                        isSelected: selectedDestination == destination,
                        dynamicIconColor: dynamicIconColor,
                        dynamicTextColor: dynamicTextColor,
                        onTap: {
                            selectedDestination = destination
                            onDestinationSelected(destination)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minX)
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .coordinateSpace(name: "scroll")
    }
}

/// Individual popular destination pill
struct PopularDestinationPill: View {
    let destination: PopularDestination
    let isSelected: Bool
    let dynamicIconColor: Color
    let dynamicTextColor: Color
    let onTap: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Minimalistic icon
                Image(systemName: destination.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : dynamicIconColor)
                
                // Destination name
                Text(destination.title)
                    .font(DesignTokens.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : dynamicTextColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? 
                        AnyShapeStyle(DesignTokens.Brand.primary) :
                        AnyShapeStyle(.ultraThinMaterial)
                    )
                    .saturation(isSelected ? 1.0 : 1.1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: isSelected ? [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.2)
                                    ] : [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 1.0 : 0.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? 
                DesignTokens.Brand.primary.opacity(0.2) : 
                Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {
            // Long press action if needed
        }
    }
}

/// Popular destination data model
enum PopularDestination: String, CaseIterable {
    case home = "home"
    case work = "work"
    case gas = "gas"
    case groceries = "groceries"
    case coffee = "coffee"
    case pharmacy = "pharmacy"
    case bank = "bank"
    case hospital = "hospital"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .gas: return "Gas"
        case .groceries: return "Groceries"
        case .coffee: return "Coffee"
        case .pharmacy: return "Pharmacy"
        case .bank: return "Bank"
        case .hospital: return "Hospital"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "building.2.fill"
        case .gas: return "fuelpump.fill"
        case .groceries: return "cart.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .pharmacy: return "cross.fill"
        case .bank: return "banknote.fill"
        case .hospital: return "cross.case.fill"
        }
    }
}

/// Scroll offset preference key for tracking scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PopularDestinationsPills { destination in
            print("Selected: \(destination.title)")
        }
        
        PopularDestinationsPills { destination in
            print("Selected: \(destination.title)")
        }
        .environment(\.colorScheme, .dark)
    }
    .padding()
    .background(DesignTokens.Surface.background)
}
