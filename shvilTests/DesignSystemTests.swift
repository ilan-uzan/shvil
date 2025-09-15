//
//  DesignSystemTests.swift
//  shvilTests
//
//  Created by ilan on 2024.
//

import XCTest
import SwiftUI
@testable import shvil

final class DesignSystemTests: XCTestCase {
    
    // MARK: - Design Tokens Tests
    
    func testDesignTokensInitialization() throws {
        // Test that design tokens are properly initialized
        XCTAssertNotNil(DesignTokens.Brand.primary)
        XCTAssertNotNil(DesignTokens.Brand.gradient)
        XCTAssertNotNil(DesignTokens.Semantic.success)
        XCTAssertNotNil(DesignTokens.Semantic.error)
        XCTAssertNotNil(DesignTokens.Surface.background)
        XCTAssertNotNil(DesignTokens.Text.primary)
    }
    
    func testColorSystem() throws {
        // Test brand colors
        let primary = DesignTokens.Brand.primary
        let primaryMid = DesignTokens.Brand.primaryMid
        let primaryDark = DesignTokens.Brand.primaryDark
        
        XCTAssertNotNil(primary)
        XCTAssertNotNil(primaryMid)
        XCTAssertNotNil(primaryDark)
        
        // Test semantic colors
        let success = DesignTokens.Semantic.success
        let warning = DesignTokens.Semantic.warning
        let error = DesignTokens.Semantic.error
        
        XCTAssertNotNil(success)
        XCTAssertNotNil(warning)
        XCTAssertNotNil(error)
    }
    
    func testTypographySystem() throws {
        // Test typography scale
        let largeTitle = DesignTokens.Typography.largeTitle
        let title = DesignTokens.Typography.title
        let body = DesignTokens.Typography.body
        let caption = DesignTokens.Typography.caption1
        
        XCTAssertNotNil(largeTitle)
        XCTAssertNotNil(title)
        XCTAssertNotNil(body)
        XCTAssertNotNil(caption)
    }
    
    func testSpacingSystem() throws {
        // Test spacing scale
        XCTAssertEqual(DesignTokens.Spacing.xs, 4)
        XCTAssertEqual(DesignTokens.Spacing.sm, 8)
        XCTAssertEqual(DesignTokens.Spacing.md, 16)
        XCTAssertEqual(DesignTokens.Spacing.lg, 24)
        XCTAssertEqual(DesignTokens.Spacing.xl, 32)
    }
    
    func testCornerRadiusSystem() throws {
        // Test corner radius scale
        XCTAssertEqual(DesignTokens.CornerRadius.xs, 4)
        XCTAssertEqual(DesignTokens.CornerRadius.sm, 8)
        XCTAssertEqual(DesignTokens.CornerRadius.md, 12)
        XCTAssertEqual(DesignTokens.CornerRadius.lg, 16)
        XCTAssertEqual(DesignTokens.CornerRadius.xl, 20)
    }
    
    func testShadowSystem() throws {
        // Test shadow values
        let light = DesignTokens.Shadow.light
        let medium = DesignTokens.Shadow.medium
        let heavy = DesignTokens.Shadow.heavy
        
        XCTAssertNotNil(light)
        XCTAssertNotNil(medium)
        XCTAssertNotNil(heavy)
        
        // Test shadow properties
        XCTAssertEqual(light.radius, 6)
        XCTAssertEqual(medium.radius, 12)
        XCTAssertEqual(heavy.radius, 18)
    }
    
    func testAnimationSystem() throws {
        // Test animation durations
        let micro = DesignTokens.Animation.micro
        let standard = DesignTokens.Animation.standard
        let complex = DesignTokens.Animation.complex
        
        XCTAssertNotNil(micro)
        XCTAssertNotNil(standard)
        XCTAssertNotNil(complex)
    }
    
    func testLayoutConstants() throws {
        // Test layout constants
        XCTAssertEqual(DesignTokens.Layout.minTouchTarget, 44)
        XCTAssertEqual(DesignTokens.Layout.buttonHeight, 44)
        XCTAssertEqual(DesignTokens.Layout.inputHeight, 48)
        XCTAssertEqual(DesignTokens.Layout.listRowHeight, 56)
        XCTAssertEqual(DesignTokens.Layout.tabBarHeight, 83)
    }
    
    // MARK: - Feature Flags Tests
    
    func testFeatureFlagsInitialization() throws {
        let featureFlags = FeatureFlags.shared
        
        // Test that feature flags are properly initialized
        XCTAssertNotNil(featureFlags)
        XCTAssertTrue(featureFlags.liquidGlassV2)
        XCTAssertTrue(featureFlags.liquidGlassNavV1)
        XCTAssertFalse(featureFlags.newMapOverlay)
        XCTAssertFalse(featureFlags.newHuntEngine)
    }
    
    func testFeatureFlagMethods() throws {
        let featureFlags = FeatureFlags.shared
        
        // Test feature flag checking
        XCTAssertTrue(featureFlags.isEnabled(.liquidGlassV2))
        XCTAssertTrue(featureFlags.isEnabled(.liquidGlassNavV1))
        XCTAssertFalse(featureFlags.isEnabled(.newMapOverlay))
        
        // Test enabling/disabling features
        featureFlags.enable(.newMapOverlay)
        XCTAssertTrue(featureFlags.isEnabled(.newMapOverlay))
        
        featureFlags.disable(.newMapOverlay)
        XCTAssertFalse(featureFlags.isEnabled(.newMapOverlay))
    }
    
    func testFeatureFlagReset() throws {
        let featureFlags = FeatureFlags.shared
        
        // Enable a feature
        featureFlags.enable(.newMapOverlay)
        XCTAssertTrue(featureFlags.isEnabled(.newMapOverlay))
        
        // Reset to defaults
        featureFlags.resetToDefaults()
        XCTAssertFalse(featureFlags.isEnabled(.newMapOverlay))
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilitySystem() throws {
        // Test accessibility system initialization
        XCTAssertNotNil(AccessibilitySystem.shared)
    }
    
    func testAccessibilityTraits() throws {
        // Test accessibility traits helper
        let buttonTraits = AccessibilityTraitsHelper.button
        let linkTraits = AccessibilityTraitsHelper.link
        let imageTraits = AccessibilityTraitsHelper.image
        
        XCTAssertNotNil(buttonTraits)
        XCTAssertNotNil(linkTraits)
        XCTAssertNotNil(imageTraits)
    }
    
    // MARK: - Performance Tests
    
    func testDesignTokensPerformance() throws {
        // Test that design tokens can be accessed quickly
        measure {
            for _ in 0..<1000 {
                _ = DesignTokens.Brand.primary
                _ = DesignTokens.Semantic.success
                _ = DesignTokens.Typography.body
                _ = DesignTokens.Spacing.md
                _ = DesignTokens.CornerRadius.md
            }
        }
    }
    
    func testFeatureFlagsPerformance() throws {
        let featureFlags = FeatureFlags.shared
        
        // Test that feature flag checking is fast
        measure {
            for _ in 0..<1000 {
                _ = featureFlags.isEnabled(.liquidGlassV2)
                _ = featureFlags.isEnabled(.newMapOverlay)
                _ = featureFlags.isEnabled(.aiAdventureGeneration)
            }
        }
    }
}
