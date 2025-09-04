//
//  LiquidGlassDesign.swift
//  shvil
//
//  Created by Shvil Team on 2024.
//  Liquid Glass Design System for Shvil Minimal
//

import SwiftUI

// MARK: - Color Tokens
struct LiquidGlassColors {
    // Primary Colors
    static let icyTurquoise = Color(red: 0.49, green: 0.83, blue: 0.99) // #7DD3FC
    static let deepAqua = Color(red: 0.05, green: 0.58, blue: 0.53) // #0D9488
    
    // Glass Surface Colors
    static let glassSurface1 = Color.white.opacity(0.1)
    static let glassSurface2 = Color.white.opacity(0.15)
    static let glassSurface3 = Color.white.opacity(0.2)
    
    // Text Colors
    static let primaryText = Color(red: 0.12, green: 0.16, blue: 0.22) // #1F2937
    static let secondaryText = Color(red: 0.42, green: 0.45, blue: 0.50) // #6B7280
    static let accentText = icyTurquoise
    
    // Dark Mode Adaptations
    static let darkGlassSurface1 = Color.black.opacity(0.1)
    static let darkGlassSurface2 = Color.black.opacity(0.15)
    static let darkGlassSurface3 = Color.black.opacity(0.2)
    static let darkPrimaryText = Color.white
    static let darkSecondaryText = Color(red: 0.75, green: 0.78, blue: 0.83) // #BFC2C7
}

// MARK: - Typography Tokens
struct LiquidGlassTypography {
    // Font Sizes
    static let largeTitle: CGFloat = 34
    static let title1: CGFloat = 28
    static let title2: CGFloat = 22
    static let title3: CGFloat = 20
    static let headline: CGFloat = 17
    static let body: CGFloat = 17
    static let callout: CGFloat = 16
    static let subhead: CGFloat = 15
    static let footnote: CGFloat = 13
    static let caption1: CGFloat = 12
    static let caption2: CGFloat = 11
    
    // Font Weights
    static let bold = Font.Weight.bold
    static let semibold = Font.Weight.semibold
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
}

// MARK: - Spacing Tokens
struct LiquidGlassSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Animation Tokens
struct LiquidGlassAnimations {
    static let microInteraction = Animation.easeOut(duration: 0.15)
    static let transition = Animation.easeInOut(duration: 0.3)
    static let pageTransition = Animation.easeInOut(duration: 0.5)
    
    // Ripple Animation
    static let ripple = Animation.easeOut(duration: 0.2)
    static let rippleScale: CGFloat = 1.05
}

// MARK: - Glass Effect Modifiers
struct GlassEffectModifier: ViewModifier {
    let elevation: GlassElevation
    @Environment(\.colorScheme) var colorScheme
    
    enum GlassElevation {
        case light
        case medium
        case high
    }
    
    func body(content: Content) -> some View {
        content
            .background(glassBackground)
            .overlay(glassOverlay)
            .shadow(color: glassShadow, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(glassColor)
            .blur(radius: blurRadius)
    }
    
    private var glassOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(overlayColor)
            .blendMode(.overlay)
    }
    
    private var glassColor: Color {
        switch elevation {
        case .light:
            return colorScheme == .dark ? LiquidGlassColors.darkGlassSurface1 : LiquidGlassColors.glassSurface1
        case .medium:
            return colorScheme == .dark ? LiquidGlassColors.darkGlassSurface2 : LiquidGlassColors.glassSurface2
        case .high:
            return colorScheme == .dark ? LiquidGlassColors.darkGlassSurface3 : LiquidGlassColors.glassSurface3
        }
    }
    
    private var overlayColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.2)
    }
    
    private var blurRadius: CGFloat {
        switch elevation {
        case .light: return 20
        case .medium: return 30
        case .high: return 40
        }
    }
    
    private var shadowRadius: CGFloat {
        switch elevation {
        case .light: return 8
        case .medium: return 12
        case .high: return 16
        }
    }
    
    private var shadowOffset: CGFloat {
        switch elevation {
        case .light: return 4
        case .medium: return 6
        case .high: return 8
        }
    }
    
    private var glassShadow: Color {
        Color.black.opacity(0.15)
    }
}

// MARK: - Ripple Effect Modifier
struct RippleEffectModifier: ViewModifier {
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .overlay(
                Circle()
                    .fill(LiquidGlassColors.accentText.opacity(0.3))
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
            )
            .onTapGesture {
                withAnimation(LiquidGlassAnimations.ripple) {
                    rippleScale = LiquidGlassAnimations.rippleScale
                    rippleOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(LiquidGlassAnimations.ripple) {
                        rippleScale = 0
                        rippleOpacity = 0
                    }
                }
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(LiquidGlassAnimations.microInteraction) {
                    isPressed = pressing
                }
            }, perform: {})
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Gradient Tokens
struct LiquidGlassGradients {
    static let primaryGradient = LinearGradient(
        colors: [LiquidGlassColors.icyTurquoise, LiquidGlassColors.deepAqua],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let routeGradient = LinearGradient(
        colors: [LiquidGlassColors.icyTurquoise, LiquidGlassColors.deepAqua],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Extensions
extension View {
    func glassEffect(elevation: GlassEffectModifier.GlassElevation = .medium) -> some View {
        modifier(GlassEffectModifier(elevation: elevation))
    }
    
    func rippleEffect() -> some View {
        modifier(RippleEffectModifier())
    }
    
    func liquidGlassStyle() -> some View {
        self
            .glassEffect(elevation: .medium)
            .rippleEffect()
    }
}

// MARK: - Design System Preview
struct LiquidGlassDesign_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Search Pill
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(LiquidGlassColors.secondaryText)
                Text("Search places or address")
                    .foregroundColor(LiquidGlassColors.secondaryText)
                Spacer()
            }
            .padding()
            .glassEffect(elevation: .light)
            .cornerRadius(25)
            
            // FAB Button
            Button(action: {}) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(LiquidGlassColors.primaryText)
            }
            .frame(width: 56, height: 56)
            .glassEffect(elevation: .medium)
            .clipShape(Circle())
            .rippleEffect()
            
            // Instruction Card
            VStack(alignment: .leading, spacing: 8) {
                Text("Turn right onto Main Street")
                    .font(.system(size: LiquidGlassTypography.headline, weight: LiquidGlassTypography.semibold))
                    .foregroundColor(LiquidGlassColors.primaryText)
                Text("In 200 feet")
                    .font(.system(size: LiquidGlassTypography.subhead))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding()
            .glassEffect(elevation: .high)
            .cornerRadius(16)
            
            // Gradient Route Line
            Rectangle()
                .fill(LiquidGlassGradients.routeGradient)
                .frame(height: 6)
                .cornerRadius(3)
                .shadow(color: LiquidGlassColors.icyTurquoise.opacity(0.4), radius: 4, x: 0, y: 0)
        }
        .padding()
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
