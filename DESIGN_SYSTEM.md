# Shvil Design System - Liquid Glass Navigation

## Overview

This document outlines the Liquid Glass design system implementation for Shvil's navigation components, specifically the Apple Music-style bottom navigation bar.

## Design Tokens Used

### Colors
- **Brand Colors**: `DesignTokens.Brand.primary`, `DesignTokens.Brand.primaryMid`
- **Semantic Colors**: `DesignTokens.Semantic.success`, `DesignTokens.Semantic.warning`, `DesignTokens.Semantic.info`
- **Text Colors**: `DesignTokens.Text.primary`, `DesignTokens.Text.secondary`, `DesignTokens.Text.tertiary`
- **Surface Colors**: `DesignTokens.Surface.primary`, `DesignTokens.Surface.secondary`, `DesignTokens.Surface.background`

### Spacing
- **Small**: `DesignTokens.Spacing.sm` (8pt)
- **Medium**: `DesignTokens.Spacing.md` (16pt)
- **Large**: `DesignTokens.Spacing.lg` (24pt)
- **Extra Large**: `DesignTokens.Spacing.xl` (32pt)

### Corner Radius
- **Small**: `DesignTokens.CornerRadius.sm` (4pt)
- **Medium**: `DesignTokens.CornerRadius.md` (8pt)
- **Large**: `DesignTokens.CornerRadius.lg` (12pt)
- **Extra Large**: `DesignTokens.CornerRadius.xl` (20pt)

### Shadows
- **Light**: `DesignTokens.Shadow.light` (6pt radius, 2pt y-offset)
- **Heavy**: `DesignTokens.Shadow.heavy` (18pt radius, 8pt y-offset)

### Typography
- **Caption**: `DesignTokens.Typography.caption1` (12pt)
- **Body**: `DesignTokens.Typography.body` (16pt)
- **Headline**: `DesignTokens.Typography.headline` (18pt)

## Component Architecture

### GlassTabBar
The main navigation component featuring:
- Frosted glass background with ultra-thin material
- Dynamic tinting based on selected tab
- Liquid capsule morphing animation
- Spring-based selection animations

### GlassTabButton
Individual tab button with:
- Icon and text labels
- Selected state styling
- Press animations
- Accessibility support

### LiquidCapsule
The animated selection indicator featuring:
- Convex, gel-like appearance
- Smooth morphing between tabs
- Gloss stripe overlay
- Micro-bloom effect

### ColorSampler
Utility for dynamic color adaptation:
- Context-aware color sampling
- Contrast ratio validation
- Color caching for performance
- Fallback to safe colors

## Visual Layers (Back to Front)

1. **Backdrop Blur Layer**
   - Ultra-thin material with 1.2x saturation
   - Film grain overlay for depth

2. **Glass Body Layer**
   - Dynamic tint-based gradient
   - Inner specular highlight
   - Parallax scroll effect

3. **Border Highlight**
   - Hairline border with gradient
   - Top/bottom light/dark split

4. **Shadow/Elevation**
   - Soft drop shadow
   - Separates from content below

5. **Selection Capsule**
   - Convex, gel-like appearance
   - Bright tint with extra gloss
   - Micro-bloom around edges

## Animation Specifications

### Selection Animation
- **Response**: 0.35-0.45
- **Damping**: 0.75-0.85
- **Duration**: ~200ms
- **Haptic**: Selection changed feedback

### Capsule Morphing
- **Width Interpolation**: Smooth width changes
- **X Translation**: Spring-based position updates
- **Scale Effect**: 1.02x during animation

### Tint Adaptation
- **Duration**: 160-220ms
- **Easing**: Ease in-out
- **Contrast**: AA/AAA compliance maintained

## Accessibility Features

- **Hit Targets**: Minimum 44pt
- **VoiceOver**: Proper labels and hints
- **Focus Order**: Correct tab order
- **RTL Support**: Mirrored capsule morphing
- **Dynamic Type**: Scalable text

## Performance Considerations

- **GPU-Friendly**: Opacity/transform animations only
- **Color Caching**: LRU cache for sampled colors
- **Throttled Sampling**: Route change-based updates
- **Fallback Support**: Simpler blur on older iOS

## Feature Flag

The Liquid Glass navigation is controlled by the `liquidGlassNavV1` feature flag:
- **Enabled**: Uses GlassTabBar with full effects
- **Disabled**: Falls back to FloatingNavigationPill

## Integration

```swift
if FeatureFlags.shared.isEnabled(.liquidGlassNavV1) {
    GlassTabBar(tabs: tabs, selectedTab: $selectedTab, onSelect: onSelect)
} else {
    FloatingNavigationPill(selectedTab: $selectedTab, tabs: tabs)
}
```

## Testing

- **Snapshot Tests**: Light/dark, RTL, Dynamic Type
- **Interaction Tests**: Tab switching, capsule morphing
- **Performance Tests**: Scroll + rapid tab changes
- **Accessibility Tests**: VoiceOver navigation
