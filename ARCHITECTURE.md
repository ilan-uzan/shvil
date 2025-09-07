# Shvil Architecture Analysis

## Current Architecture Overview

### Core Modules
- **AppCore/**: Configuration, AppState, DependencyContainer, FeatureFlags
- **Core/**: Models (APIModels), Services (AdventureService, AsyncRoutingService, etc.)
- **Features/**: UI Views (MapView, SearchView, AdventureSetupView, etc.)
- **Shared/**: Components, Design System, Services
- **AIKit/**: AI-powered adventure generation
- **MapEngine/**: Map functionality and routing
- **SafetyKit/**: Safety features and emergency services
- **SocialKit/**: Social features (currently minimal)
- **LocationKit/**: Location services
- **PrivacyGuard/**: Privacy controls
- **Persistence/**: Local data storage

### Design System
- **DesignSystem/Theme.swift**: Centralized design tokens (Liquid Glass 2.0)
- **DesignSystem/Components.swift**: Reusable UI components
- **AppleDesignSystem.swift**: Legacy system (DEPRECATED)

### Backend Integration
- **SupabaseService.swift**: Main backend integration
- **Auth**: Apple Sign-In + Email/Magic Link
- **Database**: PostgreSQL with RLS
- **Storage**: File uploads
- **Functions**: Edge functions for complex operations

## Proposed Architecture Improvements

### 1. Enhanced Social Features Module
```
SocialKit/
├── SocialHub/
│   ├── SocialHubView.swift
│   ├── FriendsListView.swift
│   ├── GroupInviteView.swift
│   └── QRCodeShareView.swift
├── ScavengerHunt/
│   ├── HuntHubView.swift
│   ├── CreateHuntView.swift
│   ├── JoinHuntView.swift
│   ├── HuntDetailView.swift
│   ├── LeaderboardView.swift
│   └── CheckpointSubmissionView.swift
└── Services/
    ├── SocialService.swift
    ├── HuntService.swift
    └── InviteService.swift
```

### 2. Improved Design System Structure
```
DesignSystem/
├── Theme.swift (Centralized tokens)
├── Components/
│   ├── Buttons/
│   ├── Cards/
│   ├── Sheets/
│   ├── Forms/
│   └── Navigation/
├── Tokens/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   └── Shadows.swift
└── Utilities/
    ├── ViewModifiers.swift
    ├── Extensions.swift
    └── Accessibility.swift
```

### 3. Enhanced Service Layer
```
Core/Services/
├── Network/
│   ├── APIClient.swift
│   ├── NetworkMonitor.swift
│   └── OfflineQueue.swift
├── Data/
│   ├── CacheManager.swift
│   ├── PersistenceManager.swift
│   └── SyncManager.swift
└── Business/
    ├── AdventureService.swift
    ├── SocialService.swift
    ├── HuntService.swift
    └── LocationService.swift
```

## Key Architectural Decisions

### 1. Feature Flags Strategy
- `SOCIALIZE_V1`: Enable social features
- `HUNT_V1`: Enable scavenger hunt features
- `APPLE_SIGNIN`: Enable Apple Sign-In (graceful degradation)

### 2. State Management
- Use `@StateObject` for service dependencies
- Centralized state in `AppState`
- Reactive updates with `@Published` properties

### 3. Navigation Architecture
- Tab-based navigation with floating action buttons
- Bottom sheet patterns for detail views
- Modal presentations for critical flows

### 4. Data Flow
- Unidirectional data flow
- Service layer handles all business logic
- Views are purely reactive

## Migration Strategy

### Phase 1: Design System Migration
1. Replace all `AppleColors` with `DesignTokens`
2. Update components to use centralized tokens
3. Implement proper glass effects

### Phase 2: Social Features
1. Add Socialize tab and hub
2. Implement basic friend management
3. Add group creation and invites

### Phase 3: Scavenger Hunt
1. Add Hunt tab and hub
2. Implement hunt creation flow
3. Add join hunt functionality
4. Build leaderboard system

### Phase 4: Backend Integration
1. Add typed models for all endpoints
2. Implement proper error handling
3. Add offline support and caching

## Performance Considerations

### 1. Lazy Loading
- Implement pagination for long lists
- Use `LazyVStack` for performance
- Cache frequently accessed data

### 2. Memory Management
- Use `@StateObject` appropriately
- Implement proper cleanup in `deinit`
- Monitor memory usage with `PerformanceMonitor`

### 3. Network Optimization
- Implement request deduplication
- Use background queues for heavy operations
- Add proper cancellation support

## Security Considerations

### 1. Authentication
- Graceful degradation for Apple Sign-In
- Secure token storage
- Proper session management

### 2. Data Protection
- Encrypt sensitive data
- Use RLS for database access
- Implement proper privacy controls

### 3. API Security
- Validate all inputs
- Implement rate limiting
- Use HTTPS for all communications