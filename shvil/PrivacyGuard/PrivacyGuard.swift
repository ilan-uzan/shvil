//
//  PrivacyGuard.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import Foundation

/// Privacy management and user consent handling
class PrivacyGuard: ObservableObject {
    // MARK: - Published Properties

    @Published var hasAcceptedPrivacyPolicy = false
    @Published var hasAcceptedLocationSharing = false
    @Published var hasAcceptedFriendsOnMap = false
    @Published var hasAcceptedETASharing = false
    @Published var hasAcceptedAnalytics = false
    @Published var isPanicSwitchEnabled = false

    // MARK: - Private Properties

    private let persistence: Persistence
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(persistence: Persistence = Persistence()) {
        self.persistence = persistence
        loadPrivacySettings()
    }

    // MARK: - Public Methods

    func showPrivacySheet(for feature: PrivacyFeature) -> PrivacySheetData {
        PrivacySheetData(
            feature: feature,
            title: titleForFeature(feature),
            description: descriptionForFeature(feature),
            dataCollected: dataCollectedForFeature(feature),
            howToStop: howToStopForFeature(feature)
        )
    }

    func acceptPrivacyPolicy() {
        hasAcceptedPrivacyPolicy = true
        savePrivacySettings()
    }

    func acceptLocationSharing() {
        hasAcceptedLocationSharing = true
        savePrivacySettings()
    }

    func acceptFriendsOnMap() {
        hasAcceptedFriendsOnMap = true
        savePrivacySettings()
    }

    func acceptETASharing() {
        hasAcceptedETASharing = true
        savePrivacySettings()
    }

    func acceptAnalytics() {
        hasAcceptedAnalytics = true
        savePrivacySettings()
    }

    func enablePanicSwitch() {
        isPanicSwitchEnabled = true
        // Immediately stop all sharing
        stopAllSharing()
        savePrivacySettings()
    }

    func disablePanicSwitch() {
        isPanicSwitchEnabled = false
        savePrivacySettings()
    }

    func revokeConsent(for feature: PrivacyFeature) {
        switch feature {
        case .locationSharing:
            hasAcceptedLocationSharing = false
        case .friendsOnMap:
            hasAcceptedFriendsOnMap = false
        case .etaSharing:
            hasAcceptedETASharing = false
        case .analytics:
            hasAcceptedAnalytics = false
        }

        savePrivacySettings()
    }

    func canUseFeature(_ feature: PrivacyFeature) -> Bool {
        if isPanicSwitchEnabled {
            return false
        }

        switch feature {
        case .locationSharing:
            return hasAcceptedLocationSharing
        case .friendsOnMap:
            return hasAcceptedFriendsOnMap && hasAcceptedLocationSharing
        case .etaSharing:
            return hasAcceptedETASharing
        case .analytics:
            return hasAcceptedAnalytics
        }
    }

    func getPrivacySummary() -> PrivacySummary {
        PrivacySummary(
            locationSharing: hasAcceptedLocationSharing,
            friendsOnMap: hasAcceptedFriendsOnMap,
            etaSharing: hasAcceptedETASharing,
            analytics: hasAcceptedAnalytics,
            panicSwitch: isPanicSwitchEnabled
        )
    }

    // MARK: - Private Methods

    private func loadPrivacySettings() {
        Task {
            let settings = await persistence.loadPrivacySettings()

            await MainActor.run {
                hasAcceptedPrivacyPolicy = settings.privacyPolicy
                hasAcceptedLocationSharing = settings.locationSharing
                hasAcceptedFriendsOnMap = settings.friendsOnMap
                hasAcceptedETASharing = settings.etaSharing
                hasAcceptedAnalytics = settings.analytics
                isPanicSwitchEnabled = settings.panicSwitch
            }
        }
    }

    private func savePrivacySettings() {
        let settings = PrivacySettings(
            privacyPolicy: hasAcceptedPrivacyPolicy,
            locationSharing: hasAcceptedLocationSharing,
            friendsOnMap: hasAcceptedFriendsOnMap,
            etaSharing: hasAcceptedETASharing,
            analytics: hasAcceptedAnalytics,
            panicSwitch: isPanicSwitchEnabled
        )

        Task {
            await persistence.savePrivacySettings(settings)
        }
    }

