//
//  AppState.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import Foundation

/// Main app state and dependency container
@MainActor
class AppState: ObservableObject {
    // MARK: - Core Services

    let locationKit = LocationKit()
    let mapEngine = MapEngine()
    let routingEngine = RoutingEngine()
    let contextEngine = ContextEngine()
    let socialKit = SocialKit()
    let safetyKit = SafetyKit()
    let persistence = Persistence()
    let privacyGuard = PrivacyGuard()

    // MARK: - App State

    @Published var currentScreen: AppScreen = .home
    @Published var isNavigationActive = false
    @Published var isSearchFocused = false
    @Published var isBottomSheetExpanded = false
    @Published var isOfflineMode = false

    // MARK: - Feature Flags

    @Published var enableFriendsOnMap = false
    @Published var enableSafetyLayer = false
    @Published var enableSmartStops = true
    @Published var enableVoiceSearch = false

    // MARK: - Permissions

    @Published var locationPermission: LocationPermission = .notDetermined
    @Published var microphonePermission: MicrophonePermission = .notDetermined
    @Published var notificationPermission: NotificationPermission = .notDetermined

    init() {
        setupObservers()
    }

    private func setupObservers() {
        // Monitor network connectivity
        NotificationCenter.default.publisher(for: NSNotification.Name("ReachabilityChanged"))
            .sink { [weak self] _ in
                self?.updateOfflineMode()
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    private func updateOfflineMode() {
        // Implementation for offline mode detection
        isOfflineMode = !NetworkMonitor.shared.isConnected
    }
}

// MARK: - App Screens

enum AppScreen: String, CaseIterable {
    case home
    case navigation
    case search
    case savedPlaces = "saved_places"
    case social
    case profile
}

// MARK: - Permission Types

enum LocationPermission {
    case notDetermined
    case denied
    case whenInUse
    case always
}

enum MicrophonePermission {
    case notDetermined
    case denied
    case granted
}

enum NotificationPermission {
    case notDetermined
    case denied
    case granted
}
