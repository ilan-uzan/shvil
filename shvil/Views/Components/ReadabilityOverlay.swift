//
//  ReadabilityOverlay.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// A view that adds a gradient over an image to improve legibility for a text overlay.
/// Following Landmarks Liquid Glass patterns for consistent readability.
struct ReadabilityOverlay: View {
    let cornerRadius: CGFloat
    let gradientColors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(
        cornerRadius: CGFloat = Constants.cornerRadius,
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

// MARK: - Convenience Initializers

extension ReadabilityOverlay {
    /// Standard readability overlay for text over images
    static func standard() -> ReadabilityOverlay {
        ReadabilityOverlay()
    }
    
    /// Strong readability overlay for better contrast
    static func strong() -> ReadabilityOverlay {
        ReadabilityOverlay(
            gradientColors: [.black.opacity(0.9), .clear]
        )
    }
    
    /// Light readability overlay for subtle text
    static func light() -> ReadabilityOverlay {
        ReadabilityOverlay(
            gradientColors: [.black.opacity(0.6), .clear]
        )
    }
    
    /// Custom readability overlay with specific colors
    static func custom(
        colors: [Color],
        cornerRadius: CGFloat = Constants.cornerRadius
    ) -> ReadabilityOverlay {
        ReadabilityOverlay(
            cornerRadius: cornerRadius,
            gradientColors: colors
        )
    }
}

// MARK: - #Preview

#Preview {
    ZStack {
        Image(systemName: "photo")
            .font(.system(size: 100))
            .foregroundColor(.gray)
            .frame(width: 200, height: 200)
            .background(Color.gray.opacity(0.3))
        
        ReadabilityOverlay.standard()
        
        VStack {
            Spacer()
            Text("Sample Text")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
        }
    }
    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
}
