//
//  SettingsService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

/// Centralized settings service with persistence
@MainActor
class SettingsService: ObservableObject {
    // MARK: - Published Properties
    
    // Profile Settings
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var avatarURL: String?
    
    // Language & Localization
    @Published var selectedLanguage: AppLanguage = .english
    @Published var isRTLEnabled: Bool = false
    
    // Theme & Appearance
    @Published var selectedTheme: AppTheme = .light
    @Published var enableHapticFeedback: Bool = true
    @Published var enableAnimations: Bool = true
    
    // Navigation Preferences
    @Published var avoidTolls: Bool = false
    @Published var avoidHighways: Bool = false
    @Published var preferScenicRoutes: Bool = false
    @Published var defaultTransportMode: TransportationMode = .driving
    
    // Privacy & Data
    @Published var enableLocationSharing: Bool = false
    @Published var enableAnalytics: Bool = true
    @Published var enableCrashReporting: Bool = true
    @Published var dataRetentionDays: Int = 30
    
    // Notifications
    @Published var enablePushNotifications: Bool = true
    @Published var enableNavigationAlerts: Bool = true
    @Published var enableSafetyAlerts: Bool = true
    @Published var enableSocialUpdates: Bool = false
    
    // Feature Flags
    @Published var enableFriendsOnMap: Bool = false
    @Published var enableSmartStops: Bool = true
    @Published var enableVoiceSearch: Bool = false
    @Published var enableOfflineMode: Bool = true
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private enum Keys {
        // Profile
        static let displayName = "settings_display_name"
        static let email = "settings_email"
        static let avatarURL = "settings_avatar_url"
        
        // Language
        static let selectedLanguage = "settings_language"
        static let isRTLEnabled = "settings_rtl_enabled"
        
        // Theme
        static let selectedTheme = "settings_theme"
        static let enableHapticFeedback = "settings_haptic_feedback"
        static let enableAnimations = "settings_animations"
        
        // Navigation
        static let avoidTolls = "settings_avoid_tolls"
        static let avoidHighways = "settings_avoid_highways"
        static let preferScenicRoutes = "settings_scenic_routes"
        static let defaultTransportMode = "settings_transport_mode"
        
        // Privacy
        static let enableLocationSharing = "settings_location_sharing"
        static let enableAnalytics = "settings_analytics"
        static let enableCrashReporting = "settings_crash_reporting"
        static let dataRetentionDays = "settings_data_retention"
        
        // Notifications
        static let enablePushNotifications = "settings_push_notifications"
        static let enableNavigationAlerts = "settings_navigation_alerts"
        static let enableSafetyAlerts = "settings_safety_alerts"
        static let enableSocialUpdates = "settings_social_updates"
        
        // Features
        static let enableFriendsOnMap = "settings_friends_on_map"
        static let enableSmartStops = "settings_smart_stops"
        static let enableVoiceSearch = "settings_voice_search"
        static let enableOfflineMode = "settings_offline_mode"
    }
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        displayName = ""
        email = ""
        avatarURL = nil
        selectedLanguage = .english
        isRTLEnabled = false
        selectedTheme = .light
        enableHapticFeedback = true
        enableAnimations = true
        avoidTolls = false
        avoidHighways = false
        preferScenicRoutes = false
        defaultTransportMode = .driving
        enableLocationSharing = false
        enableAnalytics = true
        enableCrashReporting = true
        dataRetentionDays = 30
        enablePushNotifications = true
        enableNavigationAlerts = true
        enableSafetyAlerts = true
        enableSocialUpdates = false
        enableFriendsOnMap = false
        enableSmartStops = true
        enableVoiceSearch = false
        enableOfflineMode = true
        
