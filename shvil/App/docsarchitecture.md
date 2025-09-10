# Shvil App - Architecture Documentation

## System Overview

Shvil is an Apple-grade navigation and adventure app for Israel, built with Swift and SwiftUI, using Supabase as the backend service. The architecture follows Apple's recommended patterns with a focus on performance, accessibility, and user experience.

## Architecture Layers

```mermaid
graph TB
    UI[Presentation Layer - SwiftUI Views]
    VM[View Models & State Management]
    DL[Domain Layer - Business Logic]
    DT[Data Layer - Models & Services]
    NL[Network Layer - API & Supabase]
    SL[Storage Layer - Local & Remote]
    
    UI --> VM
    VM --> DL
    DL --> DT
    DT --> NL
    DT --> SL
    
    UI -.->|Direct Access| DT
    VM -.->|Direct Access| NL
```

## Presentation Layer (SwiftUI)

### Core Views
- **ContentView.swift**: Main app container with tab navigation
- **MapView.swift**: Primary map interface with POI and navigation
- **AdventuresView**: Adventure planning and management
- **SettingsView**: User preferences and configuration
- **OnboardingView**: First-time user experience

### Navigation Flow

```mermaid
graph LR
    Launch[App Launch] --> Onboard{Onboarding?}
    Onboard -->|No| Main[Main App]
    Onboard -->|Yes| OnboardFlow[Onboarding Flow]
    OnboardFlow --> Main
    Main --> Map[Map View]
    Main --> Adventure[Adventures]
    Main --> Settings[Settings]
    
    Map --> POI[POI Details]
    Map --> Navigation[Turn-by-Turn]
    Adventure --> Create[Adventure Setup]
    Adventure --> Active[Active Adventure]
```

## State Management Strategy

### ObservableObject Pattern
- **AppState**: Global application state
- **ThemeManager**: Design system and appearance
- **LocalizationManager**: Multi-language support
- **PerformanceOptimizer**: Performance monitoring

### Dependency Injection
```swift
class DependencyContainer {
    static let shared = DependencyContainer()
    
    // Core Services
    let appState: AppState
    let authenticationService: AuthenticationService
    let navigationService: NavigationService
    let searchService: SearchService
    let locationManager: LocationManager
    
    // Business Logic
    let adventureKit: AdventureKit
    let mapService: MapService
}
```

## Data Layer Architecture

### Models
- **User**: Authentication and profile data
- **AdventurePlan**: Adventure configurations and routes
- **SearchResult**: Location and POI data
- **MapAnnotation**: Map marker information

### Services Architecture

```mermaid
graph TB
    Auth[AuthenticationService] --> Supabase[Supabase Client]
    Location[LocationManager] --> CoreLocation[Core Location]
    Search[SearchService] --> MapKit[MapKit Search]
    Adventure[AdventureKit] --> LocalStorage[Core Data / UserDefaults]
    
    Supabase --> Database[(Supabase PostgreSQL)]
    Supabase --> Functions[Edge Functions]
    Supabase --> Storage[File Storage]
```

## Supabase Integration

### Database Schema
```mermaid
erDiagram
    users {
        uuid id PK
        string email
        string display_name
        timestamp created_at
        timestamp updated_at
    }
    
    adventures {
        uuid id PK
        uuid user_id FK
        string title
        text description
        json route_data
        string status
        timestamp created_at
    }
    
    places {
        uuid id PK
        string name
        text description
        geometry location
        json metadata
    }
    
    adventure_stops {
        uuid id PK
        uuid adventure_id FK
        uuid place_id FK
        integer order_index
        json custom_data
    }
    
    users ||--o{ adventures : creates
    adventures ||--o{ adventure_stops : contains
    places ||--o{ adventure_stops : referenced_in
```

### Authentication Flow
```mermaid
sequenceDiagram
    participant App
    participant Supabase
    participant User
    
    User->>App: Launch App
    App->>Supabase: Check Session
    alt Session Valid
        Supabase-->>App: User Data
        App-->>User: Main Interface
    else Session Invalid
        App-->>User: Login Screen
        User->>App: Login Credentials
        App->>Supabase: Authenticate
        Supabase-->>App: Session Token
        App-->>User: Main Interface
    end
```

### Data Synchronization
- **Online**: Real-time sync with Supabase
- **Offline**: Local storage with sync queue
- **Conflict Resolution**: Last-write-wins with timestamp comparison

## Feature Flag System

### Current Flags
```swift
enum Feature: String, CaseIterable {
    case liquidGlassNavV1 = "liquid_glass_nav_v1"
    case advancedRouting = "advanced_routing"
    case voiceGuide = "voice_guide"
    case socialSharing = "social_sharing" // DISABLED for MVP
    case huntMode = "hunt_mode" // DISABLED for MVP
}
```

