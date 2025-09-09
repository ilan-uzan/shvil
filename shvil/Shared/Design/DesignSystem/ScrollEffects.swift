//
//  ScrollEffects.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Enhanced scroll effects for Shvil's Liquid Glass design system
struct ScrollEffects {
    
    // MARK: - Parallax Effects
    
    /// Creates a parallax effect for background elements
    static func parallaxEffectBackground(offset: CGFloat, speed: CGFloat = 0.5) -> CGFloat {
        return offset * speed
    }
    
    /// Creates a parallax effect for foreground elements
    static func parallaxEffectForeground(offset: CGFloat, speed: CGFloat = 1.5) -> CGFloat {
        return offset * speed
    }
}

// MARK: - Scroll View Modifiers

extension ScrollView {
    /// Adds enhanced scroll effects with parallax and blur
    func enhancedScrollEffects() -> some View {
        self
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
    }
    
    /// Adds flexible header scroll effects
    @MainActor func flexibleHeaderScrollEffects() -> some View {
        self
            .flexibleHeaderScrollView()
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
    }
}

// MARK: - View Modifiers for Scroll Effects

struct ParallaxModifier: ViewModifier {
    let speed: CGFloat
    @State private var offset: CGFloat = 0
    
    init(speed: CGFloat = 0.5) {
        self.speed = speed
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset * speed)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newOffset in
                offset = newOffset
            }
    }
}

struct BlurOnScrollModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let maxBlur: CGFloat
    
    init(maxBlur: CGFloat = 10) {
        self.maxBlur = maxBlur
    }
    
    func body(content: Content) -> some View {
        content
            .blur(radius: min(abs(offset) * 0.1, maxBlur))
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newOffset in
                offset = newOffset
            }
    }
}

struct ScaleOnScrollModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let minScale: CGFloat
    let maxScale: CGFloat
    
    init(minScale: CGFloat = 0.8, maxScale: CGFloat = 1.2) {
        self.minScale = minScale
        self.maxScale = maxScale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(calculateScale())
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newOffset in
                offset = newOffset
            }
    }
    
    private func calculateScale() -> CGFloat {
        let progress = min(abs(offset) / 200, 1.0)
        return minScale + (maxScale - minScale) * (1 - progress)
    }
}

// MARK: - Adventure-Specific Scroll Effects

struct AdventureScrollEffects: ViewModifier {
    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newOffset in
                scrollOffset = newOffset
            }
            .onGeometryChange(for: CGFloat.self, of: \.size.height) { _, newHeight in
                headerHeight = newHeight
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Adds parallax effect to the view
    func parallaxEffect(speed: CGFloat = 0.5) -> some View {
        modifier(ParallaxModifier(speed: speed))
    }
    
    /// Adds blur effect based on scroll position
    func blurOnScroll(maxBlur: CGFloat = 10) -> some View {
        modifier(BlurOnScrollModifier(maxBlur: maxBlur))
    }
    
    /// Adds scale effect based on scroll position
    func scaleOnScroll(minScale: CGFloat = 0.8, maxScale: CGFloat = 1.2) -> some View {
        modifier(ScaleOnScrollModifier(minScale: minScale, maxScale: maxScale))
    }
    
    /// Adds adventure-specific scroll effects
    func adventureScrollEffects() -> some View {
        modifier(AdventureScrollEffects())
    }
}

// MARK: - Glass Scroll Effects

struct GlassScrollEffect: ViewModifier {
    @State private var scrollOffset: CGFloat = 0
    let baseOpacity: Double
    let maxOpacity: Double
    
    init(baseOpacity: Double = 0.3, maxOpacity: Double = 0.8) {
        self.baseOpacity = baseOpacity
        self.maxOpacity = maxOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(calculateOpacity())
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newOffset in
                scrollOffset = newOffset
            }
    }
    
    private func calculateOpacity() -> Double {
        let progress = min(abs(scrollOffset) / 100, 1.0)
        return baseOpacity + (maxOpacity - baseOpacity) * progress
    }
}

extension View {
    /// Adds glass effect that changes opacity based on scroll
    func glassScrollEffect(baseOpacity: Double = 0.3, maxOpacity: Double = 0.8) -> some View {
        modifier(GlassScrollEffect(baseOpacity: baseOpacity, maxOpacity: maxOpacity))
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct ScrollEffects_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: DesignTokens.Layout.cornerRadius)
                        .fill(DesignTokens.Brand.gradient)
                        .frame(height: 100)
                        .overlay(
                            Text("Scroll Effect \(index + 1)")
                                .font(DesignTokens.Typography.headline)
                                .foregroundColor(.white)
                        )
                        .parallaxEffect(speed: 0.5)
                        .blurOnScroll(maxBlur: 5)
                        .scaleOnScroll(minScale: 0.9, maxScale: 1.1)
                }
            }
            .padding()
        }
        .enhancedScrollEffects()
    }
}
#endif
