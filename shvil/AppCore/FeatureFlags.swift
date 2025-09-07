//
//  FeatureFlags.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI

// MARK: - Feature Flags System
// Centralized feature flag management for gradual rollouts and A/B testing

@MainActor
public class FeatureFlags: ObservableObject {
    public static let shared = FeatureFlags()
    
    // MARK: - Published Feature Flags
    
    // Design System
    @Published public var liquidGlassV2: Bool = true
    @Published public var newMapOverlay: Bool = false
    @Published public var newHuntEngine: Bool = false
    
    // Authentication
    @Published public var appleSignInEnabled: Bool = false
    @Published public var magicLinkEnabled: Bool = true
    @Published public var biometricAuthEnabled: Bool = false
    
    // Social Features
    @Published public var friendsOnMapEnabled: Bool = false
    @Published public var realTimeLocationEnabled: Bool = false
    @Published public var groupTripsEnabled: Bool = false
    
    // Adventure Features
    @Published public var aiAdventureGeneration: Bool = true
    @Published public var scavengerHuntMode: Bool = true
    @Published public var photoProofRequired: Bool = true
    @Published public var antiCheatEnabled: Bool = true
    
    // Performance Features
    @Published public var asyncAwaitMigration: Bool = true
    @Published public var backgroundProcessing: Bool = true
    @Published public var smartCaching: Bool = true
    @Published public var lazyLoading: Bool = true
    
    // Accessibility Features
    @Published public var voiceOverEnhanced: Bool = true
    @Published public var highContrastMode: Bool = true
    @Published public var reducedMotion: Bool = true
    @Published public var dynamicTypeSupport: Bool = true
    
    // Platform Features
    @Published public var liveActivitiesEnabled: Bool = true
    @Published public var dynamicIslandEnabled: Bool = true
    @Published public var hapticFeedbackEnabled: Bool = true
    @Published public var pushNotificationsEnabled: Bool = true
    
    // Development Features
    @Published public var debugMode: Bool = false
    @Published public var performanceMetrics: Bool = false
    @Published public var crashReporting: Bool = true
    @Published public var analyticsEnabled: Bool = true
    
    private init() {
        loadFeatureFlags()
        setupObservers()
    }
    
    // MARK: - Feature Flag Management
    
    private func loadFeatureFlags() {
        // Load from UserDefaults with defaults
        liquidGlassV2 = UserDefaults.standard.object(forKey: "feature_liquid_glass_v2") as? Bool ?? true
        newMapOverlay = UserDefaults.standard.object(forKey: "feature_new_map_overlay") as? Bool ?? false
        newHuntEngine = UserDefaults.standard.object(forKey: "feature_new_hunt_engine") as? Bool ?? false
        
        appleSignInEnabled = UserDefaults.standard.object(forKey: "feature_apple_signin") as? Bool ?? false
        magicLinkEnabled = UserDefaults.standard.object(forKey: "feature_magic_link") as? Bool ?? true
        biometricAuthEnabled = UserDefaults.standard.object(forKey: "feature_biometric_auth") as? Bool ?? false
        
        friendsOnMapEnabled = UserDefaults.standard.object(forKey: "feature_friends_on_map") as? Bool ?? false
        realTimeLocationEnabled = UserDefaults.standard.object(forKey: "feature_realtime_location") as? Bool ?? false
        groupTripsEnabled = UserDefaults.standard.object(forKey: "feature_group_trips") as? Bool ?? false
        
        aiAdventureGeneration = UserDefaults.standard.object(forKey: "feature_ai_adventures") as? Bool ?? true
        scavengerHuntMode = UserDefaults.standard.object(forKey: "feature_scavenger_hunt") as? Bool ?? true
        photoProofRequired = UserDefaults.standard.object(forKey: "feature_photo_proof") as? Bool ?? true
        antiCheatEnabled = UserDefaults.standard.object(forKey: "feature_anti_cheat") as? Bool ?? true
        
        asyncAwaitMigration = UserDefaults.standard.object(forKey: "feature_async_await") as? Bool ?? true
        backgroundProcessing = UserDefaults.standard.object(forKey: "feature_background_processing") as? Bool ?? true
        smartCaching = UserDefaults.standard.object(forKey: "feature_smart_caching") as? Bool ?? true
        lazyLoading = UserDefaults.standard.object(forKey: "feature_lazy_loading") as? Bool ?? true
        
        voiceOverEnhanced = UserDefaults.standard.object(forKey: "feature_voiceover_enhanced") as? Bool ?? true
        highContrastMode = UserDefaults.standard.object(forKey: "feature_high_contrast") as? Bool ?? true
        reducedMotion = UserDefaults.standard.object(forKey: "feature_reduced_motion") as? Bool ?? true
        dynamicTypeSupport = UserDefaults.standard.object(forKey: "feature_dynamic_type") as? Bool ?? true
        
        liveActivitiesEnabled = UserDefaults.standard.object(forKey: "feature_live_activities") as? Bool ?? true
        dynamicIslandEnabled = UserDefaults.standard.object(forKey: "feature_dynamic_island") as? Bool ?? true
        hapticFeedbackEnabled = UserDefaults.standard.object(forKey: "feature_haptic_feedback") as? Bool ?? true
        pushNotificationsEnabled = UserDefaults.standard.object(forKey: "feature_push_notifications") as? Bool ?? true
        
        debugMode = UserDefaults.standard.object(forKey: "feature_debug_mode") as? Bool ?? false
        performanceMetrics = UserDefaults.standard.object(forKey: "feature_performance_metrics") as? Bool ?? false
        crashReporting = UserDefaults.standard.object(forKey: "feature_crash_reporting") as? Bool ?? true
        analyticsEnabled = UserDefaults.standard.object(forKey: "feature_analytics") as? Bool ?? true
    }
    
