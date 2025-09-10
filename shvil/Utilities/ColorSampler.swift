//
//  ColorSampler.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import UIKit

/// Utility for sampling colors from on-screen content and providing safe, clamped tints
/// for the Liquid Glass navigation bar
@MainActor
class ColorSampler: ObservableObject {
    static let shared = ColorSampler()
    
    private var colorCache: [String: Color] = [:]
    private let maxCacheSize = 3
    private var cacheKeys: [String] = []
    
    private init() {}
    
    /// Sample a color from the current context and return a safe tint
    /// - Parameters:
    ///   - context: The current context (map theme, mode chip, header artwork, etc.)
    ///   - accent: Optional accent color hint
    /// - Returns: A safe, clamped tint color that maintains contrast
    func sampleTint(context: ColorContext, accent: Color? = nil) -> Color {
        let cacheKey = "\(context.rawValue)_\(accent?.description ?? "nil")"
        
        // Check cache first
        if let cachedColor = colorCache[cacheKey] {
            return cachedColor
        }
        
        let sampledColor = performColorSampling(context: context, accent: accent)
        let safeTint = clampForContrast(sampledColor)
        
        // Cache the result
        cacheColor(safeTint, for: cacheKey)
        
        return safeTint
    }
    
    /// Get a tint based on the current tab/mode
    func getTintForMode(_ mode: NavigationMode) -> Color {
        switch mode {
        case .map:
            return DesignTokens.Brand.primary
        case .socialize:
            return DesignTokens.Semantic.success
        case .hunt:
            return DesignTokens.Semantic.warning
        case .adventure:
            return DesignTokens.Brand.primaryMid
        case .settings:
            return DesignTokens.Text.primary
        }
    }
    
    /// Clear the color cache
    func clearCache() {
        colorCache.removeAll()
        cacheKeys.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func performColorSampling(context: ColorContext, accent: Color? = nil) -> Color {
        // In a real implementation, this would sample actual screen content
        // For now, we'll use the accent color or fallback to context-based colors
        
        if let accent = accent {
            return accent
        }
        
        switch context {
        case .mapTheme:
            return DesignTokens.Brand.primary
        case .modeChip:
            return DesignTokens.Semantic.info
        case .headerArtwork:
            return DesignTokens.Brand.primaryMid
        case .cardAccent:
            return DesignTokens.Semantic.success
        case .default:
            return DesignTokens.Brand.primary
        }
    }
    
    private func clampForContrast(_ color: Color) -> Color {
        // Ensure the color has sufficient contrast against the background
        let uiColor = UIColor(color)
        let backgroundColor = UIColor(DesignTokens.Surface.background)
        
        // Calculate contrast ratio
        let contrastRatio = calculateContrastRatio(uiColor, backgroundColor)
        
        // If contrast is too low, adjust the color
        if contrastRatio < 3.0 { // AA minimum
            return adjustColorForContrast(color, backgroundColor)
        }
        
        return color
    }
    
    private func calculateContrastRatio(_ color1: UIColor, _ color2: UIColor) -> Double {
        let luminance1 = getLuminance(color1)
        let luminance2 = getLuminance(color2)
        
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func getLuminance(_ color: UIColor) -> Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert to sRGB
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func adjustColorForContrast(_ color: Color, _ backgroundColor: UIColor) -> Color {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Adjust brightness to improve contrast
        let adjustedBrightness = brightness > 0.5 ? brightness - 0.2 : brightness + 0.2
        
        return Color(UIColor(
            hue: hue,
            saturation: saturation,
            brightness: max(0, min(1, adjustedBrightness)),
            alpha: alpha
        ))
    }
    
    private func cacheColor(_ color: Color, for key: String) {
        // Implement LRU cache
        if cacheKeys.count >= maxCacheSize {
            let oldestKey = cacheKeys.removeFirst()
            colorCache.removeValue(forKey: oldestKey)
        }
        
        colorCache[key] = color
        cacheKeys.append(key)
    }
}

// MARK: - Supporting Types

enum ColorContext: String, CaseIterable {
    case mapTheme = "map_theme"
    case modeChip = "mode_chip"
    case headerArtwork = "header_artwork"
    case cardAccent = "card_accent"
    case `default` = "default"
}

enum NavigationMode: String, CaseIterable {
    case map = "map"
    case socialize = "socialize"
    case hunt = "hunt"
    case adventure = "adventure"
    case settings = "settings"
}
