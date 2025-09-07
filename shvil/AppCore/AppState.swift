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

    let locationManager = LocationManager()
    let mapEngine = MapEngine()
    let routingEngine = RoutingEngine()
    let contextEngine = ContextEngine()
    let socialKit = SocialKit()
    let safetyKit = SafetyKit()
    let persistence = Persistence()
    let privacyGuard = PrivacyGuard()
    
    // MARK: - Performance & Accessibility Services
    
    let performanceOptimizer = PerformanceOptimizer.shared
    let accessibilityManager = AccessibilityManager.shared
    let cacheManager = CacheManager.shared

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
        setupPerformanceMonitoring()
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
    
    private func setupPerformanceMonitoring() {
        // Start performance monitoring
        performanceOptimizer.startMonitoring()
        
        // Monitor memory usage and clear caches if needed
        performanceOptimizer.$memoryUsage
            .sink { [weak self] usage in
                if usage > 150 * 1024 * 1024 { // 150MB threshold
                    self?.cacheManager.clearExpiredCaches()
                }
            }
            .store(in: &cancellables)
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
