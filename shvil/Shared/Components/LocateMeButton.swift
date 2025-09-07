//
//  LocateMeButton.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Enhanced locate me button with liquid glass effects and ocean blue turquoise when active
struct LocateMeButton: View {
    @Binding var isLocating: Bool
    let onTap: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var pulseAnimation: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                outerGlowEffect
                mainButton
                buttonIcon
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {
            // Long press action if needed
        }
        .onChange(of: isLocating) { _, newValue in
            if newValue {
                pulseAnimation = true
            } else {
                pulseAnimation = false
            }
        }
        .shadow(
            color: isLocating ? 
            DesignTokens.Brand.primary.opacity(0.3) : 
            Color.black.opacity(0.1),
            radius: isLocating ? 12 : 8,
            x: 0,
            y: isLocating ? 6 : 4
        )
    }
    
    private var outerGlowEffect: some View {
        Group {
            if isLocating {
                Circle()
                    .fill(glowGradient)
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(pulseAnimation ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
            }
        }
    }
    
    private var glowGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.blue.opacity(0.4),
                Color.blue.opacity(0.2),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 30
        )
    }
    
    private var mainButton: some View {
        Circle()
            .fill(buttonFill)
            .saturation(isLocating ? 1.0 : 1.1)
            .frame(width: 44, height: 44)
            .overlay(buttonBorder)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isLocating)
    }
    
    private var buttonFill: AnyShapeStyle {
        if isLocating {
            return AnyShapeStyle(Color.blue.opacity(0.8))
        } else {
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }
    
    private var buttonBorder: some View {
        Circle()
            .stroke(borderGradient, lineWidth: isLocating ? 1.0 : 0.5)
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: isLocating ? [
                Color.white.opacity(0.4),
                Color.white.opacity(0.2)
            ] : [
                Color.white.opacity(0.3),
                Color.white.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var buttonIcon: some View {
        Image(systemName: isLocating ? "location.fill" : "location")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(isLocating ? .white : DesignTokens.Brand.primary)
            .scaleEffect(isLocating ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLocating)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            LocateMeButton(isLocating: .constant(false)) {
                print("Locate me tapped")
            }
            
            LocateMeButton(isLocating: .constant(true)) {
                print("Locate me tapped")
            }
        }
        
        HStack(spacing: 20) {
            LocateMeButton(isLocating: .constant(false)) {
                print("Locate me tapped")
            }
            
            LocateMeButton(isLocating: .constant(true)) {
                print("Locate me tapped")
            }
        }
        .environment(\.colorScheme, .dark)
    }
    .padding()
    .background(DesignTokens.Surface.background)
}