        saveSettings()
    }
    
    /// Export settings as dictionary
    func exportSettings() -> [String: Any] {
        return [
            Keys.displayName: displayName,
            Keys.email: email,
            Keys.avatarURL: avatarURL ?? "",
            Keys.selectedLanguage: selectedLanguage.rawValue,
            Keys.isRTLEnabled: isRTLEnabled,
            Keys.selectedTheme: selectedTheme.rawValue,
            Keys.enableHapticFeedback: enableHapticFeedback,
            Keys.enableAnimations: enableAnimations,
            Keys.avoidTolls: avoidTolls,
            Keys.avoidHighways: avoidHighways,
            Keys.preferScenicRoutes: preferScenicRoutes,
            Keys.defaultTransportMode: defaultTransportMode.rawValue,
            Keys.enableLocationSharing: enableLocationSharing,
            Keys.enableAnalytics: enableAnalytics,
            Keys.enableCrashReporting: enableCrashReporting,
            Keys.dataRetentionDays: dataRetentionDays,
            Keys.enablePushNotifications: enablePushNotifications,
            Keys.enableNavigationAlerts: enableNavigationAlerts,
            Keys.enableSafetyAlerts: enableSafetyAlerts,
            Keys.enableSocialUpdates: enableSocialUpdates,
            Keys.enableFriendsOnMap: enableFriendsOnMap,
            Keys.enableSmartStops: enableSmartStops,
            Keys.enableVoiceSearch: enableVoiceSearch,
            Keys.enableOfflineMode: enableOfflineMode
        ]
    }
    
    /// Import settings from dictionary
    func importSettings(_ settings: [String: Any]) {
        if let value = settings[Keys.displayName] as? String { displayName = value }
        if let value = settings[Keys.email] as? String { email = value }
        if let value = settings[Keys.avatarURL] as? String { avatarURL = value.isEmpty ? nil : value }
        if let value = settings[Keys.selectedLanguage] as? String,
           let language = AppLanguage(rawValue: value) { selectedLanguage = language }
        if let value = settings[Keys.isRTLEnabled] as? Bool { isRTLEnabled = value }
        if let value = settings[Keys.selectedTheme] as? String,
           let theme = AppTheme(rawValue: value) { selectedTheme = theme }
        if let value = settings[Keys.enableHapticFeedback] as? Bool { enableHapticFeedback = value }
        if let value = settings[Keys.enableAnimations] as? Bool { enableAnimations = value }
        if let value = settings[Keys.avoidTolls] as? Bool { avoidTolls = value }
        if let value = settings[Keys.avoidHighways] as? Bool { avoidHighways = value }
        if let value = settings[Keys.preferScenicRoutes] as? Bool { preferScenicRoutes = value }
        if let value = settings[Keys.defaultTransportMode] as? String,
           let mode = TransportationMode(rawValue: value) { defaultTransportMode = mode }
        if let value = settings[Keys.enableLocationSharing] as? Bool { enableLocationSharing = value }
        if let value = settings[Keys.enableAnalytics] as? Bool { enableAnalytics = value }
        if let value = settings[Keys.enableCrashReporting] as? Bool { enableCrashReporting = value }
        if let value = settings[Keys.dataRetentionDays] as? Int { dataRetentionDays = value }
        if let value = settings[Keys.enablePushNotifications] as? Bool { enablePushNotifications = value }
        if let value = settings[Keys.enableNavigationAlerts] as? Bool { enableNavigationAlerts = value }
        if let value = settings[Keys.enableSafetyAlerts] as? Bool { enableSafetyAlerts = value }
        if let value = settings[Keys.enableSocialUpdates] as? Bool { enableSocialUpdates = value }
        if let value = settings[Keys.enableFriendsOnMap] as? Bool { enableFriendsOnMap = value }
        if let value = settings[Keys.enableSmartStops] as? Bool { enableSmartStops = value }
        if let value = settings[Keys.enableVoiceSearch] as? Bool { enableVoiceSearch = value }
        if let value = settings[Keys.enableOfflineMode] as? Bool { enableOfflineMode = value }
        
        saveSettings()
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        displayName = userDefaults.string(forKey: Keys.displayName) ?? ""
        email = userDefaults.string(forKey: Keys.email) ?? ""
        avatarURL = userDefaults.string(forKey: Keys.avatarURL)
        
        if let languageRaw = userDefaults.string(forKey: Keys.selectedLanguage),
           let language = AppLanguage(rawValue: languageRaw) {
            selectedLanguage = language
        }
        isRTLEnabled = userDefaults.bool(forKey: Keys.isRTLEnabled)
        
        if let themeRaw = userDefaults.string(forKey: Keys.selectedTheme),
           let theme = AppTheme(rawValue: themeRaw) {
            selectedTheme = theme
        }
        enableHapticFeedback = userDefaults.bool(forKey: Keys.enableHapticFeedback)
        enableAnimations = userDefaults.bool(forKey: Keys.enableAnimations)
        
        avoidTolls = userDefaults.bool(forKey: Keys.avoidTolls)
        avoidHighways = userDefaults.bool(forKey: Keys.avoidHighways)
        preferScenicRoutes = userDefaults.bool(forKey: Keys.preferScenicRoutes)
        
        if let modeRaw = userDefaults.string(forKey: Keys.defaultTransportMode),
           let mode = TransportationMode(rawValue: modeRaw) {
            defaultTransportMode = mode
        }
        
        enableLocationSharing = userDefaults.bool(forKey: Keys.enableLocationSharing)
        enableAnalytics = userDefaults.bool(forKey: Keys.enableAnalytics)
        enableCrashReporting = userDefaults.bool(forKey: Keys.enableCrashReporting)
        dataRetentionDays = userDefaults.integer(forKey: Keys.dataRetentionDays)
        
        enablePushNotifications = userDefaults.bool(forKey: Keys.enablePushNotifications)
        enableNavigationAlerts = userDefaults.bool(forKey: Keys.enableNavigationAlerts)
        enableSafetyAlerts = userDefaults.bool(forKey: Keys.enableSafetyAlerts)
        enableSocialUpdates = userDefaults.bool(forKey: Keys.enableSocialUpdates)
        
        enableFriendsOnMap = userDefaults.bool(forKey: Keys.enableFriendsOnMap)
        enableSmartStops = userDefaults.bool(forKey: Keys.enableSmartStops)
        enableVoiceSearch = userDefaults.bool(forKey: Keys.enableVoiceSearch)
        enableOfflineMode = userDefaults.bool(forKey: Keys.enableOfflineMode)
    }
    
    private func saveSettings() {
        userDefaults.set(displayName, forKey: Keys.displayName)
        userDefaults.set(email, forKey: Keys.email)
        userDefaults.set(avatarURL, forKey: Keys.avatarURL)
        userDefaults.set(selectedLanguage.rawValue, forKey: Keys.selectedLanguage)
        userDefaults.set(isRTLEnabled, forKey: Keys.isRTLEnabled)
        userDefaults.set(selectedTheme.rawValue, forKey: Keys.selectedTheme)
        userDefaults.set(enableHapticFeedback, forKey: Keys.enableHapticFeedback)
        userDefaults.set(enableAnimations, forKey: Keys.enableAnimations)
        userDefaults.set(avoidTolls, forKey: Keys.avoidTolls)
        userDefaults.set(avoidHighways, forKey: Keys.avoidHighways)
        userDefaults.set(preferScenicRoutes, forKey: Keys.preferScenicRoutes)
        userDefaults.set(defaultTransportMode.rawValue, forKey: Keys.defaultTransportMode)
        userDefaults.set(enableLocationSharing, forKey: Keys.enableLocationSharing)
        userDefaults.set(enableAnalytics, forKey: Keys.enableAnalytics)
        userDefaults.set(enableCrashReporting, forKey: Keys.enableCrashReporting)
        userDefaults.set(dataRetentionDays, forKey: Keys.dataRetentionDays)
        userDefaults.set(enablePushNotifications, forKey: Keys.enablePushNotifications)
        userDefaults.set(enableNavigationAlerts, forKey: Keys.enableNavigationAlerts)
        userDefaults.set(enableSafetyAlerts, forKey: Keys.enableSafetyAlerts)
        userDefaults.set(enableSocialUpdates, forKey: Keys.enableSocialUpdates)
        userDefaults.set(enableFriendsOnMap, forKey: Keys.enableFriendsOnMap)
        userDefaults.set(enableSmartStops, forKey: Keys.enableSmartStops)
        userDefaults.set(enableVoiceSearch, forKey: Keys.enableVoiceSearch)
        userDefaults.set(enableOfflineMode, forKey: Keys.enableOfflineMode)
    }
    
    private func setupBindings() {
        // Auto-save when any setting changes - break into smaller chunks to avoid compiler timeout
        let profilePublishers = Publishers.MergeMany(
            $displayName.map { _ in () }.eraseToAnyPublisher(),
            $email.map { _ in () }.eraseToAnyPublisher(),
            $selectedLanguage.map { _ in () }.eraseToAnyPublisher(),
            $isRTLEnabled.map { _ in () }.eraseToAnyPublisher(),
            $selectedTheme.map { _ in () }.eraseToAnyPublisher()
        )
        
        let interactionPublishers = Publishers.MergeMany(
            $enableHapticFeedback.map { _ in () }.eraseToAnyPublisher(),
            $enableAnimations.map { _ in () }.eraseToAnyPublisher(),
            $avoidTolls.map { _ in () }.eraseToAnyPublisher(),
            $avoidHighways.map { _ in () }.eraseToAnyPublisher(),
            $preferScenicRoutes.map { _ in () }.eraseToAnyPublisher(),
            $defaultTransportMode.map { _ in () }.eraseToAnyPublisher()
        )
        
        let privacyPublishers = Publishers.MergeMany(
            $enableLocationSharing.map { _ in () }.eraseToAnyPublisher(),
            $enableAnalytics.map { _ in () }.eraseToAnyPublisher(),
            $enableCrashReporting.map { _ in () }.eraseToAnyPublisher(),
            $dataRetentionDays.map { _ in () }.eraseToAnyPublisher()
        )
        
        let notificationPublishers = Publishers.MergeMany(
            $enablePushNotifications.map { _ in () }.eraseToAnyPublisher(),
            $enableNavigationAlerts.map { _ in () }.eraseToAnyPublisher(),
            $enableSafetyAlerts.map { _ in () }.eraseToAnyPublisher(),
            $enableSocialUpdates.map { _ in () }.eraseToAnyPublisher(),
            $enableFriendsOnMap.map { _ in () }.eraseToAnyPublisher(),
            $enableSmartStops.map { _ in () }.eraseToAnyPublisher(),
            $enableVoiceSearch.map { _ in () }.eraseToAnyPublisher(),
            $enableOfflineMode.map { _ in () }.eraseToAnyPublisher()
        )
        
        Publishers.MergeMany(
            profilePublishers,
            interactionPublishers,
            privacyPublishers,
            notificationPublishers
        )
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
    }
}

// MARK: - Supporting Types

enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    case hebrew = "he"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .hebrew: return "עברית"
        }
    }
    
    var isRTL: Bool {
        switch self {
        case .english: return false
        case .hebrew: return true
        }
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

