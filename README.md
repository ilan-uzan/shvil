# Shvil

Apple-grade maps & navigation app built with SwiftUI, MapKit, and Supabase.

## Features

- 🗺️ **Fast place search** with autocomplete
- 🧭 **Turn-by-turn directions** (drive/walk)
- 📢 **Lightweight community reports** (hazard/traffic/roadwork)
- ⭐ **Favorites & recents**
- 📱 **Minimal offline fallback** (route cache + snapshot)
- 🎨 **iOS polish** (light/dark, haptics, smooth animations)
- 👤 **Account system** (Supabase) + optional guest mode
- ⚙️ **Settings** (privacy, data controls, opt-in analytics)

## Tech Stack

- **Platform**: iOS 17+, Swift 5.9+, SwiftUI
- **Maps**: MapKit (native)
- **Backend**: Supabase (Auth + Postgres + RLS)
- **Architecture**: MVVM + Repository Pattern

## Setup Instructions

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ target device or simulator
- Supabase account and project

### 1. Clone the Repository

```bash
git clone https://github.com/ilan-uzan/shvil.git
cd shvil
```

### 2. Configure Supabase

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from Settings → API
3. Update `shvil/Shared/Services/Config.swift`:

```swift
struct Supabase {
    static let projectURL = "https://your-project.supabase.co"
    static let anonKey = "your-anon-key-here"
}
```

### 3. Add Swift Package Dependencies

1. Open `shvil.xcodeproj` in Xcode
2. Go to File → Add Package Dependencies
3. Add: `https://github.com/supabase/supabase-swift`
4. Select "Supabase" when prompted

### 4. Build and Run

1. Select your target device or simulator
2. Press Cmd+R to build and run
3. Grant location permissions when prompted

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

## Development Workflow

### Branch Policy

- **main**: Production-ready code
- **feat/**: Feature development
- **fix/**: Bug fixes
- **chore/**: Maintenance tasks

### Commit Convention

```
feat: add new feature
fix: resolve bug
chore: update dependencies
docs: update documentation
```

### Pull Request Process

1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Create PR with template filled
5. Code review and approval
6. Merge to `main`

## Architecture

### MVVM Pattern

- **Models**: Data structures and business logic
- **Views**: SwiftUI views and UI components
- **ViewModels**: Business logic and state management
- **Services**: API clients and external integrations

### Core Services

- **SupabaseManager**: Authentication and database operations
- **LocationService**: User location tracking and permissions
- **MapService**: MapKit integration and route calculation
- **ReportService**: Community reports management

## Privacy & Security

- **Location Data**: Only used for navigation and map display
- **User Data**: Encrypted storage with RLS policies
- **Analytics**: Opt-in only, no PII collected
- **Permissions**: Clear, minimal requests with explanations

## Performance Targets

- **Cold Start**: < 2 seconds
- **Map Interactions**: 60fps
- **Search Latency**: < 500ms
- **Memory Usage**: < 100MB on older devices

## Testing

### Unit Tests

```bash
# Run unit tests
xcodebuild test -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests

```bash
# Run UI tests
xcodebuild test -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:shvilUITests
```

## Code Quality

### SwiftLint

```bash
# Install SwiftLint
brew install swiftlint

# Run linting
swiftlint lint
```

### Code Coverage

Target: 80% minimum coverage for business logic

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Update documentation
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using SwiftUI and Supabase**