    private func stopAllSharing() {
        // Implementation to stop all data sharing
        // This would typically involve:
        // - Stopping location updates
        // - Ending all ETA sessions
        // - Disabling friends on map
        // - Clearing cached data
    }

    private func titleForFeature(_ feature: PrivacyFeature) -> String {
        switch feature {
        case .locationSharing:
            "Location Sharing"
        case .friendsOnMap:
            "Friends on Map"
        case .etaSharing:
            "ETA Sharing"
        case .analytics:
            "Analytics"
        }
    }

    private func descriptionForFeature(_ feature: PrivacyFeature) -> String {
        switch feature {
        case .locationSharing:
            "We use your location to provide navigation services and show your position on the map. Your location is processed locally on your device and only shared when you explicitly choose to share your ETA or enable friends on map."
        case .friendsOnMap:
            "This feature allows you to see your friends' locations on the map and share your location with them. Both you and your friends must opt-in to this feature. You can disable this at any time."
        case .etaSharing:
            "When you share your ETA, we send your current location and estimated arrival time to the people you choose. This information is only shared for the duration of your trip and is automatically deleted after 1 hour."
        case .analytics:
            "We collect anonymous usage data to improve the app. This includes app crashes, feature usage, and performance metrics. No personal information or precise location data is collected."
        }
    }

    private func dataCollectedForFeature(_ feature: PrivacyFeature) -> [String] {
        switch feature {
        case .locationSharing:
            [
                "Your current location (latitude and longitude)",
                "Location accuracy and timestamp",
                "Location is processed locally on your device",
            ]
        case .friendsOnMap:
            [
                "Your current location (when feature is enabled)",
                "Your friends' locations (when they opt-in)",
                "Location data is encrypted and shared only with selected friends",
            ]
        case .etaSharing:
            [
                "Your current location",
                "Your destination",
                "Estimated arrival time",
                "Route information (start and end points only)",
            ]
        case .analytics:
            [
                "App usage statistics (anonymous)",
                "Feature usage patterns (anonymous)",
                "App performance metrics",
                "Crash reports (no personal data)",
            ]
        }
    }

    private func howToStopForFeature(_ feature: PrivacyFeature) -> String {
        switch feature {
        case .locationSharing:
            "Go to Settings > Privacy > Location Services and disable location access for Shvil, or disable the panic switch to stop all sharing immediately."
        case .friendsOnMap:
            "Go to Settings > Privacy > Friends on Map and disable this feature, or use the panic switch to stop all sharing immediately."
        case .etaSharing:
            "Stop any active ETA sharing sessions in the app, or use the panic switch to immediately end all sharing."
        case .analytics:
            "Go to Settings > Privacy > Analytics and disable this feature, or use the panic switch to stop all data collection."
        }
    }
}

// MARK: - Supporting Types

enum PrivacyFeature: String, CaseIterable {
    case locationSharing = "location_sharing"
    case friendsOnMap = "friends_on_map"
    case etaSharing = "eta_sharing"
    case analytics
}

struct PrivacySheetData {
    let feature: PrivacyFeature
    let title: String
    let description: String
    let dataCollected: [String]
    let howToStop: String
}

struct PrivacySummary {
    let locationSharing: Bool
    let friendsOnMap: Bool
    let etaSharing: Bool
    let analytics: Bool
    let panicSwitch: Bool
}

struct PrivacySettings: Codable {
    let privacyPolicy: Bool
    let locationSharing: Bool
    let friendsOnMap: Bool
    let etaSharing: Bool
    let analytics: Bool
    let panicSwitch: Bool
}

// MARK: - Persistence Extensions

extension Persistence {
    func savePrivacySettings(_: PrivacySettings) async {
        // Implementation for saving privacy settings
        // This would typically use UserDefaults or a simple file
    }

    func loadPrivacySettings() async -> PrivacySettings {
        // Implementation for loading privacy settings
        // This would typically use UserDefaults or a simple file
        PrivacySettings(
            privacyPolicy: false,
            locationSharing: false,
            friendsOnMap: false,
            etaSharing: false,
            analytics: false,
            panicSwitch: false
        )
    }
}
