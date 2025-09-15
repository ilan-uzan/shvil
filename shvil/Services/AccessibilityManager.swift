//
//  AccessibilityManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI
import Combine

/// Comprehensive accessibility management system
@MainActor
public class AccessibilityManager: ObservableObject {
    // MARK: - Singleton
    
    public static let shared = AccessibilityManager()
    
    // MARK: - Published Properties
    
    @Published public var isVoiceOverEnabled = false
    @Published public var isReduceMotionEnabled = false
    @Published public var isReduceTransparencyEnabled = false
    @Published public var isIncreaseContrastEnabled = false
    @Published public var preferredContentSizeCategory: DynamicTypeSize = .medium
    @Published public var isRTLEnabled = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupAccessibilityObservers()
    }
    
    // MARK: - Setup
    
    private func setupAccessibilityObservers() {
        // VoiceOver
        NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
            }
            .store(in: &cancellables)
        
        // Reduce Motion
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
            }
            .store(in: &cancellables)
        
        // Reduce Transparency
        NotificationCenter.default.publisher(for: UIAccessibility.reduceTransparencyStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
            }
            .store(in: &cancellables)
        
        // Increase Contrast
        NotificationCenter.default.publisher(for: UIAccessibility.darkerSystemColorsStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isIncreaseContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
            }
            .store(in: &cancellables)
        
        // Content Size Category
        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [weak self] _ in
                self?.preferredContentSizeCategory = DynamicTypeSize(UIApplication.shared.preferredContentSizeCategory) ?? .medium
            }
            .store(in: &cancellables)
        
        // RTL
        NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                self?.isRTLEnabled = Locale.current.language.languageCode?.identifier == "he"
            }
            .store(in: &cancellables)
        
        // Initial values
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
        isIncreaseContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
        preferredContentSizeCategory = DynamicTypeSize(UIApplication.shared.preferredContentSizeCategory) ?? .medium
        isRTLEnabled = Locale.current.language.languageCode?.identifier == "he"
    }
    
    // MARK: - Public Methods
    
    /// Get appropriate animation for current accessibility settings
    public func getAccessibleAnimation() -> Animation? {
        guard !isReduceMotionEnabled else { return nil }
        return .easeInOut(duration: 0.3)
    }
    
    /// Get appropriate spring animation for current accessibility settings
    public func getAccessibleSpringAnimation(
        response: Double = 0.3,
        dampingFraction: Double = 0.8
    ) -> Animation? {
        guard !isReduceMotionEnabled else { return nil }
        return .spring(response: response, dampingFraction: dampingFraction)
    }
    
    /// Get appropriate transition for current accessibility settings
    public func getAccessibleTransition() -> AnyTransition {
        guard !isReduceMotionEnabled else { return .identity }
        return .opacity.combined(with: .scale(scale: 0.95))
    }
    
    /// Get appropriate color for current contrast settings
    public func getAccessibleColor(
        normal: Color,
        highContrast: Color
    ) -> Color {
        isIncreaseContrastEnabled ? highContrast : normal
    }
    
    /// Get appropriate font size for current content size category
    public func getAccessibleFontSize(
        baseSize: CGFloat,
        scaleFactor: CGFloat = 1.0
    ) -> CGFloat {
        let scaledSize = baseSize * scaleFactor
        
        switch preferredContentSizeCategory {
        case .xSmall:
            return scaledSize * 0.8
        case .small:
            return scaledSize * 0.9
        case .medium:
            return scaledSize
        case .large:
            return scaledSize * 1.1
        case .xLarge:
            return scaledSize * 1.2
        case .xxLarge:
            return scaledSize * 1.3
        case .xxxLarge:
            return scaledSize * 1.4
        case .accessibility1:
            return scaledSize * 1.5
        case .accessibility2:
            return scaledSize * 1.6
        case .accessibility3:
            return scaledSize * 1.7
        case .accessibility4:
            return scaledSize * 1.8
        case .accessibility5:
            return scaledSize * 1.9
        @unknown default:
            return scaledSize
        }
    }
    
    /// Get appropriate hit target size
    public func getAccessibleHitTargetSize() -> CGFloat {
        switch preferredContentSizeCategory {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return 60.0
        default:
            return 44.0
        }
    }
    
    /// Get appropriate spacing for current content size category
    public func getAccessibleSpacing(
        baseSpacing: CGFloat,
        scaleFactor: CGFloat = 1.0
    ) -> CGFloat {
        let scaledSpacing = baseSpacing * scaleFactor
        
        switch preferredContentSizeCategory {
        case .xSmall, .small:
            return scaledSpacing * 0.8
        case .medium:
            return scaledSpacing
        case .large, .xLarge, .xxLarge, .xxxLarge:
            return scaledSpacing * 1.2
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return scaledSpacing * 1.5
        @unknown default:
            return scaledSpacing
        }
    }
}

