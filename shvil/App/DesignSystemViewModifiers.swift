//
//  ViewModifiers.swift
//  shvil
//
//  Enhanced view modifiers for Apple-grade experiences
//

import SwiftUI

// MARK: - Apple Performance Optimization
extension View {
    /// Apple-grade performance optimization for complex views
    public func applePerformanceOptimized() -> some View {
        self
            .drawingGroup() // Rasterize complex views for better performance
            .compositingGroup() // Optimize layer compositing
    }
}

// MARK: - Apple Accessibility
extension View {
    /// Comprehensive Apple accessibility support
    public func appleAccessibility(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label ?? "")
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Accessible button implementation following Apple HIG
    public func accessibleButton(
        label: String,
        hint: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Double tap to activate")
            .accessibilityAddTraits(.isButton)
            .onTapGesture(perform: action)
    }
    
    /// Ensures minimum hit target size for accessibility (44pt)
    public func accessibleHitTarget(size: CGFloat = 44) -> some View {
        self
            .frame(minWidth: size, minHeight: size)
    }
    
    /// Button accessibility modifier following Apple HIG
    public func buttonAccessibility(
        label: String,
        hint: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Double tap to activate")
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                action?()
            }
    }
    
    /// List item accessibility modifier
    public func listItemAccessibility(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Apple Shadow System
extension View {
    /// Apply shadow using ShadowValue design tokens
    public func appleShadow(_ shadow: ShadowValue) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Apple Animation System

// MARK: - Apple Corner Radius System
// Note: AppleCornerRadius is defined in AppleGlassComponents.swift

// MARK: - Liquid Glass Effects
extension View {
    /// Apply Liquid Glass effect with depth and translucency
    public func liquidGlassEffect(
        style: LiquidGlassStyle = .medium,
        cornerRadius: CGFloat = DesignTokens.CornerRadius.xxl
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(style.backgroundColor)
                            .overlay(
                                // Inner highlight for depth
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                                    .blendMode(.overlay)
                            )
                    )
            )
            .applyShadow(style.shadow)
    }
    
    /// Apply glassmorphism effect with intensity and corner radius
    public func glassmorphism(
        intensity: GlassmorphismIntensity = .medium,
        cornerRadius: CGFloat = 12
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(intensity.backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 0.5)
                                    .blendMode(.overlay)
                            )
                    )
            )
            .applyShadow(intensity.shadow)
    }
    
    /// Apply shadow with proper parameters
    private func applyShadow(_ shadow: ShadowValue) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Liquid Glass Style Options
public enum LiquidGlassStyle {
    case light
    case medium
    case heavy
    case glass
    
    var backgroundColor: Color {
        switch self {
        case .light: return DesignTokens.Glass.light
        case .medium: return DesignTokens.Glass.medium
        case .heavy: return DesignTokens.Glass.heavy
        case .glass: return DesignTokens.Surface.primary
        }
    }
    
    var shadow: ShadowValue {
        switch self {
        case .light: return DesignTokens.Shadow.light
        case .medium: return DesignTokens.Shadow.medium
        case .heavy: return DesignTokens.Shadow.heavy
        case .glass: return DesignTokens.Shadow.glass
        }
    }
}

// MARK: - Glassmorphism Intensity Options
public enum GlassmorphismIntensity {
    case light
    case medium
    case heavy
    
    var backgroundColor: Color {
        switch self {
        case .light: return DesignTokens.Glass.light
        case .medium: return DesignTokens.Glass.medium
        case .heavy: return DesignTokens.Glass.heavy
        }
    }
    
    var shadow: ShadowValue {
        switch self {
        case .light: return DesignTokens.Shadow.light
        case .medium: return DesignTokens.Shadow.medium
        case .heavy: return DesignTokens.Shadow.heavy
        }
    }
}

// MARK: - Haptic Feedback
extension View {
    /// Apple-style loading indicator
    public func appleLoadingOverlay(
        isLoading: Bool,
        message: String? = nil
    ) -> some View {
        self
            .overlay(
                Group {
                    if isLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack(spacing: DesignTokens.Spacing.md) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Brand.primary))
                                
                                if let message = message {
                                    Text(message)
                                        .font(DesignTokens.Typography.footnote)
                                        .foregroundColor(DesignTokens.Text.secondary)
                                }
                            }
                            .padding(DesignTokens.Spacing.xl)
                            .background(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                    .fill(.regularMaterial)
                            )
                        }
                        .transition(.opacity.combined(with: .scale))
                        .animation(DesignTokens.Animation.standard, value: isLoading)
                    }
                }
            )
    }
}

// MARK: - Error States  
extension View {
    /// Apple-style error presentation
    public func appleErrorOverlay(
        error: Error?,
        retry: @escaping () -> Void
    ) -> some View {
        self
            .overlay(
                ZStack {
                    if let error = error {
                        VStack(spacing: DesignTokens.Spacing.lg) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(DesignTokens.Semantic.error)
                            
                            VStack(spacing: DesignTokens.Spacing.sm) {
                                Text("Something went wrong")
                                    .font(DesignTokens.Typography.title3)
                                    .foregroundColor(DesignTokens.Text.primary)
                                
                                Text(error.localizedDescription)
                                    .font(DesignTokens.Typography.body)
                                    .foregroundColor(DesignTokens.Text.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: retry) {
                                Text("Try Again")
                                    .font(DesignTokens.Typography.bodyEmphasized)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, DesignTokens.Spacing.lg)
                                    .padding(.vertical, DesignTokens.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                                            .fill(DesignTokens.Brand.primary)
                                    )
                            }
                        }
                        .padding(DesignTokens.Spacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .fill(.regularMaterial)
                        )
                        .transition(.opacity.combined(with: .scale))
                        .animation(DesignTokens.Animation.standard, value: error.localizedDescription)
                    }
                }
            )
    }
}

// MARK: - Landmarks Liquid Glass Patterns

// MARK: - Flexible Header (Landmarks Pattern)

@Observable private class FlexibleHeaderGeometry {
    var offset: CGFloat = 0
}

/// A view modifier that stretches content when the containing geometry offset changes
private struct FlexibleHeaderContentModifier: ViewModifier {
    @Environment(FlexibleHeaderGeometry.self) private var geometry
    
    func body(content: Content) -> some View {
        GeometryReader { geometryReader in
            let height = (geometryReader.size.height / 2) - geometry.offset
            content
                .frame(height: height)
                .padding(.bottom, geometry.offset)
                .offset(y: geometry.offset)
        }
    }
}

/// A view modifier that tracks scroll view geometry to stretch a view
private struct FlexibleHeaderScrollViewModifier: ViewModifier {
    @State private var geometry = FlexibleHeaderGeometry()
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometryReader in
                    Color.clear
                        .onAppear {
                            // Initialize with current scroll position
                            geometry.offset = 0
                        }
                }
            )
            .environment(geometry)
    }
}

// MARK: - Background Extension Effect (Landmarks Pattern)

/// A view modifier that extends the background beyond safe areas
struct BackgroundExtensionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(.clear)
                    .ignoresSafeArea()
            )
    }
}

// MARK: - Landmarks View Extensions

extension View {
    /// Apply background extension effect (Landmarks pattern)
    func backgroundExtensionEffect() -> some View {
        modifier(BackgroundExtensionModifier())
    }
}