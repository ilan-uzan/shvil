//
//  HapticFeedback.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import UIKit

/// Haptic feedback management
class HapticFeedback: ObservableObject {
    static let shared = HapticFeedback()

    @Published var isEnabled = true
    @Published var intensity: HapticIntensity = .medium

    init() {
        loadSettings()
    }

    func enable() {
        isEnabled = true
        saveSettings()
    }

    func disable() {
        isEnabled = false
        saveSettings()
    }

    func setIntensity(_ intensity: HapticIntensity) {
        self.intensity = intensity
        saveSettings()
    }

    // MARK: - Haptic Feedback Methods

    func success() {
        guard isEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    func error() {
        guard isEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }

    func warning() {
        guard isEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }

    func selection() {
        guard isEnabled else { return }
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }

    func safetyAlert() {
        guard isEnabled else { return }
        // Strong haptic for safety alerts
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()

        // Add a second haptic after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred()
        }
    }

    func navigationTurn() {
        guard isEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    func buttonPress() {
        guard isEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    func longPress() {
        guard isEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    func swipeGesture() {
        guard isEnabled else { return }
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }

    func customPattern(_ pattern: HapticPattern) {
        guard isEnabled else { return }

        switch pattern {
        case .doubleTap:
            impact(style: .light)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impact(style: .light)
            }
        case .tripleTap:
            impact(style: .light)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impact(style: .light)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.impact(style: .light)
            }
        case .pulse:
            impact(style: .medium)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.impact(style: .medium)
            }
        case .heartbeat:
            impact(style: .light)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impact(style: .heavy)
            }
        }
    }

    // MARK: - Private Methods

    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "haptic_enabled")
        if let intensityRaw = UserDefaults.standard.object(forKey: "haptic_intensity") as? String,
           let intensity = HapticIntensity(rawValue: intensityRaw)
        {
            self.intensity = intensity
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(isEnabled, forKey: "haptic_enabled")
        UserDefaults.standard.set(intensity.rawValue, forKey: "haptic_intensity")
    }
}

enum HapticIntensity: String, CaseIterable {
    case light
    case medium
    case heavy

    var displayName: String {
        switch self {
        case .light: "Light"
        case .medium: "Medium"
        case .heavy: "Heavy"
        }
    }
}

enum HapticPattern {
    case doubleTap
    case tripleTap
    case pulse
    case heartbeat
}
