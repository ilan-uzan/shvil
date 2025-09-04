# Liquid Glass Design System

The signature design language for Shvil, featuring translucent depth, animated micro-interactions, and a calming turquoise-to-aqua color palette with comprehensive accessibility support.

## 🎨 Color Palette

### Primary Colors
- **Icy Turquoise**: `#7DD3FC` (Light accent)
- **Deep Aqua**: `#0D9488` (Dark accent)
- **Paradisiaque Ocean**: Gradient from Icy Turquoise to Deep Aqua

### Surface Colors
- **Glass Surface**: Translucent neutral with subtle bluish tint
- **Glass-1**: Light elevation - `rgba(255, 255, 255, 0.1)`
- **Glass-2**: Medium elevation - `rgba(255, 255, 255, 0.15)`
- **Glass-3**: High elevation - `rgba(255, 255, 255, 0.2)`

### Text Colors
- **Primary Text**: High-contrast neutral `#1F2937`
- **Secondary Text**: Medium contrast `#6B7280`
- **Accent Text**: Only for alerts and highlights using accent colors

### High Contrast Colors (Accessibility)
- **High Contrast Primary Text**: `#000000`
- **High Contrast Secondary Text**: `#333333`
- **High Contrast Accent Text**: `#0066CC`
- **High Contrast Background**: `#FFFFFF`
- **High Contrast Glass Surface 1**: `rgba(0, 0, 0, 0.05)`
- **High Contrast Glass Surface 2**: `rgba(0, 0, 0, 0.1)`
- **High Contrast Glass Surface 3**: `rgba(0, 0, 0, 0.15)`

## 🔤 Typography

### Font Family
- **Primary**: SF Pro (System font with Dynamic Type support)
- **Fallback**: San Francisco (iOS system font)

### Type Scale (Dynamic Type Compatible)
- **Large Title**: `.largeTitle`, Bold (Navigation instructions)
- **Title XL**: `.title2`, Semibold (Screen titles)
- **Title**: `.title3`, Semibold (Section headers)
- **Headline**: `.headline` (Body emphasis)
- **Subheadline**: `.subheadline` (Secondary text)
- **Body**: `.body` (Primary text - minimum for legibility)
- **Body Medium**: `.body`, Medium weight (Emphasized body text)
- **Body Semibold**: `.body`, Semibold weight (Strong body text)
- **Footnote**: `.footnote` (Captions)
- **Caption**: `.caption` (Small text)
- **Caption Medium**: `.caption`, Medium weight (Emphasized small text)
- **Caption Small**: `.caption2` (Tiny text)

### Accessibility Features
- **Dynamic Type**: All text scales with system settings
- **High Contrast**: Enhanced contrast ratios for accessibility
- **RTL Support**: Right-to-left layout support for internationalization

## 🎭 Visual Effects

### Glass Morphism
- **Backdrop Blur**: 20-40pt radius
- **Overlay**: Subtle white/black overlay (10-20% opacity)
- **Noise**: Subtle texture overlay for depth
- **Inner Shadow**: Soft inner glow for depth
- **Outer Shadow**: Subtle drop shadow for elevation

### Elevation Tiers
- **Glass-1**: Light blur (20pt), minimal shadow
- **Glass-2**: Medium blur (30pt), moderate shadow
- **Glass-3**: Heavy blur (40pt), strong shadow

## 🎯 Interactive Elements

### Hit Targets
- **Minimum Size**: 48×48pt (Accessibility compliant)
- **Recommended Size**: 56×56pt for primary actions
- **Touch Feedback**: 160-220ms ease-out animation

### Ripple Effects
- **Scale**: Maximum 1.05x on tap
- **Duration**: 160-220ms ease-out
- **Color**: Accent color with 20% opacity
- **Shape**: Circular, expanding from touch point

### Micro-Interactions
- **Hover**: Subtle scale (1.02x) and glow increase
- **Press**: Scale down (0.98x) with ripple
- **Focus**: Glow outline with accent color
- **Loading**: Subtle pulse animation

## 🧩 Component Library

### Search Pill
```swift
// Floating search bar with glass effect and accessibility
struct SearchPill: View {
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LiquidGlassColors.accentDeepAqua)
            Text("Search places or address")
                .font(LiquidGlassTypography.body)
                .foregroundColor(LiquidGlassColors.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(elevation: .light)
        .cornerRadius(25)
        .onTapGesture { onTap() }
        .buttonAccessibility(
            label: "Search places or address",
            hint: "Double tap to open search"
        )
        .dynamicTypeSupport()
    }
}
```

### Glass Button
```swift
// Glass button with accessibility and haptic feedback
struct GlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(LiquidGlassTypography.bodySemibold)
                }
                Text(title)
                    .font(LiquidGlassTypography.bodySemibold)
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(style.background)
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .buttonAccessibility(
            label: title,
            hint: "Double tap to activate"
        )
        .dynamicTypeSupport()
    }
}
```

### Settings Row
```swift
// Settings row with glass effect and accessibility
struct SettingsRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(LiquidGlassColors.glassSurface1)
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .listItemAccessibility(
            label: "\(title), \(subtitle ?? "")",
            hint: "Double tap to open settings"
        )
        .dynamicTypeSupport()
    }
}
```

