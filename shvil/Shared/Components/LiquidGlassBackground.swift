//
//  LiquidGlassBackground.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Liquid Glass background component
public struct LiquidGlassBackground: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            // Base background
            LiquidGlassColors.background
                .ignoresSafeArea()
            
            // Glass effect overlay
            LinearGradient(
                colors: [
                    LiquidGlassColors.glassSurface.opacity(0.1),
                    LiquidGlassColors.glassSurface2.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}
