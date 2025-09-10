# Shvil App - Project Inventory

## Project Overview
**Product**: Shvil - Apple-grade navigation & adventures app for Israel
**Platform**: iOS (Xcode 16 beta)
**Tech Stack**: Swift + SwiftUI + Supabase

## Project Structure

### Core Application Files
- `ContentView.swift` - Main app interface with tab navigation and onboarding flow
- `MapView.swift` - Core map functionality with POI displays
- `Theme.swift` - Centralized design tokens and theme management
- `Components.swift` - Reusable UI components library
- `AppleGlassComponents.swift` - Liquid Glass design system components

### Architecture & Infrastructure
- `LocalizationManager.swift` - Multi-language support (English, Hebrew, French)
- `FeatureFlags.swift` - Feature flag management system
- `AuthenticationService.swift` - Supabase authentication integration
- `ErrorHandlingService.swift` - Centralized error handling
- `PerformanceOptimizer.swift` - Performance monitoring and optimization
- `PrivacyGuard.swift` - Privacy protection utilities
- `CodeCleanup.swift` - Code quality and cleanup utilities

### Design System
- `ScrollEffects.swift` - Custom scroll behaviors
- `FlexibleHeader.swift` - Adaptive header components

### Testing
- `APIModelsTests.swift` - API model validation tests

## Dependencies Overview

### Swift Package Manager Dependencies
**Status**: Current dependency manifest not visible - needs investigation

**Expected Dependencies:**
- Supabase Swift SDK (for backend integration)
- MapKit/MapKit JS (for map functionality)
- Combine (for reactive programming)

## Build Configuration

### Targets
- **Main App Target**: iOS deployment target TBD
- **Test Target**: Unit and integration tests

### Configuration Files
- Info.plist configuration
- Build settings and schemes
- Environment configuration

### Feature Flags
- Liquid Glass Navigation V1 (`liquidGlassNavV1`)
- Performance optimizations
- A11y enhancements
- Dark mode support

## Environment Configuration

### Required Environment Variables/Secrets
- Supabase URL
- Supabase Anonymous Key
- API Keys (location services, etc.)

### Privacy Requirements
- Location permissions (for navigation)
- Notification permissions (for adventure alerts)
- Analytics opt-out capabilities

## Current Issues Identified

### Compilation Errors
1. Missing `applePerformanceOptimized` view modifier
2. Missing `appleAccessibility` view modifier  
3. Missing `AppleCornerRadius` constants
4. Missing `AppleAnimations` constants

### Architecture Issues
- Non-MVP features present (SocializeView, HuntView) - need removal
- Incomplete design system implementation
- Missing accessibility modifiers
- Performance optimization extensions incomplete

### UX/UI Issues  
- Inconsistent spacing and typography
- Mixed design system usage
- Non-functional buttons and settings
- Dark mode implementation incomplete

## Next Steps
1. Fix compilation errors by implementing missing modifiers
2. Remove non-MVP features (social, hunt)
3. Complete design system implementation
4. Implement comprehensive accessibility support
5. Add proper error handling and loading states
6. Complete Supabase integration
7. Add comprehensive testing coverage

## Documentation Gaps
- API documentation
- Component usage guidelines  
- Accessibility guidelines
- Performance benchmarks
- Deployment procedures