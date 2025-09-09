//
//  MissingTypes.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI

// MARK: - Map Layer

public enum MapLayer: String, CaseIterable, Codable {
    case standard = "standard"
    case satellite = "satellite"
    case hybrid = "hybrid"
    case terrain = "terrain"
    
    public var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .satellite: return "Satellite"
        case .hybrid: return "Hybrid"
        case .terrain: return "Terrain"
        }
    }
    
    public var icon: String {
        switch self {
        case .standard: return "map"
        case .satellite: return "globe"
        case .hybrid: return "map.fill"
        case .terrain: return "mountain.2.fill"
        }
    }
}

// MARK: - Transportation Mode

public enum TransportationMode: String, CaseIterable, Codable {
    case walking = "walking"
    case cycling = "cycling"
    case driving = "driving"
    case publicTransport = "public_transport"
    case mixed = "mixed"
    
    public var displayName: String {
        switch self {
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .driving: return "Driving"
        case .publicTransport: return "Public Transport"
        case .mixed: return "Mixed"
        }
    }
    
    public var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .driving: return "car"
        case .publicTransport: return "bus"
        case .mixed: return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - Theme

public enum Theme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Notification Settings

public struct NotificationSettings: Codable {
    public let pushNotifications: Bool
    public let emailNotifications: Bool
    public let adventureReminders: Bool
    public let safetyAlerts: Bool
    public let socialUpdates: Bool
    public let marketingEmails: Bool
    
    public init(
        pushNotifications: Bool = true,
        emailNotifications: Bool = false,
        adventureReminders: Bool = true,
        safetyAlerts: Bool = true,
        socialUpdates: Bool = true,
        marketingEmails: Bool = false
    ) {
        self.pushNotifications = pushNotifications
        self.emailNotifications = emailNotifications
        self.adventureReminders = adventureReminders
        self.safetyAlerts = safetyAlerts
        self.socialUpdates = socialUpdates
        self.marketingEmails = marketingEmails
    }
}

// MARK: - Privacy Settings

public struct PrivacySettings: Codable {
    public let shareLocation: Bool
    public let shareAdventures: Bool
    public let shareWithFriends: Bool
    public let analyticsTracking: Bool
    public let crashReporting: Bool
    public let personalizedAds: Bool
    
    public init(
        shareLocation: Bool = true,
        shareAdventures: Bool = false,
        shareWithFriends: Bool = true,
        analyticsTracking: Bool = true,
        crashReporting: Bool = true,
        personalizedAds: Bool = false
    ) {
        self.shareLocation = shareLocation
        self.shareAdventures = shareAdventures
        self.shareWithFriends = shareWithFriends
        self.analyticsTracking = analyticsTracking
        self.crashReporting = crashReporting
        self.personalizedAds = personalizedAds
    }
}

// MARK: - User Preferences

public struct UserPreferences: Codable {
    public let language: String
    public let theme: Theme
    public let notifications: NotificationSettings
    public let privacy: PrivacySettings
    
    public init(
        language: String = "en",
        theme: Theme = .system,
        notifications: NotificationSettings = NotificationSettings(),
        privacy: PrivacySettings = PrivacySettings()
    ) {
        self.language = language
        self.theme = theme
        self.notifications = notifications
        self.privacy = privacy
    }
}

// MARK: - Companion Type

public enum CompanionType: String, CaseIterable, Codable {
    case solo = "solo"
    case couple = "couple"
    case friends = "friends"
    case family = "family"
    case group = "group"
    
    public var displayName: String {
        switch self {
        case .solo: return "Solo"
        case .couple: return "Couple"
        case .friends: return "Friends"
        case .family: return "Family"
        case .group: return "Group"
        }
    }
    
    public var icon: String {
        switch self {
        case .solo: return "person"
        case .couple: return "person.2"
        case .friends: return "person.3"
        case .family: return "house"
        case .group: return "person.3.sequence"
        }
    }
}

// MARK: - Time Frame

public enum TimeFrame: String, CaseIterable, Codable {
    case halfDay = "half_day"
    case fullDay = "full_day"
    case weekend = "weekend"
    case week = "week"
    
    public var displayName: String {
        switch self {
        case .halfDay: return "Half Day (4-6 hours)"
        case .fullDay: return "Full Day (8-12 hours)"
        case .weekend: return "Weekend (2-3 days)"
        case .week: return "Week (5-7 days)"
        }
    }
    
    public var duration: TimeInterval {
        switch self {
        case .halfDay: return 4 * 3600 // 4 hours
        case .fullDay: return 8 * 3600 // 8 hours
        case .weekend: return 2 * 24 * 3600 // 2 days
        case .week: return 7 * 24 * 3600 // 7 days
        }
    }
}

// MARK: - Budget Level

public enum BudgetLevel: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case premium = "premium"
    
    public var displayName: String {
        switch self {
        case .low: return "Budget-Friendly"
        case .medium: return "Moderate"
        case .high: return "Expensive"
        case .premium: return "Premium"
        }
    }
    
    public var icon: String {
        switch self {
        case .low: return "dollarsign.circle"
        case .medium: return "dollarsign.circle.fill"
        case .high: return "dollarsign.square"
        case .premium: return "dollarsign.square.fill"
        }
    }
}
