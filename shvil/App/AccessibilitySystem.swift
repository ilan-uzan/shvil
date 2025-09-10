//
//  AccessibilitySystem.swift
//  shvil
//
//  Comprehensive accessibility system for Shvil
//

import SwiftUI
import UIKit

/// Centralized accessibility system for Shvil
public struct AccessibilitySystem {
    
    // MARK: - Dynamic Type Support
    
    /// Get scaled font size based on Dynamic Type settings
    public static func scaledFontSize(_ baseSize: CGFloat) -> CGFloat {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        return UIFontMetrics.default.scaledValue(for: baseSize, compatibleWith: contentSize)
    }
    
    /// Get scaled spacing based on Dynamic Type settings
    public static func scaledSpacing(_ baseSpacing: CGFloat) -> CGFloat {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        let scaleFactor = UIFontMetrics.default.scaledValue(for: 1.0, compatibleWith: contentSize)
        return baseSpacing * scaleFactor
    }
    
    /// Check if user prefers reduced motion
    public static var prefersReducedMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    /// Check if user prefers reduced transparency
    public static var prefersReducedTransparency: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }
    
    // MARK: - Touch Target Sizing
    
    /// Minimum touch target size (44pt as per Apple HIG)
    public static let minTouchTarget: CGFloat = 44
    
    /// Check if element meets minimum touch target requirements
    public static func meetsTouchTarget(_ size: CGSize) -> Bool {
        return size.width >= minTouchTarget && size.height >= minTouchTarget
    }
    
    // MARK: - VoiceOver Support
    
    /// Create accessibility label with hint
    public static func accessibilityLabel(_ label: String, hint: String? = nil) -> (String, String?) {
        return (label, hint)
    }
    
    /// Create accessibility action description
    public static func accessibilityAction(_ action: String, description: String) -> (String, String) {
        return (action, description)
    }
    
    // MARK: - RTL Support
    
    /// Check if current language is RTL
    public static var isRTL: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
    
    /// Get appropriate alignment for RTL support
    public static var leadingAlignment: HorizontalAlignment {
        return isRTL ? .trailing : .leading
    }
    
    /// Get appropriate alignment for RTL support
    public static var trailingAlignment: HorizontalAlignment {
        return isRTL ? .leading : .trailing
    }
    
    /// Get appropriate edge for RTL support
    public static var leadingEdge: Edge {
        return isRTL ? .trailing : .leading
    }
    
    /// Get appropriate edge for RTL support
    public static var trailingEdge: Edge {
        return isRTL ? .leading : .trailing
    }
}

/// Accessibility modifiers for SwiftUI views
extension View {
    
    /// Apply comprehensive accessibility support
    public func shvilAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = [],
        action: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
            .accessibilityAction(named: action ?? "") {
                // Action will be handled by the view
            }
    }
    
    /// Apply minimum touch target size
    public func minimumTouchTarget() -> some View {
        self
            .frame(minWidth: AccessibilitySystem.minTouchTarget, minHeight: AccessibilitySystem.minTouchTarget)
    }
    
    /// Apply RTL-aware padding
    public func rtlPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        if AccessibilitySystem.isRTL {
            return self.padding(edges, length)
        } else {
            return self.padding(edges, length)
        }
    }
    
    /// Apply RTL-aware alignment
    public func rtlAlignment(_ alignment: HorizontalAlignment) -> some View {
        let rtlAlignment: HorizontalAlignment = {
            switch alignment {
            case .leading:
                return AccessibilitySystem.leadingAlignment
            case .trailing:
                return AccessibilitySystem.trailingAlignment
            default:
                return alignment
            }
        }()
        
        return self.multilineTextAlignment(rtlAlignment == .leading ? .leading : .trailing)
    }
    
    /// Apply reduced motion animation
    public func reducedMotionAnimation<T: Equatable>(
        _ animation: Animation,
        value: T
    ) -> some View {
        if AccessibilitySystem.prefersReducedMotion {
            return self.animation(.linear(duration: 0.1), value: value)
        } else {
            return self.animation(animation, value: value)
        }
    }
    
    /// Apply reduced transparency background
    public func reducedTransparencyBackground<S: ShapeStyle>(
        _ style: S,
        fallback: Color
    ) -> some View {
        if AccessibilitySystem.prefersReducedTransparency {
            return self.background(fallback)
        } else {
            return self.background(style)
        }
    }
}

/// Accessibility traits for common UI elements
public struct AccessibilityTraits {
    public static let button: AccessibilityTraits = .isButton
    public static let header: AccessibilityTraits = .isHeader
    public static let image: AccessibilityTraits = .isImage
    public static let link: AccessibilityTraits = .isLink
    public static let searchField: AccessibilityTraits = .isSearchField
    public static let selected: AccessibilityTraits = .isSelected
    public static let staticText: AccessibilityTraits = .isStaticText
    public static let toggle: AccessibilityTraits = .isButton
    public static let adjustable: AccessibilityTraits = .isAdjustable
}

/// RTL-aware layout utilities
public struct RTLLayout {
    
    /// Get appropriate HStack alignment for RTL
    public static var hStackAlignment: HorizontalAlignment {
        return AccessibilitySystem.isRTL ? .trailing : .leading
    }
    
    /// Get appropriate VStack alignment for RTL
    public static var vStackAlignment: VerticalAlignment {
        return .top
    }
    
    /// Get appropriate text alignment for RTL
    public static var textAlignment: TextAlignment {
        return AccessibilitySystem.isRTL ? .trailing : .leading
    }
    
    /// Get appropriate image alignment for RTL
    public static var imageAlignment: HorizontalAlignment {
        return AccessibilitySystem.isRTL ? .trailing : .leading
    }
}
