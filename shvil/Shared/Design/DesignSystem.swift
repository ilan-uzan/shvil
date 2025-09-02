//
//  DesignSystem.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Design System
struct ShvilDesign {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors
        static let primary = Color.blue
        static let primaryDark = Color.blue.opacity(0.8)
        static let secondary = Color.gray
        
        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Background Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        // Text Colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let tertiaryText = Color(.tertiaryLabel)
        
        // Map Colors
        static let routePrimary = Color.blue
        static let routeSecondary = Color.gray
        static let startPin = Color.green
        static let destinationPin = Color.red
        static let userLocation = Color.blue
        
        // Transport Mode Colors
        static let carColor = Color.blue
        static let walkingColor = Color.green
        static let transitColor = Color.purple
        static let bikeColor = Color.orange
        static let truckColor = Color.brown
    }
    
    // MARK: - Typography
    struct Typography {
        // Headlines
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        
        // Body Text
        static let body = Font.body
        static let bodyEmphasized = Font.body.weight(.medium)
        static let headline = Font.headline
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
        
        // Navigation
        static let navigationTitle = Font.title2.weight(.semibold)
        static let tabBarItem = Font.caption2
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Component specific
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let pill: CGFloat = 50
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func shvilCard(style: CardStyle = .default) -> some View {
        self
            .background(ShvilDesign.Colors.background)
            .cornerRadius(ShvilDesign.CornerRadius.medium)
            .shadow(
                color: ShvilDesign.Shadows.medium.color,
                radius: ShvilDesign.Shadows.medium.radius,
                x: ShvilDesign.Shadows.medium.x,
                y: ShvilDesign.Shadows.medium.y
            )
    }
    
    func shvilButton(style: ButtonStyle = .primary) -> some View {
        self
            .font(ShvilDesign.Typography.bodyEmphasized)
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, ShvilDesign.Spacing.lg)
            .padding(.vertical, ShvilDesign.Spacing.md)
            .background(style.backgroundColor)
            .cornerRadius(ShvilDesign.CornerRadius.medium)
            .shadow(
                color: ShvilDesign.Shadows.small.color,
                radius: ShvilDesign.Shadows.small.radius,
                x: ShvilDesign.Shadows.small.x,
                y: ShvilDesign.Shadows.small.y
            )
    }
}

// MARK: - Card Styles
enum CardStyle {
    case `default`
    case elevated
    case flat
}

// MARK: - Button Styles
enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary: return ShvilDesign.Colors.primary
        case .secondary: return ShvilDesign.Colors.secondaryBackground
        case .tertiary: return Color.clear
        case .destructive: return ShvilDesign.Colors.error
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return ShvilDesign.Colors.primaryText
        case .tertiary: return ShvilDesign.Colors.primary
        case .destructive: return .white
        }
    }
}
