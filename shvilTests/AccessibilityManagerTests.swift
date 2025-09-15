//
//  AccessibilityManagerTests.swift
//  shvilTests
//
//  Created by ilan on 2024.
//

import XCTest
@testable import shvil

@MainActor
final class AccessibilityManagerTests: XCTestCase {
    var accessibilityManager: AccessibilityManager!
    
    override func setUp() {
        super.setUp()
        accessibilityManager = AccessibilityManager.shared
    }
    
    func testAccessibilityManagerInitialization() {
        XCTAssertNotNil(accessibilityManager)
        // Initial values should be set based on system settings
        XCTAssertNotNil(accessibilityManager.isVoiceOverEnabled)
        XCTAssertNotNil(accessibilityManager.isReduceMotionEnabled)
        XCTAssertNotNil(accessibilityManager.isReduceTransparencyEnabled)
        XCTAssertNotNil(accessibilityManager.isIncreaseContrastEnabled)
        XCTAssertNotNil(accessibilityManager.preferredContentSizeCategory)
        XCTAssertNotNil(accessibilityManager.isRTLEnabled)
    }
    
    func testGetAccessibleAnimation() {
        let animation = accessibilityManager.getAccessibleAnimation()
        
        if accessibilityManager.isReduceMotionEnabled {
            XCTAssertNil(animation)
        } else {
            XCTAssertNotNil(animation)
        }
    }
    
    func testGetAccessibleSpringAnimation() {
        let animation = accessibilityManager.getAccessibleSpringAnimation()
        
        if accessibilityManager.isReduceMotionEnabled {
            XCTAssertNil(animation)
        } else {
            XCTAssertNotNil(animation)
        }
    }
    
    func testGetAccessibleTransition() {
        let transition = accessibilityManager.getAccessibleTransition()
        
        if accessibilityManager.isReduceMotionEnabled {
            XCTAssertEqual(transition, .identity)
        } else {
            XCTAssertNotEqual(transition, .identity)
        }
    }
    
    func testGetAccessibleColor() {
        let normalColor = Color.blue
        let highContrastColor = Color.red
        
        let resultColor = accessibilityManager.getAccessibleColor(
            normal: normalColor,
            highContrast: highContrastColor
        )
        
        if accessibilityManager.isIncreaseContrastEnabled {
            XCTAssertEqual(resultColor, highContrastColor)
        } else {
            XCTAssertEqual(resultColor, normalColor)
        }
    }
    
    func testGetAccessibleFontSize() {
        let baseSize: CGFloat = 16.0
        let scaleFactor: CGFloat = 1.0
        
        let resultSize = accessibilityManager.getAccessibleFontSize(
            baseSize: baseSize,
            scaleFactor: scaleFactor
        )
        
        // Result size should be adjusted based on content size category
        XCTAssertGreaterThan(resultSize, 0)
        XCTAssertNotEqual(resultSize, baseSize * scaleFactor) // Should be adjusted
    }
    
    func testGetAccessibleHitTargetSize() {
        let hitTargetSize = accessibilityManager.getAccessibleHitTargetSize()
        
        // Should be at least 44 points for accessibility
        XCTAssertGreaterThanOrEqual(hitTargetSize, 44.0)
        
        // Should be larger for accessibility content size categories
        if accessibilityManager.preferredContentSizeCategory.isAccessibilityCategory {
            XCTAssertGreaterThanOrEqual(hitTargetSize, 60.0)
        }
    }
    
    func testGetAccessibleSpacing() {
        let baseSpacing: CGFloat = 16.0
        let scaleFactor: CGFloat = 1.0
        
        let resultSpacing = accessibilityManager.getAccessibleSpacing(
            baseSpacing: baseSpacing,
            scaleFactor: scaleFactor
        )
        
        // Result spacing should be adjusted based on content size category
        XCTAssertGreaterThan(resultSpacing, 0)
        XCTAssertNotEqual(resultSpacing, baseSpacing * scaleFactor) // Should be adjusted
    }
}
