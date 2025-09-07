# Shvil Navigation System

## Overview

Shvil features a modern, Apple Music-style Liquid Glass bottom navigation system that provides an intuitive and visually appealing way to navigate between the app's main sections.

## Navigation Structure

### Tab Order
1. **Map** - Main map interface with search
2. **Socialize** - Social features and group management
3. **Hunt** - Scavenger hunt functionality
4. **Adventure** - Adventure planning and management
5. **Settings** - App settings and preferences

### Visual Design
- **Frosted Glass**: Translucent background with blur effects
- **Liquid Capsule**: Animated selection indicator
- **Dynamic Tinting**: Colors adapt based on selected tab
- **Spring Animations**: Natural, bouncy interactions

## Components

### GlassTabBar
The main navigation component that renders the bottom tab bar.

```swift
GlassTabBar(
    tabs: [GlassTabItem],
    selectedTab: Binding<Int>,
    onSelect: (Int) -> Void
)
```

### GlassTabItem
Data structure representing a navigation tab.

```swift
GlassTabItem(
    icon: String,
    selectedIcon: String?,
    title: String,
    route: String
)
```

### ColorSampler
Utility for dynamic color adaptation and contrast validation.

```swift
ColorSampler.shared.sampleTint(context: ColorContext, accent: Color?)
```

## API Reference

### GlassTabBar Properties

| Property | Type | Description |
|----------|------|-------------|
| `tabs` | `[GlassTabItem]` | Array of tab items to display |
| `selectedTab` | `Binding<Int>` | Currently selected tab index |
| `onSelect` | `(Int) -> Void` | Callback when tab is selected |

### GlassTabItem Properties

| Property | Type | Description |
|----------|------|-------------|
| `icon` | `String` | SF Symbol name for unselected state |
| `selectedIcon` | `String` | SF Symbol name for selected state |
| `title` | `String` | Display name for the tab |
| `route` | `String` | Route identifier for navigation |

### ColorSampler Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `sampleTint` | `context: ColorContext, accent: Color?` | `Color` | Sample and return safe tint color |
| `getTintForMode` | `mode: NavigationMode` | `Color` | Get tint for specific navigation mode |
| `clearCache` | None | `Void` | Clear color cache |

## Integration

### Basic Usage

```swift
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Main content
            Group {
                switch selectedTab {
                case 0: MapView()
                case 1: SocializeView()
                case 2: HuntView()
                case 3: AdventuresView()
                case 4: SettingsView()
                default: MapView()
                }
            }
            
            // Navigation
            GlassTabBar(
                tabs: navigationTabs,
                selectedTab: $selectedTab,
                onSelect: { index in
                    selectedTab = index
                }
            )
        }
    }
}
```

### Feature Flag Integration

```swift
if FeatureFlags.shared.isEnabled(.liquidGlassNavV1) {
    GlassTabBar(tabs: tabs, selectedTab: $selectedTab, onSelect: onSelect)
} else {
    FloatingNavigationPill(selectedTab: $selectedTab, tabs: tabs)
}
```

### Custom Tab Configuration

```swift
let navigationTabs = [
    GlassTabItem(
        icon: "map",
        selectedIcon: "map.fill",
        title: "Map",
        route: "map"
    ),
    GlassTabItem(
        icon: "person.3",
        selectedIcon: "person.3.fill",
        title: "Socialize",
        route: "socialize"
    ),
    // ... more tabs
]
```

## Styling

### Design Tokens
The navigation system uses Shvil's design tokens for consistent styling:

- **Colors**: `DesignTokens.Brand.*`, `DesignTokens.Semantic.*`
- **Spacing**: `DesignTokens.Spacing.*`
- **Corner Radius**: `DesignTokens.CornerRadius.*`
- **Shadows**: `DesignTokens.Shadow.*`
- **Typography**: `DesignTokens.Typography.*`

### Customization
To customize the appearance, modify the design tokens or create custom variants:

```swift
// Custom tint color
let customTint = Color.blue

// Custom spacing
let customSpacing = DesignTokens.Spacing.lg * 1.5
```

## Accessibility

### VoiceOver Support
- Each tab has proper accessibility labels
- Selection state is announced
- Navigation order is logical

### Dynamic Type
- Text scales with system font size
- Icons maintain proper proportions
- Layout adapts to larger text

### RTL Support
- Layout mirrors correctly in RTL languages
- Animations work in both directions
- Text alignment adapts automatically

## Performance

### Optimization
- Animations use GPU-friendly properties
- Color sampling is throttled
- Memory usage is minimized

### Monitoring
- Frame rate monitoring
- Memory usage tracking
- Animation performance metrics

## Testing

### Unit Tests
```swift
func testTabSelection() {
    let tabBar = GlassTabBar(tabs: testTabs, selectedTab: .constant(0), onSelect: { _ in })
    // Test tab selection logic
}
```

### Snapshot Tests
```swift
func testNavigationAppearance() {
    let view = GlassTabBar(tabs: testTabs, selectedTab: .constant(0), onSelect: { _ in })
    assertSnapshot(matching: view, as: .image)
}
```

### Performance Tests
```swift
func testAnimationPerformance() {
    // Test 60fps during rapid tab switching
    // Measure memory usage
    // Verify smooth animations
}
```

## Troubleshooting

### Common Issues

1. **Animation Stuttering**
   - Check for main thread blocking
   - Verify GPU-friendly properties
   - Reduce animation complexity

2. **Color Contrast Issues**
   - Use ColorSampler for safe colors
   - Test with accessibility tools
   - Verify dark mode compatibility

3. **RTL Layout Problems**
   - Check layout direction
   - Verify animation mirroring
   - Test with Hebrew/Arabic text

### Debug Tools
- Xcode Animation Inspector
- Accessibility Inspector
- Performance Profiler
- Memory Graph Debugger

## Future Enhancements

### Planned Features
- Haptic feedback integration
- Gesture-based navigation
- Custom animation curves
- Advanced parallax effects

### Performance Improvements
- Metal-based rendering
- Precomputed animations
- Optimized blur effects
- Reduced memory footprint
