# Project Scaffolding Plan

## Overview
This document outlines the project structure and setup for the Shvil iOS app following MVVM architecture with SwiftUI and Supabase integration.

## Project Structure

### 1. Xcode Project Organization

```
shvil.xcodeproj
├── App Target
│   ├── App/
│   │   ├── shvilApp.swift (main app entry)
│   │   ├── AppDelegate.swift (if needed)
│   │   └── Info.plist
│   ├── Features/
│   │   ├── Authentication/
│   │   ├── Home/
│   │   ├── Search/
│   │   ├── Navigation/
│   │   ├── Reports/
│   │   ├── SavedPlaces/
│   │   ├── Settings/
│   │   └── Offline/
│   ├── Shared/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── UI/
│   │   └── Utils/
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.strings
│       └── PrivacyInfo.xcprivacy
```

### 2. Module Groups Setup

#### App Group
- [ ] `shvilApp.swift` - Main app entry point
- [ ] `AppDelegate.swift` - App lifecycle management (if needed)
- [ ] `Info.plist` - App configuration and permissions

#### Features Groups
Each feature will have its own group with:
- [ ] `Views/` - SwiftUI views
- [ ] `ViewModels/` - MVVM view models
- [ ] `Models/` - Feature-specific models
- [ ] `Services/` - Feature-specific services

#### Shared Groups
- [ ] `Models/` - Shared data models
- [ ] `Services/` - Core services (Supabase, Location, Map)
- [ ] `UI/` - Reusable UI components
- [ ] `Utils/` - Utilities and extensions

### 3. Configuration Setup

#### Info.plist Configuration
```xml
<!-- Location Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Shvil needs location access to show your position on the map and provide navigation.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Shvil needs location access for turn-by-turn navigation and route guidance.</string>

<!-- Privacy Manifest -->
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryLocation</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>NSPrivacyAccessedAPITypeReasonLocation</string>
        </array>
    </dict>
</array>
```

#### Configuration Files
- [ ] `Config.swift` - App configuration constants
- [ ] `SupabaseConfig.swift` - Supabase-specific configuration
- [ ] `Environment.swift` - Environment-specific settings

### 4. Dependencies Setup

#### Swift Package Manager Dependencies
- [ ] **Supabase Swift** - Backend integration
  - URL: `https://github.com/supabase/supabase-swift`
  - Version: Latest stable

- [ ] **SwiftLint** - Code quality (development only)
  - URL: `https://github.com/realm/SwiftLint`
  - Version: Latest stable

#### Optional Dependencies (Future)
- [ ] **Lottie** - Animations (if needed)
- [ ] **KeychainAccess** - Secure storage
- [ ] **Combine** - Reactive programming (built-in)

### 5. Build Configuration

#### Build Settings
- [ ] **iOS Deployment Target**: 17.0
- [ ] **Swift Language Version**: 5.9
- [ ] **Code Signing**: Automatic
- [ ] **Bundle Identifier**: `com.ilan.uzan.shvil`

#### Build Configurations
- [ ] **Debug**: Development with debug symbols
- [ ] **Release**: Production optimized
- [ ] **Staging**: Pre-production testing (future)

### 6. Code Quality Setup

#### SwiftLint Configuration
```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - empty_string
  - force_unwrapping
  - implicitly_unwrapped_optional

included:
  - shvil

excluded:
  - Pods
  - .build

line_length:
  warning: 120
  error: 200

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500
```

#### Xcode Project Settings
- [ ] **Enable User Script Sandboxing**: Yes
- [ ] **Run Script Phase**: SwiftLint integration
- [ ] **Build Phases**: Proper ordering and dependencies

### 7. Testing Setup

#### Test Targets
- [ ] **shvilTests** - Unit tests
- [ ] **shvilUITests** - UI tests (future)

#### Test Structure
```
Tests/
├── Unit/
│   ├── Models/
│   ├── Services/
│   └── ViewModels/
├── Integration/
│   ├── Supabase/
│   └── Location/
└── Mocks/
    ├── SupabaseMock/
    └── LocationMock/
```

### 8. Documentation Setup

#### README Structure
- [ ] **Project Overview**
- [ ] **Architecture**
- [ ] **Setup Instructions**
- [ ] **Development Workflow**
- [ ] **Contributing Guidelines**

#### Code Documentation
- [ ] **Header comments** for all files
- [ ] **Function documentation** for public APIs
- [ ] **Architecture decision records** (ADRs)

### 9. Privacy & Security Setup

#### Privacy Manifest
- [ ] **PrivacyInfo.xcprivacy** - Required for App Store
- [ ] **Data collection disclosure**
- [ ] **Third-party SDK privacy**

#### Security Configuration
- [ ] **Keychain integration** for sensitive data
- [ ] **Certificate pinning** for API calls
- [ ] **Input validation** for user data

### 10. Performance Setup

#### Performance Monitoring
- [ ] **Build time tracking**
- [ ] **Memory usage monitoring**
- [ ] **App launch time measurement**

#### Optimization Targets
- [ ] **Cold start**: < 2 seconds
- [ ] **Memory usage**: < 100MB
- [ ] **Map interactions**: 60fps

## Implementation Checklist

### Phase 1: Basic Structure
- [ ] Create Xcode project with proper structure
- [ ] Set up module groups and folders
- [ ] Configure Info.plist with permissions
- [ ] Add Swift Package Manager dependencies
- [ ] Set up basic build configuration

### Phase 2: Code Quality
- [ ] Configure SwiftLint
- [ ] Set up build scripts
- [ ] Create test targets
- [ ] Add code documentation templates

### Phase 3: Configuration
- [ ] Set up environment configuration
- [ ] Create configuration files
- [ ] Set up privacy manifest
- [ ] Configure security settings

### Phase 4: Documentation
- [ ] Create comprehensive README
- [ ] Document architecture decisions
- [ ] Set up contribution guidelines
- [ ] Create development workflow docs

## Validation Criteria

### Project Structure Validation
- [ ] All module groups created and organized
- [ ] Dependencies properly configured
- [ ] Build settings optimized
- [ ] Test targets functional

### Code Quality Validation
- [ ] SwiftLint running without errors
- [ ] Build succeeds on clean project
- [ ] Tests can be run and pass
- [ ] Documentation is complete

### Configuration Validation
- [ ] App builds and runs on simulator
- [ ] Permissions properly requested
- [ ] Supabase connection testable
- [ ] Privacy manifest valid

## Next Steps

After scaffolding completion:
1. **Create first feature branch**: `feat/auth-onboarding`
2. **Implement authentication flow**
3. **Set up Supabase integration**
4. **Begin feature development cycle**

## Risk Mitigation

### Potential Issues
- **Xcode project corruption**: Regular backups and version control
- **Dependency conflicts**: Pin versions and test regularly
- **Build configuration errors**: Document all settings
- **Privacy compliance**: Regular privacy audits

### Mitigation Strategies
- **Automated testing**: CI/CD pipeline validation
- **Code reviews**: All changes reviewed
- **Documentation**: Comprehensive setup guides
- **Monitoring**: Performance and error tracking
