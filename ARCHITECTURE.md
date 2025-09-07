# Shvil Architecture Documentation

**Version:** 2.0 (Liquid Glass Refactor)  
**Date:** December 2024  
**Status:** Comprehensive refactor in progress

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

### Current Module Structure

#### **AppCore** - Central State Management
- `AppState.swift` - Main app state and feature flags
- `DependencyContainer.swift` - Service dependency injection
- `Configuration.swift` - Environment and API configuration

#### **Core Services** - Business Logic
- `NavigationService.swift` - Turn-by-turn guidance
- `RoutingService.swift` - Multi-mode routing
- `AdventureService.swift` - AI-powered adventure generation
- `AuthenticationService.swift` - User authentication
- `GuidanceService.swift` - Voice and haptic feedback
- `LiveActivityService.swift` - Dynamic Island integration
- `OfflineManager.swift` - Offline data management
- `SafetyService.swift` - Emergency and safety features
- `SettingsService.swift` - User preferences

#### **Feature Modules** - Specialized Functionality
- `AdventureKit/` - Adventure generation and management
- `AIKit/` - OpenAI integration
- `LocationKit/` - Core Location wrapper
- `MapEngine/` - MapKit integration
- `RoutingEngine/` - Route calculation
- `ContextEngine/` - Contextual information
- `SocialKit/` - Social features
- `SafetyKit/` - Safety and emergency
- `PrivacyGuard/` - Privacy protection

#### **Shared Components** - Reusable UI
- `Design/AppleDesignSystem.swift` - Design tokens and components
- `Components/` - Reusable UI components
- `Services/` - Shared service utilities

## 🎨 Design System Architecture

### Current State (Pre-Refactor)
- **Mixed Systems**: Legacy `LiquidGlassColors` + new `AppleColors`
- **Inconsistent Usage**: Hard-coded values throughout components
- **No Token System**: Colors, spacing, typography scattered
- **Limited Components**: Basic buttons and cards only

### Target State (Liquid Glass 2.0)
- **Unified Token System**: Centralized design tokens
- **Component Library**: Comprehensive, reusable components
- **Accessibility First**: Built-in a11y and RTL support
- **Performance Optimized**: 60fps animations, lazy loading

## 🔄 Data Flow Architecture

### Authentication Flow
```
User Action → AuthenticationService → Supabase Auth → AppState → UI Update
```

### Adventure Generation Flow
```
User Input → AdventureService → AIKit → OpenAI API → Route Planning → UI Display
```

### Navigation Flow
```
Route Selection → RoutingService → MapEngine → NavigationService → GuidanceService
```

## 🚀 Performance Architecture

### Current Issues Identified
1. **Main Thread Blocking**: Heavy operations on UI thread
2. **Memory Leaks**: Retain cycles in service dependencies
3. **Inefficient Caching**: No proper cache invalidation
4. **Synchronous Operations**: Blocking network calls

### Target Performance Improvements
1. **Async/Await Pipeline**: All network operations off main thread
2. **Background Queues**: Heavy computations in background
3. **Smart Caching**: Multi-layer cache with invalidation
4. **Lazy Loading**: On-demand resource loading

## 🔐 Security Architecture

### Current Security Measures
- **API Key Protection**: Environment variable validation
- **Supabase RLS**: Row-level security policies
- **Privacy Guard**: Location data protection
- **Secure Storage**: Keychain for sensitive data

### Security Improvements Needed
- **Token Refresh**: Automatic auth token renewal
- **Certificate Pinning**: Enhanced network security
- **Data Encryption**: Local data encryption
- **Audit Logging**: Security event tracking

## 🌐 Backend Integration Architecture

### Supabase Integration
- **Authentication**: User management and sessions
- **Database**: PostgreSQL with RLS policies
- **Real-time**: Live location sharing
- **Storage**: File and image storage
- **Functions**: Server-side business logic

### API Contract
- **RESTful Endpoints**: Standard HTTP methods
- **GraphQL Queries**: Complex data fetching
- **WebSocket**: Real-time updates
- **File Upload**: Multipart form data

## 📱 Platform Architecture

### iOS-Specific Features
- **MapKit Integration**: Native map rendering
- **Core Location**: GPS and location services
- **Core Data**: Local data persistence
- **UserDefaults**: Settings and preferences
- **Keychain**: Secure credential storage

### Cross-Platform Considerations
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive programming
- **Async/Await**: Modern concurrency
- **Localization**: Multi-language support

## 🔧 Development Architecture

### Build System
- **Xcode Project**: Native iOS development
- **Swift Package Manager**: Dependency management
- **CI/CD Pipeline**: Automated testing and deployment
- **Code Quality**: SwiftLint and formatting

### Testing Strategy
- **Unit Tests**: Service layer testing
- **Integration Tests**: API and database testing
- **UI Tests**: User interaction testing
- **Snapshot Tests**: Visual regression testing

## 📊 Monitoring and Analytics

### Performance Monitoring
- **Launch Time**: App startup performance
- **Memory Usage**: RAM consumption tracking
- **Network Performance**: API response times
- **Crash Reporting**: Error tracking and analysis

### User Analytics
- **Feature Usage**: User interaction tracking
- **Performance Metrics**: App responsiveness
- **Error Rates**: Failure tracking
- **User Journey**: Flow analysis

## 🚧 Technical Debt and Improvements

### Identified Issues
1. **Dead Code**: Unused files and functions
2. **Duplicate Components**: Multiple implementations
3. **Inconsistent Patterns**: Mixed architectural approaches
4. **Missing Tests**: Insufficient test coverage
5. **Performance Bottlenecks**: Blocking operations

### Refactor Priorities
1. **Design System Unification**: Single source of truth
2. **Service Layer Cleanup**: Remove duplicates
3. **Performance Optimization**: Async/await migration
4. **Test Coverage**: Comprehensive testing
5. **Documentation**: Complete API documentation

## 🎯 Future Architecture Considerations

### Scalability
- **Microservices**: Service decomposition
- **Caching Strategy**: Multi-tier caching
- **Load Balancing**: Traffic distribution
- **Database Sharding**: Data partitioning

### Maintainability
- **Modular Design**: Loose coupling
- **Documentation**: Comprehensive docs
- **Code Standards**: Consistent patterns
- **Refactoring**: Regular cleanup

### Extensibility
- **Plugin Architecture**: Feature modules
- **API Versioning**: Backward compatibility
- **Feature Flags**: Gradual rollouts
- **A/B Testing**: Experimentation framework

---

## 📋 Architecture Decision Records (ADRs)

### ADR-001: SwiftUI + MVVM
**Decision**: Use SwiftUI with MVVM pattern for UI architecture
**Rationale**: Native iOS framework with clear separation of concerns
**Status**: Implemented

### ADR-002: Supabase Backend
**Decision**: Use Supabase for backend services
**Rationale**: Rapid development with built-in auth, database, and real-time features
**Status**: Implemented

### ADR-003: Liquid Glass Design System
**Decision**: Implement Apple-style Liquid Glass design system
**Rationale**: Modern, accessible, and performant UI with consistent branding
**Status**: In Progress

### ADR-004: Async/Await Migration
**Decision**: Migrate from Combine to async/await for concurrency
**Rationale**: Modern Swift concurrency with better performance and readability
**Status**: Planned

---

*This architecture document will be updated as the refactor progresses and new decisions are made.*
