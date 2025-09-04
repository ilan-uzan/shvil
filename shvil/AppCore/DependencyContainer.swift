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
    lazy var appState: AppState = AppState()
    lazy var locationKit: LocationKit = LocationKit()
    lazy var mapEngine: MapEngine = MapEngine()
    lazy var routingEngine: RoutingEngine = RoutingEngine()
    lazy var contextEngine: ContextEngine = ContextEngine()
    lazy var socialKit: SocialKit = SocialKit()
    lazy var safetyKit: SafetyKit = SafetyKit()
    lazy var persistence: Persistence = Persistence()
    lazy var privacyGuard: PrivacyGuard = PrivacyGuard()
    
    // MARK: - Feature Services
    lazy var locationService: LocationService = LocationService()
    lazy var searchService: SearchService = SearchService()
    lazy var navigationService: NavigationService = NavigationService()
    lazy var aiKit: AIKit = AIKit(apiKey: Configuration.openAIAPIKey)
    lazy var adventureKit: AdventureKit = AdventureKit(
        aiKit: aiKit,
        mapEngine: mapEngine,
        safetyKit: safetyKit,
        persistence: persistence
    )
    lazy var supabaseService: SupabaseService = SupabaseService.shared
    
    // MARK: - Utility Services
    lazy var networkMonitor: NetworkMonitor = NetworkMonitor.shared
    lazy var analytics: Analytics = Analytics.shared
    lazy var hapticFeedback: HapticFeedback = HapticFeedback.shared
    
    // MARK: - Reset for Testing
    func reset() {
        // Reset all services for testing
        appState = AppState()
        locationKit = LocationKit()
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