    private func setupObservers() {
        // Observe changes and persist to UserDefaults
        $liquidGlassV2
            .sink { UserDefaults.standard.set($0, forKey: "feature_liquid_glass_v2") }
            .store(in: &cancellables)
        
        $newMapOverlay
            .sink { UserDefaults.standard.set($0, forKey: "feature_new_map_overlay") }
            .store(in: &cancellables)
        
        $newHuntEngine
            .sink { UserDefaults.standard.set($0, forKey: "feature_new_hunt_engine") }
            .store(in: &cancellables)
        
        $appleSignInEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_apple_signin") }
            .store(in: &cancellables)
        
        $magicLinkEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_magic_link") }
            .store(in: &cancellables)
        
        $biometricAuthEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_biometric_auth") }
            .store(in: &cancellables)
        
        $friendsOnMapEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_friends_on_map") }
            .store(in: &cancellables)
        
        $realTimeLocationEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_realtime_location") }
            .store(in: &cancellables)
        
        $groupTripsEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_group_trips") }
            .store(in: &cancellables)
        
        $aiAdventureGeneration
            .sink { UserDefaults.standard.set($0, forKey: "feature_ai_adventures") }
            .store(in: &cancellables)
        
        $scavengerHuntMode
            .sink { UserDefaults.standard.set($0, forKey: "feature_scavenger_hunt") }
            .store(in: &cancellables)
        
        $photoProofRequired
            .sink { UserDefaults.standard.set($0, forKey: "feature_photo_proof") }
            .store(in: &cancellables)
        
        $antiCheatEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_anti_cheat") }
            .store(in: &cancellables)
        
        $asyncAwaitMigration
            .sink { UserDefaults.standard.set($0, forKey: "feature_async_await") }
            .store(in: &cancellables)
        
        $backgroundProcessing
            .sink { UserDefaults.standard.set($0, forKey: "feature_background_processing") }
            .store(in: &cancellables)
        
        $smartCaching
            .sink { UserDefaults.standard.set($0, forKey: "feature_smart_caching") }
            .store(in: &cancellables)
        
        $lazyLoading
            .sink { UserDefaults.standard.set($0, forKey: "feature_lazy_loading") }
            .store(in: &cancellables)
        
        $voiceOverEnhanced
            .sink { UserDefaults.standard.set($0, forKey: "feature_voiceover_enhanced") }
            .store(in: &cancellables)
        
        $highContrastMode
            .sink { UserDefaults.standard.set($0, forKey: "feature_high_contrast") }
            .store(in: &cancellables)
        
        $reducedMotion
            .sink { UserDefaults.standard.set($0, forKey: "feature_reduced_motion") }
            .store(in: &cancellables)
        
        $dynamicTypeSupport
            .sink { UserDefaults.standard.set($0, forKey: "feature_dynamic_type") }
            .store(in: &cancellables)
        
        $liveActivitiesEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_live_activities") }
            .store(in: &cancellables)
        
        $dynamicIslandEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_dynamic_island") }
            .store(in: &cancellables)
        
        $hapticFeedbackEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_haptic_feedback") }
            .store(in: &cancellables)
        
        $pushNotificationsEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_push_notifications") }
            .store(in: &cancellables)
        
        $debugMode
            .sink { UserDefaults.standard.set($0, forKey: "feature_debug_mode") }
            .store(in: &cancellables)
        
        $performanceMetrics
            .sink { UserDefaults.standard.set($0, forKey: "feature_performance_metrics") }
            .store(in: &cancellables)
        
        $crashReporting
            .sink { UserDefaults.standard.set($0, forKey: "feature_crash_reporting") }
            .store(in: &cancellables)
        
        $analyticsEnabled
            .sink { UserDefaults.standard.set($0, forKey: "feature_analytics") }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Feature Flag Methods
    
    /// Check if a feature is enabled
    public func isEnabled(_ feature: Feature) -> Bool {
        switch feature {
        case .liquidGlassV2: return liquidGlassV2
        case .newMapOverlay: return newMapOverlay
        case .newHuntEngine: return newHuntEngine
        case .appleSignIn: return appleSignInEnabled
        case .magicLink: return magicLinkEnabled
        case .biometricAuth: return biometricAuthEnabled
        case .friendsOnMap: return friendsOnMapEnabled
        case .realTimeLocation: return realTimeLocationEnabled
        case .groupTrips: return groupTripsEnabled
        case .aiAdventureGeneration: return aiAdventureGeneration
        case .scavengerHuntMode: return scavengerHuntMode
        case .photoProofRequired: return photoProofRequired
        case .antiCheatEnabled: return antiCheatEnabled
        case .asyncAwaitMigration: return asyncAwaitMigration
        case .backgroundProcessing: return backgroundProcessing
        case .smartCaching: return smartCaching
        case .lazyLoading: return lazyLoading
        case .voiceOverEnhanced: return voiceOverEnhanced
        case .highContrastMode: return highContrastMode
        case .reducedMotion: return reducedMotion
        case .dynamicTypeSupport: return dynamicTypeSupport
        case .liveActivities: return liveActivitiesEnabled
        case .dynamicIsland: return dynamicIslandEnabled
        case .hapticFeedback: return hapticFeedbackEnabled
        case .pushNotifications: return pushNotificationsEnabled
        case .debugMode: return debugMode
        case .performanceMetrics: return performanceMetrics
        case .crashReporting: return crashReporting
        case .analytics: return analyticsEnabled
        }
    }
    
    /// Enable a feature
    public func enable(_ feature: Feature) {
        switch feature {
        case .liquidGlassV2: liquidGlassV2 = true
        case .newMapOverlay: newMapOverlay = true
        case .newHuntEngine: newHuntEngine = true
        case .appleSignIn: appleSignInEnabled = true
        case .magicLink: magicLinkEnabled = true
        case .biometricAuth: biometricAuthEnabled = true
        case .friendsOnMap: friendsOnMapEnabled = true
        case .realTimeLocation: realTimeLocationEnabled = true
        case .groupTrips: groupTripsEnabled = true
        case .aiAdventureGeneration: aiAdventureGeneration = true
        case .scavengerHuntMode: scavengerHuntMode = true
        case .photoProofRequired: photoProofRequired = true
        case .antiCheatEnabled: antiCheatEnabled = true
        case .asyncAwaitMigration: asyncAwaitMigration = true
        case .backgroundProcessing: backgroundProcessing = true
        case .smartCaching: smartCaching = true
        case .lazyLoading: lazyLoading = true
        case .voiceOverEnhanced: voiceOverEnhanced = true
        case .highContrastMode: highContrastMode = true
        case .reducedMotion: reducedMotion = true
        case .dynamicTypeSupport: dynamicTypeSupport = true
        case .liveActivities: liveActivitiesEnabled = true
        case .dynamicIsland: dynamicIslandEnabled = true
        case .hapticFeedback: hapticFeedbackEnabled = true
        case .pushNotifications: pushNotificationsEnabled = true
        case .debugMode: debugMode = true
        case .performanceMetrics: performanceMetrics = true
        case .crashReporting: crashReporting = true
        case .analytics: analyticsEnabled = true
        }
    }
    
    /// Disable a feature
    public func disable(_ feature: Feature) {
        switch feature {
        case .liquidGlassV2: liquidGlassV2 = false
        case .newMapOverlay: newMapOverlay = false
        case .newHuntEngine: newHuntEngine = false
        case .appleSignIn: appleSignInEnabled = false
        case .magicLink: magicLinkEnabled = false
        case .biometricAuth: biometricAuthEnabled = false
        case .friendsOnMap: friendsOnMapEnabled = false
        case .realTimeLocation: realTimeLocationEnabled = false
        case .groupTrips: groupTripsEnabled = false
        case .aiAdventureGeneration: aiAdventureGeneration = false
        case .scavengerHuntMode: scavengerHuntMode = false
        case .photoProofRequired: photoProofRequired = false
        case .antiCheatEnabled: antiCheatEnabled = false
        case .asyncAwaitMigration: asyncAwaitMigration = false
        case .backgroundProcessing: backgroundProcessing = false
        case .smartCaching: smartCaching = false
        case .lazyLoading: lazyLoading = false
        case .voiceOverEnhanced: voiceOverEnhanced = false
        case .highContrastMode: highContrastMode = false
        case .reducedMotion: reducedMotion = false
        case .dynamicTypeSupport: dynamicTypeSupport = false
        case .liveActivities: liveActivitiesEnabled = false
        case .dynamicIsland: dynamicIslandEnabled = false
        case .hapticFeedback: hapticFeedbackEnabled = false
        case .pushNotifications: pushNotificationsEnabled = false
        case .debugMode: debugMode = false
        case .performanceMetrics: performanceMetrics = false
        case .crashReporting: crashReporting = false
        case .analytics: analyticsEnabled = false
        }
    }
    
    /// Reset all feature flags to defaults
    public func resetToDefaults() {
        liquidGlassV2 = true
        newMapOverlay = false
        newHuntEngine = false
        appleSignInEnabled = false
        magicLinkEnabled = true
        biometricAuthEnabled = false
        friendsOnMapEnabled = false
        realTimeLocationEnabled = false
        groupTripsEnabled = false
        aiAdventureGeneration = true
        scavengerHuntMode = true
        photoProofRequired = true
        antiCheatEnabled = true
        asyncAwaitMigration = true
        backgroundProcessing = true
        smartCaching = true
        lazyLoading = true
        voiceOverEnhanced = true
        highContrastMode = true
        reducedMotion = true
        dynamicTypeSupport = true
        liveActivitiesEnabled = true
        dynamicIslandEnabled = true
        hapticFeedbackEnabled = true
        pushNotificationsEnabled = true
        debugMode = false
        performanceMetrics = false
        crashReporting = true
        analyticsEnabled = true
    }
}

// MARK: - Feature Enum

public enum Feature: String, CaseIterable {
    case liquidGlassV2 = "liquid_glass_v2"
    case newMapOverlay = "new_map_overlay"
    case newHuntEngine = "new_hunt_engine"
    case appleSignIn = "apple_signin"
    case magicLink = "magic_link"
    case biometricAuth = "biometric_auth"
    case friendsOnMap = "friends_on_map"
    case realTimeLocation = "realtime_location"
    case groupTrips = "group_trips"
    case aiAdventureGeneration = "ai_adventure_generation"
    case scavengerHuntMode = "scavenger_hunt_mode"
    case photoProofRequired = "photo_proof_required"
    case antiCheatEnabled = "anti_cheat_enabled"
    case asyncAwaitMigration = "async_await_migration"
    case backgroundProcessing = "background_processing"
    case smartCaching = "smart_caching"
    case lazyLoading = "lazy_loading"
    case voiceOverEnhanced = "voiceover_enhanced"
    case highContrastMode = "high_contrast_mode"
    case reducedMotion = "reduced_motion"
    case dynamicTypeSupport = "dynamic_type_support"
    case liveActivities = "live_activities"
    case dynamicIsland = "dynamic_island"
    case hapticFeedback = "haptic_feedback"
    case pushNotifications = "push_notifications"
    case debugMode = "debug_mode"
    case performanceMetrics = "performance_metrics"
    case crashReporting = "crash_reporting"
    case analytics = "analytics"
    
