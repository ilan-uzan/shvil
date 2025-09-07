//
//  FeatureFlagsTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

import XCTest
@testable import shvil

final class FeatureFlagsTests: XCTestCase {
    
    var featureFlags: FeatureFlags!
    
    override func setUp() {
        super.setUp()
        featureFlags = FeatureFlags.shared
    }
    
    override func tearDown() {
        featureFlags = nil
        super.tearDown()
    }
    
    // MARK: - Feature Flag Tests
    
    func testFeatureFlagInitialization() {
        XCTAssertNotNil(featureFlags)
    }
    
    func testDefaultFeatureFlags() {
        // Test that default feature flags are set correctly
        XCTAssertTrue(featureFlags.liquidGlassV2)
        XCTAssertFalse(featureFlags.newMapOverlay)
        XCTAssertFalse(featureFlags.newHuntEngine)
        XCTAssertFalse(featureFlags.appleSignInEnabled)
        XCTAssertTrue(featureFlags.magicLinkEnabled)
        XCTAssertFalse(featureFlags.biometricAuthEnabled)
    }
    
    func testFeatureFlagEnable() {
        let initialValue = featureFlags.newMapOverlay
        featureFlags.enable(.newMapOverlay)
        XCTAssertTrue(featureFlags.newMapOverlay)
        XCTAssertNotEqual(featureFlags.newMapOverlay, initialValue)
    }
    
    func testFeatureFlagDisable() {
        let initialValue = featureFlags.liquidGlassV2
        featureFlags.disable(.liquidGlassV2)
        XCTAssertFalse(featureFlags.liquidGlassV2)
        XCTAssertNotEqual(featureFlags.liquidGlassV2, initialValue)
    }
    
    func testFeatureFlagIsEnabled() {
        featureFlags.enable(.appleSignIn)
        XCTAssertTrue(featureFlags.isEnabled(.appleSignIn))
        
        featureFlags.disable(.appleSignIn)
        XCTAssertFalse(featureFlags.isEnabled(.appleSignIn))
    }
    
    func testResetToDefaults() {
        // Change some flags
        featureFlags.enable(.newMapOverlay)
        featureFlags.disable(.liquidGlassV2)
        
        // Reset to defaults
        featureFlags.resetToDefaults()
        
        // Check that defaults are restored
        XCTAssertTrue(featureFlags.liquidGlassV2)
        XCTAssertFalse(featureFlags.newMapOverlay)
    }
    
    // MARK: - Feature Enum Tests
    
    func testFeatureEnumCases() {
        let allFeatures = Feature.allCases
        XCTAssertFalse(allFeatures.isEmpty)
        
        // Test that all features have display names
        for feature in allFeatures {
            XCTAssertFalse(feature.displayName.isEmpty)
            XCTAssertFalse(feature.description.isEmpty)
        }
    }
    
    func testFeatureEnumRawValues() {
        XCTAssertEqual(Feature.liquidGlassV2.rawValue, "liquid_glass_v2")
        XCTAssertEqual(Feature.appleSignIn.rawValue, "apple_signin")
        XCTAssertEqual(Feature.magicLink.rawValue, "magic_link")
    }
    
    // MARK: - Feature Flag Persistence Tests
    
    func testFeatureFlagPersistence() {
        // Enable a feature
        featureFlags.enable(.newMapOverlay)
        
        // Create a new instance (simulating app restart)
        let newFeatureFlags = FeatureFlags.shared
        
        // Check that the feature is still enabled
        XCTAssertTrue(newFeatureFlags.newMapOverlay)
    }
    
    // MARK: - Feature Flag Categories Tests
    
    func testDesignSystemFlags() {
        XCTAssertTrue(featureFlags.liquidGlassV2)
        XCTAssertFalse(featureFlags.newMapOverlay)
        XCTAssertFalse(featureFlags.newHuntEngine)
    }
    
    func testAuthenticationFlags() {
        XCTAssertFalse(featureFlags.appleSignInEnabled)
        XCTAssertTrue(featureFlags.magicLinkEnabled)
        XCTAssertFalse(featureFlags.biometricAuthEnabled)
    }
    
    func testSocialFlags() {
        XCTAssertFalse(featureFlags.friendsOnMapEnabled)
        XCTAssertFalse(featureFlags.realTimeLocationEnabled)
        XCTAssertFalse(featureFlags.groupTripsEnabled)
    }
    
    func testAdventureFlags() {
        XCTAssertTrue(featureFlags.aiAdventureGeneration)
        XCTAssertTrue(featureFlags.scavengerHuntMode)
        XCTAssertTrue(featureFlags.photoProofRequired)
        XCTAssertTrue(featureFlags.antiCheatEnabled)
    }
    
    func testPerformanceFlags() {
        XCTAssertTrue(featureFlags.asyncAwaitMigration)
        XCTAssertTrue(featureFlags.backgroundProcessing)
        XCTAssertTrue(featureFlags.smartCaching)
        XCTAssertTrue(featureFlags.lazyLoading)
    }
    
    func testAccessibilityFlags() {
        XCTAssertTrue(featureFlags.voiceOverEnhanced)
        XCTAssertTrue(featureFlags.highContrastMode)
        XCTAssertTrue(featureFlags.reducedMotion)
        XCTAssertTrue(featureFlags.dynamicTypeSupport)
    }
    
    func testPlatformFlags() {
        XCTAssertTrue(featureFlags.liveActivitiesEnabled)
        XCTAssertTrue(featureFlags.dynamicIslandEnabled)
        XCTAssertTrue(featureFlags.hapticFeedbackEnabled)
        XCTAssertTrue(featureFlags.pushNotificationsEnabled)
    }
    
    func testDevelopmentFlags() {
        XCTAssertFalse(featureFlags.debugMode)
        XCTAssertFalse(featureFlags.performanceMetrics)
        XCTAssertTrue(featureFlags.crashReporting)
        XCTAssertTrue(featureFlags.analyticsEnabled)
    }
}
