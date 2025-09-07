//
//  DesignSystemTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

import XCTest
import SwiftUI
@testable import shvil

final class DesignSystemTests: XCTestCase {
    
    // MARK: - Design Tokens Tests
    
    func testBrandColors() {
        // Test brand color values
        XCTAssertNotNil(DesignTokens.Brand.primary)
        XCTAssertNotNil(DesignTokens.Brand.primaryMid)
        XCTAssertNotNil(DesignTokens.Brand.primaryDark)
        XCTAssertNotNil(DesignTokens.Brand.gradient)
    }
    
    func testSemanticColors() {
        // Test semantic color values
        XCTAssertNotNil(DesignTokens.Semantic.success)
        XCTAssertNotNil(DesignTokens.Semantic.warning)
        XCTAssertNotNil(DesignTokens.Semantic.error)
        XCTAssertNotNil(DesignTokens.Semantic.info)
    }
    
    func testSurfaceColors() {
        // Test surface color values
        XCTAssertNotNil(DesignTokens.Surface.background)
        XCTAssertNotNil(DesignTokens.Surface.primary)
        XCTAssertNotNil(DesignTokens.Surface.secondary)
        XCTAssertNotNil(DesignTokens.Surface.tertiary)
    }
    
    func testTextColors() {
        // Test text color values
        XCTAssertNotNil(DesignTokens.Text.primary)
        XCTAssertNotNil(DesignTokens.Text.secondary)
        XCTAssertNotNil(DesignTokens.Text.tertiary)
        XCTAssertNotNil(DesignTokens.Text.quaternary)
    }
    
    func testSpacingValues() {
        // Test spacing values follow 8pt grid
        XCTAssertEqual(DesignTokens.Spacing.xs, 4)
        XCTAssertEqual(DesignTokens.Spacing.sm, 8)
        XCTAssertEqual(DesignTokens.Spacing.md, 16)
        XCTAssertEqual(DesignTokens.Spacing.lg, 24)
        XCTAssertEqual(DesignTokens.Spacing.xl, 32)
        XCTAssertEqual(DesignTokens.Spacing.xxl, 40)
        XCTAssertEqual(DesignTokens.Spacing.xxxl, 48)
    }
    
    func testCornerRadiusValues() {
        // Test corner radius values
        XCTAssertEqual(DesignTokens.CornerRadius.xs, 4)
        XCTAssertEqual(DesignTokens.CornerRadius.sm, 8)
        XCTAssertEqual(DesignTokens.CornerRadius.md, 12)
        XCTAssertEqual(DesignTokens.CornerRadius.lg, 16)
        XCTAssertEqual(DesignTokens.CornerRadius.xl, 20)
        XCTAssertEqual(DesignTokens.CornerRadius.xxl, 24)
    }
    
    func testTypographyValues() {
        // Test typography values exist
        XCTAssertNotNil(DesignTokens.Typography.largeTitle)
        XCTAssertNotNil(DesignTokens.Typography.title)
        XCTAssertNotNil(DesignTokens.Typography.title2)
        XCTAssertNotNil(DesignTokens.Typography.title3)
        XCTAssertNotNil(DesignTokens.Typography.headline)
        XCTAssertNotNil(DesignTokens.Typography.body)
        XCTAssertNotNil(DesignTokens.Typography.callout)
        XCTAssertNotNil(DesignTokens.Typography.subheadline)
        XCTAssertNotNil(DesignTokens.Typography.footnote)
        XCTAssertNotNil(DesignTokens.Typography.caption1)
        XCTAssertNotNil(DesignTokens.Typography.caption2)
    }
    
    func testAnimationValues() {
        // Test animation values exist
        XCTAssertNotNil(DesignTokens.Animation.micro)
        XCTAssertNotNil(DesignTokens.Animation.standard)
        XCTAssertNotNil(DesignTokens.Animation.complex)
        XCTAssertNotNil(DesignTokens.Animation.spring)
        XCTAssertNotNil(DesignTokens.Animation.ripple)
        XCTAssertNotNil(DesignTokens.Animation.glassFloat)
        XCTAssertNotNil(DesignTokens.Animation.parallax)
        XCTAssertNotNil(DesignTokens.Animation.liquidFlow)
    }
    
    // MARK: - Component Tests
    
    func testLiquidGlassButton() {
        // Test button creation
        let button = LiquidGlassButton("Test Button") { }
        XCTAssertNotNil(button)
    }
    
    func testLiquidGlassCard() {
        // Test card creation
        let card = LiquidGlassCard {
            Text("Test Content")
        }
        XCTAssertNotNil(card)
    }
    
    func testLiquidGlassTextField() {
        // Test text field creation
        let textField = LiquidGlassTextField("Test Field", text: .constant(""))
        XCTAssertNotNil(textField)
    }
    
    func testLiquidGlassListRow() {
        // Test list row creation
        let listRow = LiquidGlassListRow {
            Text("Test Row")
        }
        XCTAssertNotNil(listRow)
    }
    
    // MARK: - Theme Manager Tests
    
    func testThemeManagerInitialization() {
        let themeManager = ThemeManager.shared
        XCTAssertNotNil(themeManager)
    }
    
    func testThemeManagerDarkModeToggle() {
        let themeManager = ThemeManager.shared
        let initialDarkMode = themeManager.isDarkMode
        themeManager.toggleDarkMode()
        XCTAssertNotEqual(themeManager.isDarkMode, initialDarkMode)
    }
    
    // MARK: - Design Constants Tests
    
    func testDesignConstants() {
        XCTAssertEqual(DesignConstants.minimumHitTarget, 44)
        XCTAssertEqual(DesignConstants.maxContentWidth, 600)
        XCTAssertEqual(DesignConstants.cardPadding, DesignTokens.Spacing.md)
        XCTAssertEqual(DesignConstants.listItemHeight, 56)
        XCTAssertEqual(DesignConstants.buttonHeight, 44)
        XCTAssertEqual(DesignConstants.inputHeight, 48)
    }
}
