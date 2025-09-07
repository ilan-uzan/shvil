# Development Notes

## Simulator Setup

### Location Services Configuration
1. **Enable Location Services**:
   - Open Simulator
   - Go to Features → Location
   - Select any option except "None"

2. **Recommended Location Settings**:
   - **Apple**: For general testing
   - **Freeway Drive**: For navigation testing
   - **Custom Location**: For specific coordinate testing

3. **GPX Routes** (Advanced):
   - Create `.gpx` files for custom location paths
   - Place in `Resources/GPX/` directory
   - Select in Simulator → Features → Location → Custom Location

### Common Simulator Issues

#### "Location Permission Missing" Error
- **Cause**: Simulator location is set to "None"
- **Fix**: Change to any other location option in Simulator → Features → Location

#### Map Not Rendering
- **Cause**: SwiftUI Map rendering errors
- **Fix**: Ensure location services are enabled and app has proper permissions

#### Yellow Background with Red X
- **Cause**: Location permission denied or invalid map configuration
- **Fix**: Check location permissions and ensure proper map region setup

## Debugging

### Console Logs
Monitor these log patterns for issues:

```bash
# Check for SwiftUI rendering errors
xcrun simctl spawn "iPhone 16" log show --predicate 'process == "shvil"' --last 1m | grep -i "swiftui"

# Check for location permission issues
xcrun simctl spawn "iPhone 16" log show --predicate 'process == "shvil"' --last 1m | grep -i "location"

# Check for map rendering errors
xcrun simctl spawn "iPhone 16" log show --predicate 'process == "shvil"' --last 1m | grep -i "map"
```

### Common Error Patterns

#### SwiftUI Rendering Errors
```
[com.apple.SwiftUI:Invalid Configuration] Unable to render flattened version of PlatformViewRepresentableAdaptor
```
- **Cause**: Invalid MapKit configuration or data binding issues
- **Fix**: Check map region and annotation data

#### Location Permission Errors
```
Location Permission Missing: The app's Info.plist must contain an "NSLocationWhenInUseUsageDescription" key
```
- **Cause**: Missing location permission description
- **Fix**: Ensure Info.plist contains required permission keys

#### Network Errors
```
DNS Error: NoSuchRecord
```
- **Cause**: App trying to connect to non-existent Supabase URL
- **Fix**: App should handle demo mode gracefully (already implemented)

## Development Workflow

### Building and Testing
```bash
# Build the project
xcodebuild -project shvil.xcodeproj -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 16' build

# Install and launch
xcrun simctl install "iPhone 16" "path/to/app.app"
xcrun simctl launch "iPhone 16" com.ilan.uzan.shvil
```

### Code Changes
1. **Location Services**: Use `LocationManager` (unified service)
2. **Map Views**: Use `Map` with proper region binding
3. **Error States**: Use Liquid Glass design system
4. **Permissions**: Handle all authorization states gracefully

### Testing Checklist
- [ ] App launches without crashes
- [ ] Map renders properly in simulator
- [ ] Location permission prompt appears on first launch
- [ ] Error states show proper UI when location is denied
- [ ] Demo region displays when location is unavailable
- [ ] Settings deep link works for permission management

## Performance Considerations

### Memory Management
- Location updates happen on main thread
- Map region updates are debounced
- Services use lazy initialization

### Thread Safety
- All UI updates happen on main thread
- Location delegate methods use `@preconcurrency`
- Background tasks use proper queues

## Troubleshooting

### App Won't Launch
1. Check for compilation errors
2. Verify simulator is running
3. Check console logs for specific errors

### Map Not Showing
1. Verify location services are enabled
2. Check location permission status
3. Ensure map region is valid
4. Check for SwiftUI rendering errors

### Location Not Working
1. Verify Info.plist permissions
2. Check simulator location settings
3. Test on physical device
4. Check location manager initialization

### UI Issues
1. Verify Liquid Glass design tokens
2. Check for missing imports
3. Ensure proper view hierarchy
4. Test in both light and dark modes
