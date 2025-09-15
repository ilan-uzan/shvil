//
//  OSVersionDetection.swift
//  shvil
//
//  OS version detection for iOS 26 Liquid Glass vs glassmorphism fallback
//

import SwiftUI
import UIKit

/// OS version detection utilities for applying appropriate styling
public struct OSVersionDetection {
    
    /// Check if the current iOS version supports Liquid Glass (iOS 26+)
    public static var supportsLiquidGlass: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
    
    /// Check if the current iOS version supports glassmorphism (iOS 16+)
    public static var supportsGlassmorphism: Bool {
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
    
    /// Get the appropriate material style based on iOS version
    public static var preferredMaterialStyle: Material {
        if supportsLiquidGlass {
            return .ultraThinMaterial
        } else if supportsGlassmorphism {
            return .ultraThinMaterial
        } else {
            return .regularMaterial
        }
    }
    
    /// Get the appropriate glass surface style
    public static var glassSurfaceStyle: GlassSurfaceStyle {
        if supportsLiquidGlass {
            return .liquidGlass
        } else {
            return .glassmorphism
        }
    }
}

/// Glass surface styles for different iOS versions
public enum GlassSurfaceStyle {
    case liquidGlass    // iOS 26+ - Apple's Liquid Glass
    case glassmorphism  // iOS 16-25 - Traditional glassmorphism
    
    var material: Material {
        switch self {
        case .liquidGlass:
            return .ultraThinMaterial
        case .glassmorphism:
            return .ultraThinMaterial
        }
    }
    
    var strokeOpacity: Double {
        switch self {
        case .liquidGlass:
            return 0.08  // Subtle stroke for Liquid Glass
        case .glassmorphism:
            return 0.12  // More visible stroke for glassmorphism
        }
    }
    
    var backgroundOpacity: Double {
        switch self {
        case .liquidGlass:
            return 0.55  // More opaque for Liquid Glass
        case .glassmorphism:
            return 0.45  // More transparent for glassmorphism
        }
    }
}
