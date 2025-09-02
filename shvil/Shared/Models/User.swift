//
//  User.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String?
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    let id: UUID
    let userId: UUID
    let displayName: String
    let avatarURL: String?
    let preferences: UserPreferences
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case preferences
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    let theme: AppTheme
    let enableNotifications: Bool
    let enableLocationTracking: Bool
    let enableAnalytics: Bool
    let dataRetentionDays: Int
    
    enum CodingKeys: String, CodingKey {
        case theme
        case enableNotifications = "enable_notifications"
        case enableLocationTracking = "enable_location_tracking"
        case enableAnalytics = "enable_analytics"
        case dataRetentionDays = "data_retention_days"
    }
}

// MARK: - App Theme
enum AppTheme: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}
