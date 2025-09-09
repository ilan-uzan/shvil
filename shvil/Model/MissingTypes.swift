//
//  MissingTypes.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI

// MARK: - Map Layer
// Note: MapLayer is defined in MapLayersSelector.swift

// MARK: - Transportation Mode
// Note: TransportationMode is defined in Route.swift

// MARK: - Theme
// Note: Theme is defined in OnboardingView.swift

// MARK: - Notification Settings
// Note: NotificationSettings is defined in MockAPIService.swift

// MARK: - Privacy Settings
// Note: PrivacySettings is defined in PrivacyGuard.swift

// MARK: - User Preferences
// Note: UserPreferences is defined in APIModels.swift

// MARK: - Glass Elevation

public enum GlassElevation: String, CaseIterable, Codable {
    case light = "light"
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// MARK: - Companion Type
// Note: CompanionType is defined in AdventureKit.swift

// MARK: - Time Frame
// Note: TimeFrame is defined in AdventureKit.swift

// MARK: - Budget Level
// Note: BudgetLevel is defined in AdventureKit.swift
