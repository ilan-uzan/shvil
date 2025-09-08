//
//  DependencyContainer.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation

/// Dependency injection container for the app
@MainActor
class DependencyContainer {
    static let shared = DependencyContainer()

    private init() {}

    // MARK: - Core Services

    lazy var appState: AppState = .init()
    lazy var mapEngine: MapEngine = .init()
    lazy var routingEngine: RoutingEngine = .init()
    lazy var contextEngine: ContextEngine = .init()
    lazy var socialKit: SocialKit = .init()
    lazy var safetyKit: SafetyKit = .init()
    lazy var persistence: Persistence = .init()
    lazy var privacyGuard: PrivacyGuard = .init()
    
    // MARK: - Authentication & Settings
    
    lazy var authenticationService: AuthenticationService = .init()
    lazy var settingsService: SettingsService = .init()

    // MARK: - Feature Services

    lazy var locationManager: LocationManager = .init()
    lazy var searchService: SearchService = .init()
    lazy var navigationService: AsyncNavigationService = .init()
    lazy var offlineManager: OfflineManager = .init()
    lazy var routingService: AsyncRoutingService = .init(
        locationService: locationManager,
        offlineManager: offlineManager
    )
    lazy var aiKit: AIKit = {
        do {
            return try AIKit()
        } catch {
            // Fallback to direct initialization with placeholder key
            // This will show proper error messages when the key is invalid
            return AIKit(apiKey: Configuration.openAIAPIKey)
        }
    }()

    lazy var adventureKit: AdventureKit = .init(
        aiKit: aiKit,
        mapEngine: mapEngine,
        safetyKit: safetyKit,
        persistence: persistence
    )
    lazy var supabaseService: SupabaseService = .shared
    lazy var socialService: SocialService = .init()
    lazy var huntService: HuntService = .init()

    // MARK: - Utility Services

    lazy var networkMonitor: NetworkMonitor = .shared
    lazy var analytics: Analytics = .shared
    lazy var hapticFeedback: HapticFeedback = .shared
    lazy var performanceMonitor: PerformanceMonitor = .shared
    lazy var contractTestingService: ContractTestingService = .shared
    lazy var mockAPIService: MockAPIService = .shared

    // MARK: - Reset for Testing

    func reset() {
        // Reset all services for testing
        appState = AppState()
        locationManager = LocationManager()
        mapEngine = MapEngine()
        routingEngine = RoutingEngine()
        contextEngine = ContextEngine()
        socialKit = SocialKit()
        safetyKit = SafetyKit()
        persistence = Persistence()
        privacyGuard = PrivacyGuard()
        networkMonitor = NetworkMonitor.shared
        analytics = Analytics.shared
        hapticFeedback = HapticFeedback.shared
    }
}
