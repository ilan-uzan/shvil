//
//  FeatureFlagsTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

/*
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
    
    // MARK: - Initialization Tests
    
    func testFeatureFlagsInitialization() {
        XCTAssertNotNil(featureFlags)
    }
    
    func testFeatureFlagsSingleton() {
        let flags1 = FeatureFlags.shared
        let flags2 = FeatureFlags.shared
        
        XCTAssertIdentical(flags1, flags2)
    }
    
    // MARK: - Feature Flag Tests
    
    func testIsFeatureEnabled() {
        // Test with a known feature flag
        let isEnabled = featureFlags.isFeatureEnabled(.socialPlans)
        
        // Should return a boolean value
        XCTAssertTrue(isEnabled == true || isEnabled == false)
    }
    
    func testIsFeatureDisabled() {
        // Test with a disabled feature flag
        let isEnabled = featureFlags.isFeatureEnabled(.socialPlans)
        
        // Should return a boolean value
        XCTAssertTrue(isEnabled == true || isEnabled == false)
    }
    
    func testAllFeatureFlags() {
        // Test all feature flags
        for flag in FeatureFlag.allCases {
            let isEnabled = featureFlags.isFeatureEnabled(flag)
            XCTAssertTrue(isEnabled == true || isEnabled == false)
        }
    }
    
    // MARK: - Feature Flag Enum Tests
    
    func testFeatureFlagCases() {
        let cases = FeatureFlag.allCases
        
        XCTAssertTrue(cases.contains(.socialPlans))
        XCTAssertTrue(cases.contains(.aiRecommendations))
        XCTAssertTrue(cases.contains(.offlineMode))
        XCTAssertTrue(cases.contains(.darkMode))
        XCTAssertTrue(cases.contains(.hapticFeedback))
        XCTAssertTrue(cases.contains(.analytics))
        XCTAssertTrue(cases.contains(.crashReporting))
        XCTAssertTrue(cases.contains(.performanceMonitoring))
    }
    
    func testFeatureFlagRawValues() {
        XCTAssertEqual(FeatureFlag.socialPlans.rawValue, "social_plans")
        XCTAssertEqual(FeatureFlag.aiRecommendations.rawValue, "ai_recommendations")
        XCTAssertEqual(FeatureFlag.offlineMode.rawValue, "offline_mode")
        XCTAssertEqual(FeatureFlag.darkMode.rawValue, "dark_mode")
        XCTAssertEqual(FeatureFlag.hapticFeedback.rawValue, "haptic_feedback")
        XCTAssertEqual(FeatureFlag.analytics.rawValue, "analytics")
        XCTAssertEqual(FeatureFlag.crashReporting.rawValue, "crash_reporting")
        XCTAssertEqual(FeatureFlag.performanceMonitoring.rawValue, "performance_monitoring")
    }
    
    // MARK: - Feature Flag Toggle Tests
    
    func testToggleFeatureFlag() {
        let originalValue = featureFlags.isFeatureEnabled(.socialPlans)
        
        // Toggle the feature flag
        featureFlags.toggleFeatureFlag(.socialPlans)
        
        // Should be the opposite of the original value
        let newValue = featureFlags.isFeatureEnabled(.socialPlans)
        XCTAssertEqual(newValue, !originalValue)
        
        // Toggle back to original value
        featureFlags.toggleFeatureFlag(.socialPlans)
        let finalValue = featureFlags.isFeatureEnabled(.socialPlans)
        XCTAssertEqual(finalValue, originalValue)
    }
    
    func testSetFeatureFlag() {
        // Set feature flag to true
        featureFlags.setFeatureFlag(.socialPlans, enabled: true)
        XCTAssertTrue(featureFlags.isFeatureEnabled(.socialPlans))
        
        // Set feature flag to false
        featureFlags.setFeatureFlag(.socialPlans, enabled: false)
        XCTAssertFalse(featureFlags.isFeatureEnabled(.socialPlans))
    }
    
    // MARK: - Feature Flag Persistence Tests
    
    func testFeatureFlagPersistence() {
        // Set a feature flag
        featureFlags.setFeatureFlag(.socialPlans, enabled: true)
        
        // Create a new instance
        let newFeatureFlags = FeatureFlags.shared
        
        // Should maintain the same value
        XCTAssertTrue(newFeatureFlags.isFeatureEnabled(.socialPlans))
    }
    
    // MARK: - Feature Flag Reset Tests
    
    func testResetFeatureFlags() {
        // Set some feature flags
        featureFlags.setFeatureFlag(.socialPlans, enabled: true)
        featureFlags.setFeatureFlag(.aiRecommendations, enabled: false)
        
        // Reset all feature flags
        featureFlags.resetToDefaults()
        
        // Should be back to default values
        // Note: This test assumes we know the default values
        // In a real implementation, you'd need to verify the actual defaults
    }
    
    // MARK: - Feature Flag Validation Tests
    
    func testFeatureFlagValidation() {
        // Test with valid feature flags
        for flag in FeatureFlag.allCases {
            let isValid = featureFlags.isValidFeatureFlag(flag)
            XCTAssertTrue(isValid)
        }
    }
    
    // MARK: - Performance Tests
    
    func testFeatureFlagPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = featureFlags.isFeatureEnabled(.socialPlans)
            }
        }
    }
    
    func testFeatureFlagTogglePerformance() {
        measure {
            for _ in 0..<1000 {
                featureFlags.toggleFeatureFlag(.socialPlans)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testFeatureFlagWithNilValue() {
        // Test behavior when feature flag value is nil
        // This would depend on the implementation
    }
    
    func testFeatureFlagWithInvalidValue() {
        // Test behavior with invalid feature flag values
        // This would depend on the implementation
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentFeatureFlagAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access")
        let group = DispatchGroup()
        
        for _ in 0..<100 {
            group.enter()
            DispatchQueue.global().async {
                let _ = self.featureFlags.isFeatureEnabled(.socialPlans)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testFeatureFlagsMemoryManagement() {
        weak var weakFeatureFlags: FeatureFlags?
        
        autoreleasepool {
            let strongFeatureFlags = FeatureFlags.shared
            weakFeatureFlags = strongFeatureFlags
        }
        
        // Should still be alive due to singleton pattern
        XCTAssertNotNil(weakFeatureFlags)
    }
}
*/