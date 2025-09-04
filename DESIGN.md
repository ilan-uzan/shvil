# Liquid Glass Design System

The signature design language for Shvil Minimal, featuring translucent depth, animated micro-interactions, and a calming turquoise-to-aqua color palette.

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

## 🔤 Typography

### Font Family
- **Primary**: SF Pro (System font)
- **Fallback**: San Francisco (iOS system font)

### Type Scale
- **Large Title**: 34pt, Bold (Navigation instructions)
- **Title 1**: 28pt, Bold (Screen titles)
- **Title 2**: 22pt, Bold (Section headers)
- **Title 3**: 20pt, Semibold (Card titles)
- **Headline**: 17pt, Semibold (Body emphasis)
- **Body**: 17pt, Regular (Primary text - minimum for legibility)
- **Callout**: 16pt, Regular (Secondary text)
- **Subhead**: 15pt, Regular (Tertiary text)
- **Footnote**: 13pt, Regular (Captions)
- **Caption 1**: 12pt, Regular (Small text)
- **Caption 2**: 11pt, Regular (Tiny text)

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
// Floating search bar with glass effect
struct SearchPill: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            Text("Search places or address")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
```

### Floating Action Button (FAB)
```swift
// Circular FAB with glass effect
struct GlassFAB: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
        }
        .frame(width: 56, height: 56)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isPressed)
    }
}
```

### Instruction Card (Slab)
```swift
// Floating instruction card for navigation
struct InstructionSlab: View {
    let instruction: String
    let distance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(instruction)
                .font(.headline)
                .fontWeight(.semibold)
            Text(distance)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}
```

### Bottom Sheet
```swift
// Expandable bottom sheet with glass effect
struct GlassBottomSheet: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.secondary)
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            // Content
            if isExpanded {
                ExpandedContent()
            } else {
                CollapsedContent()
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -10)
    }
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

## 🔧 Implementation Notes

### SwiftUI Effects
- Use `.ultraThinMaterial` for glass effects
- Combine with `.overlay()` for color tints
- Apply `.shadow()` for depth
- Use `.blur()` for backdrop effects

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

---

*This design system ensures a consistent, beautiful, and accessible experience across all Shvil Minimal interfaces.*
