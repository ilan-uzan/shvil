# Shvil Project Restructure Plan

**Date**: 2024-12-08  
**Target**: Xcode 26 Beta + Landmarks Liquid Glass Patterns  
**Status**: 🚀 IN PROGRESS

## 🎯 Restructure Goals

1. **Follow Landmarks Architecture**: Implement proven Landmarks Liquid Glass patterns
2. **Xcode 26 Beta Compatibility**: Ensure modern SwiftUI features work
3. **Clean Project Structure**: Organize files according to Apple best practices
4. **Supabase Integration**: Fix and optimize backend connections
5. **Performance Optimization**: Remove unnecessary files and optimize structure

## 📁 Current vs Target Structure

### Current Structure (Issues)
```
shvil/
├── Features/ (Mixed concerns)
├── Shared/ (Overloaded)
├── Core/ (Good but needs refinement)
├── AppCore/ (Good)
└── [Various scattered files]
```

### Target Structure (Landmarks-Inspired)
```
shvil/
├── App/                    # App entry point
├── Model/                  # Data models (like Landmarks)
├── Views/                  # All UI views (like Landmarks)
│   ├── Content/           # Main content views
│   ├── Components/        # Reusable components
│   └── Modifiers/         # View modifiers
├── Resources/             # Assets, localization, etc.
├── Services/              # Business logic services
├── Utilities/             # Helper functions and extensions
└── Tests/                 # Test files
```

## 🔄 Restructure Steps

### Phase 1: Create New Structure
1. Create new directory structure
2. Move files to appropriate locations
3. Update import statements
4. Fix compilation errors

### Phase 2: Implement Landmarks Patterns
1. Create Constants.swift (like Landmarks)
2. Implement flexible header patterns
3. Add readability overlays
4. Implement proper navigation patterns

### Phase 3: Fix Supabase Integration
1. Update configuration
2. Test database connections
3. Implement proper error handling
4. Add offline fallbacks

### Phase 4: Cleanup & Optimization
1. Remove unnecessary files
2. Optimize build settings
3. Add proper documentation
4. Test Xcode 26 beta compatibility

## 🎨 Landmarks Patterns to Implement

### 1. Constants Structure
```swift
struct Constants {
    // App-wide constants
    static let cornerRadius: CGFloat = 15.0
    static let leadingContentInset: CGFloat = 26.0
    static let standardPadding: CGFloat = 14.0
    
    // Grid constants
    static let collectionGridSpacing: CGFloat = 14.0
    static let collectionGridItemCornerRadius: CGFloat = 8.0
    
    // Map constants
    static let mapAspectRatio: CGFloat = 1.2
}
```

### 2. Flexible Header Pattern
```swift
extension ScrollView {
    func flexibleHeaderScrollView() -> some View {
        modifier(FlexibleHeaderScrollViewModifier())
    }
}

extension View {
    func flexibleHeaderContent() -> some View {
        modifier(FlexibleHeaderContentModifier())
    }
}
```

### 3. Readability Overlay
```swift
struct ReadabilityRoundedRectangle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .foregroundStyle(.clear)
            .background(
                LinearGradient(colors: [.black.opacity(0.8), .clear], 
                             startPoint: .bottom, endPoint: .center)
            )
    }
}
```

## 🗂️ File Organization Plan

### App/
- `ShvilApp.swift` (main app file)
- `AppDelegate.swift` (if needed)

### Model/
- `Adventure.swift`
- `Plan.swift`
- `User.swift`
- `SearchResult.swift`
- `Route.swift`
- `Constants.swift` (Landmarks-style)

### Views/
- `Content/`
  - `MapView.swift`
  - `OnboardingView.swift`
  - `LoginView.swift`
- `Components/`
  - `LiquidGlassButton.swift`
  - `LiquidGlassCard.swift`
  - `ReadabilityOverlay.swift`
  - `FlexibleHeader.swift`
- `Modifiers/`
  - `LiquidGlassModifiers.swift`
  - `AccessibilityModifiers.swift`

### Services/
- `LocationService.swift`
- `NavigationService.swift`
- `SearchService.swift`
- `SupabaseService.swift`
- `AdventureService.swift`

### Resources/
- `Assets.xcassets/`
- `Localization/`
- `Fonts/`

## 🔧 Implementation Details

### 1. Constants Integration
- Replace hardcoded values with Constants
- Follow Landmarks naming conventions
- Add device-specific constants

### 2. View Organization
- Group related views together
- Separate components from content
- Create proper view modifiers

### 3. Service Architecture
- Keep services focused and single-purpose
- Implement proper dependency injection
- Add error handling and fallbacks

### 4. Resource Management
- Organize assets properly
- Implement proper localization
- Add accessibility resources

## 🚀 Success Criteria

### Phase 1 Success
- [ ] New directory structure created
- [ ] All files moved to correct locations
- [ ] App compiles without errors
- [ ] No broken imports

### Phase 2 Success
- [ ] Landmarks patterns implemented
- [ ] Constants structure in place
- [ ] Flexible header working
- [ ] Readability overlays added

### Phase 3 Success
- [ ] Supabase connection working
- [ ] Database operations functional
- [ ] Error handling implemented
- [ ] Offline fallbacks working

### Phase 4 Success
- [ ] Unnecessary files removed
- [ ] Build optimized
- [ ] Xcode 26 beta compatible
- [ ] Documentation complete

## 📊 Expected Benefits

1. **Better Organization**: Clear separation of concerns
2. **Easier Maintenance**: Logical file structure
3. **Improved Performance**: Optimized build and runtime
4. **Better UX**: Landmarks-proven patterns
5. **Modern Compatibility**: Xcode 26 beta features

## 🎯 Next Actions

1. **Start Phase 1**: Create new directory structure
2. **Move Files**: Reorganize existing files
3. **Update Imports**: Fix all import statements
4. **Test Compilation**: Ensure everything works
5. **Implement Patterns**: Add Landmarks patterns

---

**Priority**: 🔴 HIGH - Foundation for all future development  
**Complexity**: MEDIUM - Requires careful file organization  
**Impact**: HIGH - Will significantly improve maintainability
