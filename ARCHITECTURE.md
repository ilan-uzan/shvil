# Shvil Architecture Overview

## Vision
Apple-grade maps & navigation app with fast place search, turn-by-turn directions, lightweight community reports, and iOS polish.

## Tech Stack
- **Platform**: iOS 17+, Swift 5.9+, SwiftUI
- **Maps**: MapKit (native)
- **Backend**: Supabase (Auth + Postgres + RLS)
- **Architecture**: MVVM + Repository Pattern

## Project Structure

```
shvil/
├── App/                    # App entry point, configuration
├── Features/              # Feature modules
│   ├── Authentication/    # Auth flows, onboarding
│   ├── Home/             # Main map view
│   ├── Search/           # Place search, autocomplete
│   ├── Navigation/       # Directions, turn-by-turn
│   ├── Reports/          # Community reports
│   ├── SavedPlaces/      # Favorites, recents
│   ├── Settings/         # App settings, privacy
│   └── Offline/          # Offline fallback
├── Shared/               # Shared components
│   ├── Models/           # Data models
│   ├── Services/         # Business logic, API clients
│   ├── UI/               # Reusable UI components
│   └── Utils/            # Utilities, extensions
└── Resources/            # Assets, localization
```

## Core Services

### SupabaseManager
- Authentication (email/pass + guest mode)
- Database operations with RLS
- Real-time subscriptions

### LocationService
- User location tracking
- Permission management
- Location accuracy optimization

### MapService
- MapKit integration
- Route calculation
- Offline caching

### ReportService
- Community reports CRUD
- Auto-expiry management
- Abuse prevention

## Data Flow

1. **Authentication**: Supabase Auth → User Profile → Local Storage
2. **Location**: Core Location → LocationService → Map Updates
3. **Search**: MKLocalSearch → Results → Recent Storage
4. **Navigation**: MKDirections → Route → Navigation HUD
5. **Reports**: User Input → Supabase → Real-time Updates

## Privacy & Security

- **RLS Policies**: User data isolation
- **Local Storage**: Sensitive data encrypted
- **Permissions**: Clear, minimal requests
- **Data Retention**: Configurable, user-controlled

## Performance Targets

- **Cold Start**: < 2 seconds
- **Map Interactions**: 60fps
- **Search Latency**: < 500ms
- **Memory Budget**: < 100MB on older devices

## Accessibility

- **Dynamic Type**: All text scales
- **VoiceOver**: Full navigation support
- **Touch Targets**: Minimum 44pt
- **Contrast**: WCAG AA compliance