    public var displayName: String {
        switch self {
        case .liquidGlassV2: return "Liquid Glass V2"
        case .newMapOverlay: return "New Map Overlay"
        case .newHuntEngine: return "New Hunt Engine"
        case .appleSignIn: return "Apple Sign In"
        case .magicLink: return "Magic Link"
        case .biometricAuth: return "Biometric Auth"
        case .friendsOnMap: return "Friends on Map"
        case .realTimeLocation: return "Real-time Location"
        case .groupTrips: return "Group Trips"
        case .aiAdventureGeneration: return "AI Adventure Generation"
        case .scavengerHuntMode: return "Scavenger Hunt Mode"
        case .photoProofRequired: return "Photo Proof Required"
        case .antiCheatEnabled: return "Anti-cheat Enabled"
        case .asyncAwaitMigration: return "Async/Await Migration"
        case .backgroundProcessing: return "Background Processing"
        case .smartCaching: return "Smart Caching"
        case .lazyLoading: return "Lazy Loading"
        case .voiceOverEnhanced: return "Enhanced VoiceOver"
        case .highContrastMode: return "High Contrast Mode"
        case .reducedMotion: return "Reduced Motion"
        case .dynamicTypeSupport: return "Dynamic Type Support"
        case .liveActivities: return "Live Activities"
        case .dynamicIsland: return "Dynamic Island"
        case .hapticFeedback: return "Haptic Feedback"
        case .pushNotifications: return "Push Notifications"
        case .debugMode: return "Debug Mode"
        case .performanceMetrics: return "Performance Metrics"
        case .crashReporting: return "Crash Reporting"
        case .analytics: return "Analytics"
        }
    }
    
