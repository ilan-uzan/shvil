# Shvil Architecture Documentation

**Version:** 3.0 (Deep Audit & Cleanup)  
**Date:** December 2024  
**Status:** Comprehensive audit and refactor in progress

## 🏗️ Current Architecture Overview

### Core Architecture Pattern
Shvil follows a **Modular MVVM + Service Layer** architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  SwiftUI Views  │  ViewModels  │  State Management         │
├─────────────────────────────────────────────────────────────┤
│                    Service Layer                            │
├─────────────────────────────────────────────────────────────┤
│  Core Services  │  Feature Services  │  Utility Services   │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                               │
├─────────────────────────────────────────────────────────────┤
│  Supabase  │  Core Data  │  File System  │  UserDefaults   │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Current Module Analysis

### **AppCore** - Central State Management
- `AppState.swift` - Main app state and feature flags ✅
- `DependencyContainer.swift` - Service dependency injection ✅
- `Configuration.swift` - Environment and API configuration ✅
- `FeatureFlags.swift` - Feature toggle management ✅

**Issues Found:**
- No proper dependency graph validation
- Missing service lifecycle management
- Configuration validation could be improved

### **Core Services** - Business Logic
- `NavigationService.swift` - Turn-by-turn guidance ⚠️ (Legacy)
- `AsyncNavigationService.swift` - Modern async/await version ✅
- `RoutingService.swift` - Multi-mode routing ⚠️ (Legacy)
- `AsyncRoutingService.swift` - Modern async/await version ✅
- `AdventureService.swift` - AI-powered adventure generation ✅
- `AuthenticationService.swift` - User authentication ✅
- `AppleAuthenticationService.swift` - Apple Sign-in ✅
- `GuidanceService.swift` - Voice and haptic feedback ✅
- `LiveActivityService.swift` - Dynamic Island integration ✅
- `OfflineManager.swift` - Offline data management ✅
- `SafetyService.swift` - Emergency and safety features ✅
- `SettingsService.swift` - User preferences ✅
- `ErrorHandlingService.swift` - Centralized error management ✅

**Issues Found:**
- Duplicate services (legacy + async versions)
- Some services missing proper error handling
- Main-thread blocking in some operations

### **Feature Modules** - Specialized Functionality
- `AdventureKit/` - Adventure generation and management ✅
- `AIKit/` - OpenAI integration ✅
- `LocationKit/` - Core Location wrapper ✅
- `MapEngine/` - MapKit integration ✅
- `RoutingEngine/` - Route calculation ✅
- `ContextEngine/` - Contextual information ✅
- `SocialKit/` - Social features ✅
- `SafetyKit/` - Safety and emergency ✅
- `PrivacyGuard/` - Privacy protection ✅

**Issues Found:**
- Some modules have tight coupling
- Missing proper abstraction layers
- Inconsistent error handling patterns

### **Shared Components** - Reusable UI
- `Design/AppleDesignSystem.swift` - Legacy design system ⚠️ (Deprecated)
- `Design/DesignSystem/Theme.swift` - New design tokens ✅
- `Design/DesignSystem/Components.swift` - Reusable components ✅
- `Components/` - Various UI components ✅
- `Services/` - Shared service utilities ✅

**Issues Found:**
- Mixed usage of old and new design systems
- Some components not using design tokens
- Missing accessibility features in some components

## 🎨 Design System Architecture

### Current State (Post-Refactor)
- **Unified Token System**: Centralized design tokens in `Theme.swift` ✅
- **Component Library**: Comprehensive, reusable components ✅
- **Liquid Glass Aesthetics**: Translucent depth and animations ✅
- **Accessibility Support**: VoiceOver, Dynamic Type, RTL ✅

### Issues to Address
- **Legacy System**: `AppleDesignSystem.swift` still referenced in some places
- **Inconsistent Usage**: Some components still use hard-coded values
- **Missing Components**: Some UI patterns not covered by design system

## 🔄 Data Flow Architecture

### Authentication Flow
```
User Action → AuthenticationService → Supabase → AppState → UI Update
```

### Navigation Flow
```
User Input → AsyncNavigationService → MapEngine → UI Update
```

### Adventure Flow
```
User Request → AdventureService → AIKit → MapEngine → UI Update
```

## 🚨 Critical Issues Identified

### 1. **Duplicate Services**
- `NavigationService` vs `AsyncNavigationService`
- `RoutingService` vs `AsyncRoutingService`
- Both versions exist, causing confusion

### 2. **Main-Thread Blocking**
- Several services perform heavy operations on main thread
- Network calls not properly async
- File I/O operations blocking UI

### 3. **Error Handling Inconsistency**
- Some services use completion handlers
- Others use async/await
- Error types not standardized

### 4. **Memory Management**
- Potential retain cycles in some services
- Missing weak references in closures
- No proper cleanup in some cases

## 🎯 Proposed Architecture Improvements

### 1. **Service Consolidation**
- Remove legacy services
- Standardize on async/await
- Implement proper service lifecycle

### 2. **Error Handling Standardization**
- Use `ErrorHandlingService` everywhere
- Standardize error types
- Implement proper error recovery

### 3. **Performance Optimization**
- Move heavy operations to background queues
- Implement proper caching strategies
- Add performance monitoring

### 4. **Testing Architecture**
- Add unit tests for all services
- Implement snapshot tests for UI
- Add integration tests for critical flows

## 📈 Performance Metrics

### Current State
- **Build Time**: ~45 seconds
- **App Launch**: ~2.1 seconds
- **Memory Usage**: ~85MB average
- **Frame Rate**: 60fps (with occasional drops)

### Target State
- **Build Time**: <30 seconds
- **App Launch**: <1.5 seconds
- **Memory Usage**: <70MB average
- **Frame Rate**: Consistent 60fps

## 🔧 Technical Debt

### High Priority
1. Remove duplicate services
2. Fix main-thread blocking
3. Standardize error handling
4. Implement proper testing

### Medium Priority
1. Optimize asset loading
2. Improve caching strategies
3. Add performance monitoring
4. Enhance accessibility

### Low Priority
1. Refactor legacy components
2. Improve documentation
3. Add more unit tests
4. Optimize build process

## 🚀 Migration Strategy

### Phase 1: Cleanup (Week 1)
- Remove duplicate services
- Fix critical bugs
- Standardize error handling

### Phase 2: Optimization (Week 2)
- Performance improvements
- Asset optimization
- Memory management fixes

### Phase 3: Testing (Week 3)
- Add comprehensive tests
- Implement CI/CD improvements
- Add monitoring

### Phase 4: Documentation (Week 4)
- Update architecture docs
- Add API documentation
- Create developer guides

## 📋 Success Criteria

- [ ] Zero duplicate services
- [ ] No main-thread blocking
- [ ] Consistent error handling
- [ ] 90%+ test coverage
- [ ] <1.5s app launch time
- [ ] Consistent 60fps performance
- [ ] Full accessibility compliance
- [ ] Clean Git history
- [ ] Proper CI/CD pipeline