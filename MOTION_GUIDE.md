# Shvil Motion Guide - Liquid Glass Navigation

## Animation Philosophy

The Liquid Glass navigation follows Apple's motion design principles with spring-based animations that feel natural and responsive. All animations are designed to maintain 60fps performance while providing delightful micro-interactions.

## Animation Timings

### Selection Animation
- **Response**: 0.35-0.45 seconds
- **Damping**: 0.75-0.85
- **Type**: Spring animation
- **Purpose**: Tab selection feedback

### Capsule Morphing
- **Response**: 0.35 seconds
- **Damping**: 0.8
- **Type**: Spring animation
- **Purpose**: Smooth capsule transition between tabs

### Tint Adaptation
- **Duration**: 160-220ms
- **Easing**: Ease in-out
- **Purpose**: Color transition when switching contexts

### Press Animations
- **Response**: 0.3 seconds
- **Damping**: 0.6-0.7
- **Type**: Spring animation
- **Purpose**: Button press feedback

## Animation Types

### 1. Spring Animations
Used for all interactive elements to provide natural, bouncy feedback:

```swift
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
```

### 2. Ease In-Out
Used for color transitions and non-interactive animations:

```swift
.animation(.easeInOut(duration: 0.2), value: dynamicTint)
```

### 3. Custom Spring
For specific micro-interactions:

```swift
.animation(.spring(response: 0.35, dampingFraction: 0.8), value: capsuleOffset)
```

## Animation Hierarchy

### Primary Animations (Immediate)
- Tab selection
- Capsule morphing
- Press feedback

### Secondary Animations (Delayed)
- Tint adaptation
- Icon scaling
- Text scaling

### Tertiary Animations (Background)
- Parallax effects
- Blur intensity changes

## Performance Guidelines

### GPU-Friendly Properties
- `opacity`
- `transform` (scale, rotation, translation)
- `color` (with caution)

### Avoid on Main Thread
- Complex path animations
- Heavy blur calculations
- Color sampling operations

### Throttling
- Color sampling: Route changes only
- Blur updates: Scroll-based throttling
- Animation state: Debounced updates

## Accessibility Considerations

### Reduce Motion
Respect `accessibilityReduceMotion` setting:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

// Use simpler animations when motion is reduced
if reduceMotion {
    .animation(.easeInOut(duration: 0.2), value: selectedTab)
} else {
    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
}
```

### VoiceOver
- Pause animations during VoiceOver navigation
- Provide audio feedback for state changes
- Ensure focus indicators are visible

## RTL Support

### Capsule Morphing
The liquid capsule morphing mirrors correctly in RTL:
- X-offset calculations account for RTL layout
- Animation directions are reversed
- Visual hierarchy is maintained

### Icon Animations
- Scale animations work in both directions
- Press feedback is consistent
- Focus indicators adapt to RTL

## Dark Mode Adaptations

### Highlight Opacities
- Light mode: Higher opacity for contrast
- Dark mode: Lower opacity to avoid glare

### Shadow Adjustments
- Light mode: Subtle shadows
- Dark mode: Enhanced shadows for depth

### Color Transitions
- Maintain contrast ratios
- Adapt to background changes
- Preserve brand identity

## Testing Animations

### Unit Tests
- Animation duration validation
- Spring parameter verification
- State transition testing

### Integration Tests
- Tab switching performance
- Capsule morphing accuracy
- Color adaptation timing

### Performance Tests
- 60fps maintenance
- Memory usage during animations
- Battery impact assessment

## Debugging

### Animation Inspector
Use Xcode's animation inspector to:
- Verify timing curves
- Check for dropped frames
- Identify performance bottlenecks

### Console Logging
```swift
#if DEBUG
print("Animation: \(animationName) - Duration: \(duration)s")
#endif
```

### Performance Monitoring
- Track animation frame rates
- Monitor memory usage
- Log animation completion times

## Best Practices

### 1. Consistent Timing
Use the same spring parameters for similar interactions across the app.

### 2. Meaningful Motion
Every animation should have a purpose and provide feedback to the user.

### 3. Performance First
Always prioritize 60fps over complex animations.

### 4. Accessibility
Ensure animations work for all users, including those with motion sensitivity.

### 5. Testing
Test animations on various devices and in different conditions.

## Future Enhancements

### Planned Features
- Haptic feedback integration
- Custom easing curves
- Advanced parallax effects
- Gesture-based animations

### Performance Improvements
- Metal-based animations
- Precomputed animation paths
- Optimized blur effects
- Reduced memory footprint