    public var description: String {
        switch self {
        case .liquidGlassV2: return "Enable the new Liquid Glass design system"
        case .newMapOverlay: return "Enable new map overlay components"
        case .newHuntEngine: return "Enable the new scavenger hunt engine"
        case .appleSignIn: return "Enable Apple Sign In authentication"
        case .magicLink: return "Enable magic link authentication"
        case .biometricAuth: return "Enable biometric authentication"
        case .friendsOnMap: return "Show friends' locations on the map"
        case .realTimeLocation: return "Enable real-time location sharing"
        case .groupTrips: return "Enable group trip planning"
        case .aiAdventureGeneration: return "Enable AI-powered adventure generation"
        case .scavengerHuntMode: return "Enable scavenger hunt mode"
        case .photoProofRequired: return "Require photo proof for checkpoints"
        case .antiCheatEnabled: return "Enable anti-cheat measures"
        case .asyncAwaitMigration: return "Use async/await for concurrency"
        case .backgroundProcessing: return "Process heavy operations in background"
        case .smartCaching: return "Enable smart caching system"
        case .lazyLoading: return "Enable lazy loading for lists"
        case .voiceOverEnhanced: return "Enhanced VoiceOver support"
        case .highContrastMode: return "High contrast mode support"
        case .reducedMotion: return "Reduced motion support"
        case .dynamicTypeSupport: return "Dynamic Type scaling support"
        case .liveActivities: return "Live Activities for Lock Screen"
        case .dynamicIsland: return "Dynamic Island integration"
        case .hapticFeedback: return "Haptic feedback for interactions"
        case .pushNotifications: return "Push notification support"
        case .debugMode: return "Debug mode for development"
        case .performanceMetrics: return "Performance metrics collection"
        case .crashReporting: return "Crash reporting"
        case .analytics: return "Analytics collection"
        }
    }
}

// MARK: - Feature Flag View Modifier

struct FeatureFlagModifier: ViewModifier {
    let feature: Feature
    let fallback: AnyView?
    
    init(feature: Feature, fallback: AnyView? = nil) {
        self.feature = feature
        self.fallback = fallback
    }
    
    func body(content: Content) -> some View {
        if FeatureFlags.shared.isEnabled(feature) {
            content
        } else if let fallback = fallback {
            fallback
        } else {
            EmptyView()
        }
    }
}

extension View {
    /// Show content only if feature flag is enabled
    public func featureFlag(_ feature: Feature, fallback: AnyView? = nil) -> some View {
        modifier(FeatureFlagModifier(feature: feature, fallback: fallback))
    }
}
