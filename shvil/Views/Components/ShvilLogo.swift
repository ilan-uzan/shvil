//
//  ShvilLogo.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Mock Shvil logo component based on the app icon design
/// Features: Liquid glass S-shaped curve in a circle with glossy highlights
struct ShvilLogo: View {
    let size: CGFloat
    let showGlow: Bool
    
    init(size: CGFloat = 24, showGlow: Bool = true) {
        self.size = size
        self.showGlow = showGlow
    }
    
    var body: some View {
        ZStack {
            // Outer glow effect
            if showGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DesignTokens.Brand.primary.opacity(0.3),
                                DesignTokens.Brand.primary.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.8
                        )
                    )
                    .frame(width: size * 1.6, height: size * 1.6)
                    .blur(radius: 4)
            }
            
            // Main logo container
            ZStack {
                // White rounded square background
                RoundedRectangle(cornerRadius: size * 0.2)
                    .fill(Color.white)
                    .frame(width: size, height: size)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                
                // Blue circular outline
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                DesignTokens.Brand.primary,
                                DesignTokens.Brand.primary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: size * 0.08
                    )
                    .frame(width: size * 0.7, height: size * 0.7)
                    .overlay(
                        // Highlight on top-left
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                ),
                                lineWidth: size * 0.04
                            )
                            .frame(width: size * 0.7, height: size * 0.7)
                    )
                
                // S-shaped curve
                SCurveShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Brand.primary,
                                DesignTokens.Brand.primary.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.5, height: size * 0.5)
                    .overlay(
                        // S-curve highlight
                        SCurveShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: size * 0.5, height: size * 0.5)
                    )
            }
        }
    }
}

/// Custom S-shaped curve path
struct SCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create a flowing S-shape
        let centerX = width / 2
        let centerY = height / 2
        
        // Upper curve (thinner, more open)
        path.move(to: CGPoint(x: centerX - width * 0.15, y: height * 0.2))
        path.addCurve(
            to: CGPoint(x: centerX + width * 0.15, y: centerY - height * 0.1),
            control1: CGPoint(x: centerX - width * 0.25, y: height * 0.1),
            control2: CGPoint(x: centerX - width * 0.05, y: centerY - height * 0.2)
        )
        
        // Lower curve (thicker, more pronounced)
        path.addCurve(
            to: CGPoint(x: centerX - width * 0.15, y: height * 0.8),
            control1: CGPoint(x: centerX + width * 0.25, y: centerY + height * 0.1),
            control2: CGPoint(x: centerX + width * 0.05, y: centerY + height * 0.2)
        )
        
        // Add line width by creating a stroke
        return path.strokedPath(StrokeStyle(lineWidth: width * 0.12, lineCap: .round, lineJoin: .round))
    }
}

