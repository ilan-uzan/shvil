# QA Checklist

## Map Functionality

### Basic Map Rendering
- [ ] Map displays without yellow background or red X
- [ ] Map shows proper region (Israel by default)
- [ ] Map responds to touch gestures (pan, zoom, pinch)
- [ ] Map style changes work (Standard, Satellite, Hybrid, 3D, 2D)
- [ ] Map annotations display correctly (when enabled)

### Location Services
- [ ] Location permission prompt appears on first launch
- [ ] "Allow" permission shows user location on map
- [ ] "Don't Allow" permission shows proper error state
- [ ] Error state has "Open Settings" button that works
- [ ] Error state has "Continue with Demo" button that works
- [ ] Settings deep link opens iOS Settings app
- [ ] Map centers on user location when "Locate Me" is tapped

### Error States
- [ ] Location denied shows proper Liquid Glass error UI
- [ ] Error UI has clear messaging and actionable buttons
- [ ] Error UI matches app's design system
- [ ] Demo region displays when location is unavailable
- [ ] No yellow background or red X symbols

## Navigation

### Tab Navigation
- [ ] All tabs are accessible and functional
- [ ] Tab order: Map, Socialize, Hunt, Adventure, Settings
- [ ] Floating pill aligns with selected tab
- [ ] Tab transitions are smooth and responsive
- [ ] Tab icons display correctly in all states

### Map Controls
- [ ] Search bar opens keyboard and shows popular destinations
- [ ] Popular destination pills work (Home, Work, Gas, Groceries)
- [ ] Layers button shows map style options
- [ ] Locate Me button centers map on user location
- [ ] All controls have proper accessibility labels

## Permissions

### Location Permission
- [ ] First launch shows permission prompt
- [ ] Permission prompt has clear description
- [ ] "Allow" enables location features
- [ ] "Don't Allow" shows error state with options
- [ ] Settings deep link works for permission management
- [ ] App handles permission changes gracefully

### Other Permissions
- [ ] Microphone permission (if requested)
- [ ] Camera permission (if requested)
- [ ] Photo library permission (if requested)

## Simulator Testing

### Location Scenarios
- [ ] **Location: None** - Shows error state with demo region
- [ ] **Location: Apple** - Shows Apple Park location
- [ ] **Location: Freeway Drive** - Shows moving location
- [ ] **Location: Custom** - Shows custom coordinates

### Device Testing
- [ ] **Real Device** - Location services work properly
- [ ] **Permission Denied** - Error state displays correctly
- [ ] **Location Disabled** - App handles gracefully
- [ ] **Network Offline** - App works in demo mode

## Performance

### App Launch
- [ ] App launches within 3 seconds
- [ ] No crashes on startup
- [ ] All services initialize properly
- [ ] Memory usage is reasonable

### Map Performance
- [ ] Map renders smoothly
- [ ] Pan and zoom are responsive
- [ ] No memory leaks during map interaction
- [ ] Location updates don't cause performance issues

### UI Responsiveness
- [ ] All buttons respond to touch
- [ ] Animations are smooth (60fps)
- [ ] No UI freezing or lag
- [ ] Transitions are fluid

## Accessibility

### VoiceOver
- [ ] All interactive elements are accessible
- [ ] Map controls have proper labels
- [ ] Error states are announced
- [ ] Navigation is logical and intuitive

### Dynamic Type
- [ ] Text scales with system font size
- [ ] UI adapts to larger text sizes
- [ ] No text truncation issues
- [ ] Layout remains functional

### RTL Support
- [ ] UI mirrors correctly in Hebrew
- [ ] Text alignment is proper
- [ ] Icons and controls are positioned correctly
- [ ] Navigation flow works in RTL

## Dark Mode

### Visual Consistency
- [ ] All UI elements adapt to dark mode
- [ ] Text remains readable
- [ ] Icons and images are visible
- [ ] Map overlays work in dark mode

### Map Styles
- [ ] Satellite view works in dark mode
- [ ] Hybrid view is readable
- [ ] Standard view adapts properly
- [ ] 3D view renders correctly

## Error Handling

### Network Errors
- [ ] App works offline
- [ ] No crashes when network is unavailable
- [ ] Error messages are user-friendly
- [ ] App recovers when network returns

### Location Errors
- [ ] Handles location permission denied
- [ ] Handles location services disabled
- [ ] Handles location accuracy issues
- [ ] Provides clear error messages

### General Errors
- [ ] App doesn't crash on unexpected errors
- [ ] Error states are recoverable
- [ ] User can continue using app
- [ ] Errors are logged for debugging

## Regression Testing

### After Code Changes
- [ ] All previous tests still pass
- [ ] No new crashes introduced
- [ ] Performance hasn't degraded
- [ ] UI remains consistent

### Cross-Platform
- [ ] iPhone 15 Pro Max
- [ ] iPhone 15 Pro
- [ ] iPhone 15
- [ ] iPhone SE (3rd generation)
- [ ] iPad (if supported)

## Sign-off Criteria

### Must Pass
- [ ] Map renders without yellow background or red X
- [ ] Location permission handling works correctly
- [ ] Error states show proper UI
- [ ] App doesn't crash
- [ ] All basic functionality works

### Should Pass
- [ ] Performance is smooth
- [ ] Accessibility features work
- [ ] Dark mode is consistent
- [ ] RTL support is complete

### Nice to Have
- [ ] Advanced map features work
- [ ] Custom location testing
- [ ] Performance optimizations
- [ ] Additional error handling

## Test Environment

### Simulator
- **Device**: iPhone 16
- **iOS Version**: Latest
- **Location**: Various settings
- **Network**: WiFi and Cellular

### Physical Device
- **Device**: iPhone 15 Pro
- **iOS Version**: Latest
- **Location**: Real GPS
- **Network**: Cellular and WiFi

## Known Issues

### Current Limitations
- Map annotations are disabled to prevent rendering errors
- Some deprecated MapKit APIs are used (iOS 17+ warnings)
- Demo mode uses placeholder Supabase credentials

### Future Improvements
- Enable map annotations with proper data binding
- Update to latest MapKit APIs
- Add real Supabase backend integration
- Implement advanced location features
