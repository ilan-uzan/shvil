//
//  DesignSystemTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

/*
import XCTest
@testable import shvil

final class DesignSystemTests: XCTestCase {
    
    // MARK: - Theme Tests
    
    func testThemeInitialization() {
        let theme = Theme.shared
        
        XCTAssertNotNil(theme)
        XCTAssertNotNil(theme.colors)
        XCTAssertNotNil(theme.typography)
        XCTAssertNotNil(theme.spacing)
        XCTAssertNotNil(theme.cornerRadius)
    }
    
    func testThemeColors() {
        let theme = Theme.shared
        
        // Test brand colors
        XCTAssertNotNil(theme.colors.brand.primary)
        XCTAssertNotNil(theme.colors.brand.secondary)
        XCTAssertNotNil(theme.colors.brand.accent)
        
        // Test semantic colors
        XCTAssertNotNil(theme.colors.semantic.success)
        XCTAssertNotNil(theme.colors.semantic.warning)
        XCTAssertNotNil(theme.colors.semantic.error)
        XCTAssertNotNil(theme.colors.semantic.info)
        
        // Test neutral colors
        XCTAssertNotNil(theme.colors.neutral.background)
        XCTAssertNotNil(theme.colors.neutral.surface)
        XCTAssertNotNil(theme.colors.neutral.text)
        XCTAssertNotNil(theme.colors.neutral.textSecondary)
    }
    
    func testThemeTypography() {
        let theme = Theme.shared
        
        // Test font families
        XCTAssertNotNil(theme.typography.fontFamily.primary)
        XCTAssertNotNil(theme.typography.fontFamily.secondary)
        XCTAssertNotNil(theme.typography.fontFamily.monospace)
        
        // Test font sizes
        XCTAssertTrue(theme.typography.fontSize.caption > 0)
        XCTAssertTrue(theme.typography.fontSize.body > theme.typography.fontSize.caption)
        XCTAssertTrue(theme.typography.fontSize.headline > theme.typography.fontSize.body)
        XCTAssertTrue(theme.typography.fontSize.title > theme.typography.fontSize.headline)
        XCTAssertTrue(theme.typography.fontSize.largeTitle > theme.typography.fontSize.title)
    }
    
    func testThemeSpacing() {
        let theme = Theme.shared
        
        // Test spacing values
        XCTAssertTrue(theme.spacing.xs > 0)
        XCTAssertTrue(theme.spacing.sm > theme.spacing.xs)
        XCTAssertTrue(theme.spacing.md > theme.spacing.sm)
        XCTAssertTrue(theme.spacing.lg > theme.spacing.md)
        XCTAssertTrue(theme.spacing.xl > theme.spacing.lg)
        XCTAssertTrue(theme.spacing.xxl > theme.spacing.xl)
    }
    
    func testThemeCornerRadius() {
        let theme = Theme.shared
        
        // Test corner radius values
        XCTAssertTrue(theme.cornerRadius.sm > 0)
        XCTAssertTrue(theme.cornerRadius.md > theme.cornerRadius.sm)
        XCTAssertTrue(theme.cornerRadius.lg > theme.cornerRadius.md)
        XCTAssertTrue(theme.cornerRadius.xl > theme.cornerRadius.lg)
    }
    
    // MARK: - Design Tokens Tests
    
    func testDesignTokens() {
        let tokens = DesignTokens.shared
        
        XCTAssertNotNil(tokens)
        XCTAssertNotNil(tokens.brand)
        XCTAssertNotNil(tokens.semantic)
        XCTAssertNotNil(tokens.neutral)
    }
    
    func testBrandTokens() {
        let brand = DesignTokens.Brand()
        
        XCTAssertNotNil(brand.primary)
        XCTAssertNotNil(brand.secondary)
        XCTAssertNotNil(brand.accent)
    }
    
    func testSemanticTokens() {
        let semantic = DesignTokens.Semantic()
        
        XCTAssertNotNil(semantic.success)
        XCTAssertNotNil(semantic.warning)
        XCTAssertNotNil(semantic.error)
        XCTAssertNotNil(semantic.info)
    }
    
    func testNeutralTokens() {
        let neutral = DesignTokens.Neutral()
        
        XCTAssertNotNil(neutral.background)
        XCTAssertNotNil(neutral.surface)
        XCTAssertNotNil(neutral.text)
        XCTAssertNotNil(neutral.textSecondary)
    }
    
    // MARK: - Color Tests
    
    func testColorInitialization() {
        let color = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        XCTAssertNotNil(color)
    }
    
    func testColorEquality() {
        let color1 = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let color2 = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        XCTAssertEqual(color1, color2)
    }
    
    // MARK: - Typography Tests
    
    func testFontWeight() {
        let weights = FontWeight.allCases
        
        XCTAssertTrue(weights.contains(.ultraLight))
        XCTAssertTrue(weights.contains(.thin))
        XCTAssertTrue(weights.contains(.light))
        XCTAssertTrue(weights.contains(.regular))
        XCTAssertTrue(weights.contains(.medium))
        XCTAssertTrue(weights.contains(.semibold))
        XCTAssertTrue(weights.contains(.bold))
        XCTAssertTrue(weights.contains(.heavy))
        XCTAssertTrue(weights.contains(.black))
    }
    
    func testFontSize() {
        let sizes = FontSize.allCases
        
        XCTAssertTrue(sizes.contains(.caption))
        XCTAssertTrue(sizes.contains(.body))
        XCTAssertTrue(sizes.contains(.headline))
        XCTAssertTrue(sizes.contains(.title))
        XCTAssertTrue(sizes.contains(.largeTitle))
    }
    
    // MARK: - Spacing Tests
    
    func testSpacingValues() {
        let spacing = Spacing()
        
        XCTAssertTrue(spacing.xs > 0)
        XCTAssertTrue(spacing.sm > spacing.xs)
        XCTAssertTrue(spacing.md > spacing.sm)
        XCTAssertTrue(spacing.lg > spacing.md)
        XCTAssertTrue(spacing.xl > spacing.lg)
        XCTAssertTrue(spacing.xxl > spacing.xl)
    }
    
    // MARK: - Corner Radius Tests
    
    func testCornerRadiusValues() {
        let cornerRadius = CornerRadius()
        
        XCTAssertTrue(cornerRadius.sm > 0)
        XCTAssertTrue(cornerRadius.md > cornerRadius.sm)
        XCTAssertTrue(cornerRadius.lg > cornerRadius.md)
        XCTAssertTrue(cornerRadius.xl > cornerRadius.lg)
    }
    
    // MARK: - Performance Tests
    
    func testThemePerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = Theme.shared
            }
        }
    }
    
    func testDesignTokensPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = DesignTokens.shared
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testThemeSingleton() {
        let theme1 = Theme.shared
        let theme2 = Theme.shared
        
        XCTAssertIdentical(theme1, theme2)
    }
    
    func testDesignTokensSingleton() {
        let tokens1 = DesignTokens.shared
        let tokens2 = DesignTokens.shared
        
        XCTAssertIdentical(tokens1, tokens2)
    }
}
*/