### Flag Configuration
- **Development**: All experimental features enabled
- **Staging**: Selected beta features
- **Production**: Stable features only

## Error Handling Strategy

### Error Types
```swift
enum AppError: Error, Identifiable {
    case networkError(NetworkError)
    case authenticationError(AuthError)
    case locationError(LocationError)
    case dataCorruption(DataError)
    
    var id: String { "\(self)" }
    var userMessage: String { /* Localized messages */ }
    var recoveryAction: (() -> Void)? { /* Recovery logic */ }
}
```

### Error Boundaries
1. **View Level**: Local error states with retry actions
2. **Service Level**: Automatic retry with exponential backoff
3. **App Level**: Global error handler with crash reporting

## Performance Architecture

### Optimization Strategies
- **View Rendering**: DrawingGroup for complex views
- **Image Loading**: Lazy loading with placeholder states  
- **List Performance**: RecyclerView pattern for large datasets
- **Memory Management**: Weak references and proper cleanup

### Performance Monitoring
```swift
@MainActor
class PerformanceOptimizer: ObservableObject {
    @Published var frameRate: Double = 60.0
    @Published var memoryUsage: UInt64 = 0
    @Published var networkLatency: TimeInterval = 0
}
```

## Offline Support

### Cached Data
- **Map Tiles**: Essential map data for offline navigation  
- **User Adventures**: Local storage for offline access
- **POI Data**: Cached search results and place information
- **User Preferences**: Local settings and configuration

### Sync Strategy
```mermaid
graph LR
    Online[Online Mode] --> Cache[Update Cache]
    Offline[Offline Mode] --> Local[Use Local Data]
    Local --> Queue[Queue Changes]
    Queue --> Sync[Sync When Online]
    Sync --> Resolve[Resolve Conflicts]
```

## Security Architecture

### Data Protection
- **Local Storage**: Keychain for sensitive data
- **Network**: TLS 1.3 for all communications
- **Authentication**: JWT tokens with refresh mechanism
- **Privacy**: Location data anonymization

### Privacy Compliance
- **Location**: Precise location only when navigating
- **Analytics**: Opt-in telemetry with user consent
- **Data Retention**: Automatic cleanup of old data

## Testing Strategy

### Test Pyramid
```mermaid
graph TB
    Unit[Unit Tests - 70%] --> Integration[Integration Tests - 20%]
    Integration --> UI[UI Tests - 10%]
    
    Unit -.-> Models[Models & Services]
    Integration -.-> API[API Integration]
    UI -.-> Flow[User Flows]
```

### Test Coverage Goals
- **View Models**: 90% code coverage
- **Business Logic**: 95% code coverage  
- **API Integration**: 80% code coverage
- **Critical User Flows**: 100% path coverage

## Deployment Architecture

### Build Configuration
```mermaid
graph LR
    Dev[Development] --> Stage[Staging]
    Stage --> Prod[Production]
    
    Dev -.-> DevDB[(Dev Database)]
    Stage -.-> StageDB[(Staging Database)]
    Prod -.-> ProdDB[(Production Database)]
```

### Environment Variables
```swift
enum Environment {
    case development
    case staging  
    case production
    
    var supabaseURL: String { /* Environment URLs */ }
    var supabaseKey: String { /* Environment Keys */ }
    var analyticsEnabled: Bool { /* Analytics settings */ }
}
```

## Localization Architecture

### Supported Languages
- **English** (en): Primary language
- **Hebrew** (he): RTL support with mirrored layouts
- **French** (fr): Secondary European language

### RTL Support Strategy
```swift
extension View {
    func supportRTL() -> some View {
        environment(\.layoutDirection, LocalizationManager.shared.isRTL ? .rightToLeft : .leftToRight)
            .flipsForRightToLeftLayoutDirection(true)
    }
}
```

## Accessibility Architecture

### WCAG 2.1 Compliance
- **Level AA**: Minimum compliance target
- **Dynamic Type**: Full support for text scaling
- **VoiceOver**: Complete screen reader support
- **Reduce Motion**: Respect accessibility preferences

### Implementation Pattern
```swift
extension View {
    func makeAccessible(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
            .frame(minWidth: 44, minHeight: 44) // Minimum touch target
    }
}
```

## Monitoring and Analytics

### Performance Metrics
- Frame rate and rendering performance
- Memory usage and leak detection
- Network request latency and success rates
- Crash reporting and error tracking

### User Analytics  
- Screen view tracking
- Feature usage metrics
- User journey analysis
- A/B testing infrastructure

## Future Architecture Considerations

### Scalability Plans
- Modular architecture for feature splitting
- Microservice backend migration path
- Multi-platform support (iPadOS, macOS, watchOS)

### Technology Evolution
- SwiftUI performance improvements
- iOS 18+ feature adoption
- Apple Intelligence integration opportunities
- Enhanced privacy features