### Accessibility Extensions
```swift
// Comprehensive accessibility support
extension View {
    func shvilAccessibility(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = [],
        action: (() -> Void)? = nil
    ) -> some View
    
    func buttonAccessibility(
        label: String,
        hint: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View
    
    func listItemAccessibility(
        label: String,
        hint: String? = nil
    ) -> some View
    
    func dynamicTypeSupport() -> some View
    func rtlSupport() -> some View
}
```

## 🎬 Animation Guidelines

### Timing Functions
- **Micro-interactions**: `easeOut(duration: 0.1-0.2)`
- **Transitions**: `easeInOut(duration: 0.3-0.6)`
- **Page transitions**: `easeInOut(duration: 0.4-0.8)`

### Performance
- **Target FPS**: 120fps for smooth animations
- **Battery Safety**: Disable complex animations in Low Power Mode
- **Accessibility**: Respect Reduce Motion preferences

### Motion Principles
- **Subtle**: Animations should enhance, not distract
- **Purposeful**: Every animation should have a clear purpose
- **Consistent**: Use the same timing and easing across the app
- **Responsive**: Immediate feedback on user interaction

## 🌊 Route Visualization

### Route Line Styling
- **Gradient**: Turquoise to aqua with soft glow
- **Width**: 6-8pt for primary route, 4pt for alternatives
- **Glow**: 2-3pt outer glow with accent color
- **Animation**: Subtle pulse during active navigation

### Map Styling
- **Base**: Calm, desaturated colors
- **Traffic**: Subtle color overlays (red for congestion)
- **POIs**: Minimal, clean icons
- **User Location**: Pulsing dot with accent color

## 📱 Responsive Design

### Screen Sizes
- **iPhone SE**: Compact layout with smaller components
- **iPhone Standard**: Default layout
- **iPhone Plus/Max**: Expanded layout with more spacing
- **iPad**: Adaptive layout with sidebar navigation

### Dynamic Type
- **Support**: All text scales with system settings
- **Minimum**: 17pt for body text (accessibility)
- **Maximum**: No maximum limit (accessibility)

## 🎨 Dark Mode

### Color Adaptations
- **Glass Surfaces**: Darker base with lighter overlays
- **Text**: Inverted contrast ratios
- **Accents**: Slightly adjusted for dark backgrounds
- **Shadows**: Lighter shadows for dark mode

### Accessibility
- **Contrast**: WCAG AA compliance (4.5:1 ratio)
- **Color Blind**: Patterns and icons supplement color
- **High Contrast**: Enhanced contrast mode support

## 📱 Implemented Screens

### Core Navigation
- **Home/Map Screen**: Main navigation interface with search and map
- **Search View**: Comprehensive search functionality with results
- **Place Details**: Detailed place information with actions

### Adventure Features
- **Adventure Setup**: Configure mood, duration, and preferences
- **Adventure Sheet**: Main adventure interface with stops
- **Adventure Navigation**: Active navigation with progress tracking
- **Adventure Stop Detail**: Detailed stop information
- **Adventure Recap**: Post-adventure summary and sharing

### Social Features
- **Social Plans**: Create and manage group plans
- **Saved Places**: Personal place collections and management

### Settings & Privacy
- **Settings View**: App configuration and preferences
- **Privacy Settings**: Comprehensive privacy controls
- **Location Settings**: Location permission management
- **Notification Settings**: Notification preferences

## 🔧 Implementation Notes

### SwiftUI Effects
- Use `.glassEffect(elevation:)` for consistent glass morphism
- Combine with `.overlay()` for color tints
- Apply `.shadow()` for depth
- Use `.blur()` for backdrop effects

### Accessibility Implementation
- All components use semantic accessibility modifiers
- Dynamic Type support throughout the app
- RTL support for internationalization
- High contrast mode support
- VoiceOver compatibility

### Performance
- Avoid heavy Metal shaders
- Use system materials when possible
- Cache expensive visual effects
- Test on older devices

### Testing
- Verify on all supported screen sizes
- Test with Dynamic Type enabled
- Check Dark Mode appearance
- Validate accessibility compliance
- Test RTL layout support

## 🎯 Design Tokens

### Typography Tokens
```swift
LiquidGlassTypography.titleXL      // .title2, .semibold
LiquidGlassTypography.title        // .title3, .semibold
LiquidGlassTypography.body         // .body
LiquidGlassTypography.bodyMedium   // .body, .medium
LiquidGlassTypography.bodySemibold // .body, .semibold
LiquidGlassTypography.caption      // .caption
LiquidGlassTypography.captionMedium // .caption, .medium
LiquidGlassTypography.captionSmall // .caption2
```

### Color Tokens
```swift
LiquidGlassColors.primaryText      // High contrast text
LiquidGlassColors.secondaryText    // Medium contrast text
LiquidGlassColors.accentText       // Accent color text
LiquidGlassColors.glassSurface1    // Light glass surface
LiquidGlassColors.glassSurface2    // Medium glass surface
LiquidGlassColors.glassSurface3    // High glass surface
```

### Elevation Tokens
```swift
GlassElevation.light   // Light glass effect
GlassElevation.medium  // Medium glass effect
GlassElevation.high    // High glass effect
```

---

*This design system ensures a consistent, beautiful, and accessible experience across all Shvil interfaces with comprehensive Apple-grade polish.*
