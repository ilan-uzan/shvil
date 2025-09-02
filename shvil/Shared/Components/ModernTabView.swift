//
//  ModernTabView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Modern Tab View
struct ModernTabView: View {
    @State private var selectedTab: Tab = .map
    @State private var tabBarHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Main Content
            Group {
                switch selectedTab {
                case .map:
                    ModernMapTabView()
                case .search:
                    ModernSearchTabView()
                case .saved:
                    ModernSavedPlacesTabView()
                case .profile:
                    ModernProfileTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            VStack {
                Spacer()
                ModernTabBar(selectedTab: $selectedTab)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    tabBarHeight = geometry.size.height
                                }
                        }
                    )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Tab Enum
enum Tab: String, CaseIterable {
    case map = "map"
    case search = "search"
    case saved = "saved"
    case profile = "profile"
    
    var title: String {
        switch self {
        case .map: return "Map"
        case .search: return "Search"
        case .saved: return "Saved"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .map: return "map.fill"
        case .search: return "magnifyingglass"
        case .saved: return "star.fill"
        case .profile: return "person.circle.fill"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .map: return "map.fill"
        case .search: return "magnifyingglass.circle.fill"
        case .saved: return "star.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

// MARK: - Modern Tab Bar
struct ModernTabBar: View {
    @Binding var selectedTab: Tab
    @State private var tabWidth: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    tabWidth: tabWidth
                ) {
                    withAnimation(ShvilDesign.Animation.spring) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.vertical, ShvilDesign.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ShvilDesign.CornerRadius.large)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: -5
                )
        )
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.bottom, ShvilDesign.Spacing.sm)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        tabWidth = geometry.size.width / CGFloat(Tab.allCases.count)
                    }
            }
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let tabWidth: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background circle for selected state
                    if isSelected {
                        Circle()
                            .fill(ShvilDesign.Colors.primary)
                            .frame(width: 32, height: 32)
                            .scaleEffect(isSelected ? 1.0 : 0.8)
                            .animation(ShvilDesign.Animation.spring, value: isSelected)
                    }
                    
                    // Icon
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? .white : ShvilDesign.Colors.secondaryText)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(ShvilDesign.Animation.spring, value: isSelected)
                }
                
                // Label
                Text(tab.title)
                    .font(ShvilDesign.Typography.caption2)
                    .foregroundColor(isSelected ? ShvilDesign.Colors.primary : ShvilDesign.Colors.secondaryText)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
        .frame(width: tabWidth)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views
struct ModernMapTabView: View {
    var body: some View {
        ModernMapView()
    }
}

struct ModernSearchTabView: View {
    var body: some View {
        ModernSearchView()
    }
}

struct ModernSavedPlacesTabView: View {
    var body: some View {
        ModernSavedPlacesView()
    }
}

struct ModernProfileTabView: View {
    var body: some View {
        ModernProfileView()
    }
}

#Preview {
    ModernTabView()
}
