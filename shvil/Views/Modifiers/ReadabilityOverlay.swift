//
//  ReadabilityOverlay.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// A view that adds a gradient over an image to improve legibility for text overlays
struct ReadabilityRoundedRectangle: View {
    let cornerRadius: CGFloat
    let gradientColors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(
        cornerRadius: CGFloat = DesignTokens.Layout.cornerRadius,
        gradientColors: [Color] = [.black.opacity(0.8), .clear],
        startPoint: UnitPoint = .bottom,
        endPoint: UnitPoint = .center
    ) {
        self.cornerRadius = cornerRadius
        self.gradientColors = gradientColors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(.clear)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .containerRelativeFrame(.vertical)
            .clipped()
    }
}

/// A specialized readability overlay for adventure cards
struct AdventureReadabilityOverlay: View {
    let style: ReadabilityStyle
    
    enum ReadabilityStyle {
        case bottomGradient
        case topGradient
        case fullGradient
        case custom(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint)
    }
    
    init(style: ReadabilityStyle = .bottomGradient) {
        self.style = style
    }
    
    var body: some View {
        switch style {
        case .bottomGradient:
            ReadabilityRoundedRectangle(
                cornerRadius: DesignTokens.Layout.adventureCardCornerRadius,
                gradientColors: [
                    .black.opacity(0.7),
                    .black.opacity(0.3),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .center
            )
            
        case .topGradient:
            ReadabilityRoundedRectangle(
                cornerRadius: DesignTokens.Layout.adventureCardCornerRadius,
                gradientColors: [
                    .black.opacity(0.7),
                    .black.opacity(0.3),
                    .clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            
        case .fullGradient:
            ReadabilityRoundedRectangle(
                cornerRadius: DesignTokens.Layout.adventureCardCornerRadius,
                gradientColors: [
                    .black.opacity(0.6),
                    .black.opacity(0.2),
                    .black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case .custom(let colors, let startPoint, let endPoint):
            ReadabilityRoundedRectangle(
                cornerRadius: DesignTokens.Layout.adventureCardCornerRadius,
                gradientColors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
    }
}

/// A readability overlay for map views
struct MapReadabilityOverlay: View {
    let intensity: ReadabilityIntensity
    
    enum ReadabilityIntensity {
        case light
        case medium
        case heavy
    }
    
    init(intensity: ReadabilityIntensity = .medium) {
        self.intensity = intensity
    }
    
    var body: some View {
        let opacity: Double = switch intensity {
        case .light: 0.3
        case .medium: 0.5
        case .heavy: 0.7
        }
        
        ReadabilityRoundedRectangle(
            cornerRadius: DesignTokens.Layout.cornerRadius,
            gradientColors: [
                .black.opacity(opacity),
                .black.opacity(opacity * 0.5),
                .clear
            ],
            startPoint: .bottom,
            endPoint: .center
        )
    }
}

/// A readability overlay for stop cards
struct StopReadabilityOverlay: View {
    var body: some View {
        ReadabilityRoundedRectangle(
            cornerRadius: DesignTokens.Layout.stopCardCornerRadius,
            gradientColors: [
                .black.opacity(0.6),
                .black.opacity(0.2),
                .clear
            ],
            startPoint: .bottom,
            endPoint: .center
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Adds a readability overlay to improve text legibility over images
    func readabilityOverlay(
        style: AdventureReadabilityOverlay.ReadabilityStyle = .bottomGradient
    ) -> some View {
        ZStack {
            self
            AdventureReadabilityOverlay(style: style)
        }
    }
    
    /// Adds a map-specific readability overlay
    func mapReadabilityOverlay(
        intensity: MapReadabilityOverlay.ReadabilityIntensity = .medium
    ) -> some View {
        ZStack {
            self
            MapReadabilityOverlay(intensity: intensity)
        }
    }
    
    /// Adds a stop card readability overlay
    func stopReadabilityOverlay() -> some View {
        ZStack {
            self
            StopReadabilityOverlay()
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct ReadabilityOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Adventure card with readability overlay
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Layout.adventureCardCornerRadius)
                    .fill(DesignTokens.Brand.gradient)
                    .frame(height: DesignTokens.Layout.adventureCardHeight)
                
                VStack {
                    Spacer()
                    Text("Adventure Title")
                        .font(DesignTokens.Typography.title)
                        .foregroundColor(.white)
                    Text("3 stops planned")
                        .font(DesignTokens.Typography.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
            .readabilityOverlay(style: .bottomGradient)
            
            // Map with readability overlay
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Layout.cornerRadius)
                    .fill(DesignTokens.Brand.gradient)
                    .frame(height: 200)
                
                VStack {
                    Spacer()
                    Text("Map Location")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(.white)
                }
                .padding()
            }
            .mapReadabilityOverlay(intensity: .medium)
        }
        .padding()
    }
}
#endif