// MARK: - View Accessibility Extensions

extension View {
    /// Apply comprehensive accessibility support
    public func accessible(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = [],
        action: (() -> Void)? = nil
    ) -> some View {
        self
            .accessibilityLabel(label ?? "")
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
            .onTapGesture {
                action?()
            }
    }
    
    /// Apply button accessibility
    public func accessibleButton(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                action()
            }
    }
    
    /// Apply header accessibility
    public func accessibleHeader(
        label: String,
        level: Int = 1
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Apply image accessibility
    public func accessibleImage(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isImage)
    }
    
    /// Apply toggle accessibility
    public func accessibleToggle(
        label: String,
        hint: String? = nil,
        isOn: Bool,
        action: @escaping () -> Void
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(isOn ? "On" : "Off")
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                action()
            }
    }
    
    /// Apply list accessibility
    public func accessibleList(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Apply dynamic type support
    public func dynamicTypeSupport() -> some View {
        self
            .dynamicTypeSize(.small ... .accessibility5)
    }
    
    /// Apply RTL support
    public func rtlSupport() -> some View {
        self
            .environment(\.layoutDirection, AccessibilityManager.shared.isRTLEnabled ? .rightToLeft : .leftToRight)
    }
    
    /// Apply accessible animation
    public func accessibleAnimation() -> some View {
        self
            .animation(AccessibilityManager.shared.getAccessibleAnimation(), value: UUID())
    }
    
    /// Apply accessible spring animation
    public func accessibleSpringAnimation(
        response: Double = 0.3,
        dampingFraction: Double = 0.8
    ) -> some View {
        self
            .animation(
                AccessibilityManager.shared.getAccessibleSpringAnimation(
                    response: response,
                    dampingFraction: dampingFraction
                ),
                value: UUID()
            )
    }
    
    /// Apply accessible transition
    public func accessibleTransition() -> some View {
        self
            .transition(AccessibilityManager.shared.getAccessibleTransition())
    }
    
    /// Apply accessible hit target
    public func accessibleHitTarget() -> some View {
        self
            .frame(minWidth: AccessibilityManager.shared.getAccessibleHitTargetSize(),
                   minHeight: AccessibilityManager.shared.getAccessibleHitTargetSize())
    }
    
    /// Apply accessible spacing
    public func accessibleSpacing(
        baseSpacing: CGFloat,
        scaleFactor: CGFloat = 1.0
    ) -> some View {
        self
            .padding(AccessibilityManager.shared.getAccessibleSpacing(
                baseSpacing: baseSpacing,
                scaleFactor: scaleFactor
            ))
    }
    
    /// Apply accessible color
    public func accessibleColor(
        normal: Color,
        highContrast: Color
    ) -> some View {
        self
            .foregroundColor(AccessibilityManager.shared.getAccessibleColor(
                normal: normal,
                highContrast: highContrast
            ))
    }
    
    /// Apply accessible background color
    public func accessibleBackgroundColor(
        normal: Color,
        highContrast: Color
    ) -> some View {
        self
            .background(AccessibilityManager.shared.getAccessibleColor(
                normal: normal,
                highContrast: highContrast
            ))
    }
}
