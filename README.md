# Shvil

**Lightweight, iOS-first navigation app that combines the clean polish of Apple Maps with the community feedback of Waze.**

## 🎯 MVP Vision

Shvil delivers a fast, reliable, and privacy-respecting navigation experience with just the essentials:

- **🚀 Instant Search & Recents** - Find places quickly with native search
- **🧭 Turn-by-Turn Directions** - Driving and walking modes with ETA and guidance
- **📱 Navigation HUD** - Distraction-free full-screen interface
- **📢 Community Reports** - Lightweight hazard and traffic reports
- **⭐ Saved Places** - Favorites with names and emojis
- **📶 Offline Fallback** - Cache route details for network drops
- **👤 Guest Mode** - Quick start without account required
- **⚙️ Privacy Controls** - Clear data management and settings

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ target device or simulator
- Supabase account (optional - guest mode available)

### Setup
1. **Clone and open:**
   ```bash
   git clone https://github.com/ilan-uzan/shvil.git
   cd shvil
   open shvil.xcodeproj
   ```

2. **Add Supabase package:**
   - File → Add Package Dependencies
   - URL: `https://github.com/supabase/supabase-swift`
   - Select "Supabase" when prompted

3. **Configure (optional):**
   ```bash
   source setup_env.sh  # Sets up Supabase connection
   ```

4. **Build and run:**
   - Select iOS Simulator
   - Press Cmd+R

## 📱 Features

### Core Navigation
- **Fast Search** - Native MapKit integration with < 500ms latency
- **Smart Directions** - Driving and walking modes with alternatives
- **Live Navigation** - Full-screen HUD with haptic feedback
- **Offline Support** - Cached routes continue without network

### Community Features
- **Lightweight Reports** - Quick hazard, traffic, and roadwork alerts
- **Auto-Expiry** - Reports automatically expire for relevance
- **Privacy-First** - Minimal data collection, local storage

### User Experience
- **Guest Mode** - Start immediately without account
- **Saved Places** - Custom favorites with emojis
- **Dark Mode** - System integration with manual override
- **Accessibility** - VoiceOver, Dynamic Type, high contrast

## 🏗️ Architecture

- **Platform**: iOS 17+, Swift 5.9+, SwiftUI
- **Maps**: MapKit (native Apple mapping)
- **Backend**: Supabase (optional authentication and sync)
- **Pattern**: MVVM + Repository
- **Privacy**: Local-first with optional cloud sync

## 🔒 Privacy & Security

- **Minimal Permissions** - Only location when needed
- **Local Storage** - Data stays on device by default
- **Optional Sync** - Cloud features require explicit opt-in
- **Transparent Policies** - Clear data usage and retention

## 📊 Performance Targets

- **Cold Start**: < 2 seconds
- **Search Latency**: < 500ms
- **Map Interactions**: 60fps
- **Memory Usage**: < 100MB

## 🛠️ Development

### Project Structure
```
shvil/
├── App/                    # App entry point
├── Features/              # Feature modules
│   ├── Authentication/    # Onboarding & auth
│   ├── Home/             # Main map view
│   ├── Search/           # Place search
│   ├── Navigation/       # Directions & HUD
│   ├── Reports/          # Community reports
│   ├── SavedPlaces/      # Favorites
│   └── Settings/         # Privacy & preferences
├── Shared/               # Shared components
│   ├── Models/           # Data models
│   ├── Services/         # Business logic
│   ├── UI/               # Reusable components
│   └── Utils/            # Utilities
└── Resources/            # Assets & localization
```

### Development Workflow
- **Branch Policy**: `feat/`, `fix/`, `chore/` prefixes
- **Commit Convention**: `feat:`, `fix:`, `chore:`, `docs:`
- **Code Quality**: SwiftLint, unit tests, accessibility
- **Security**: No sensitive data in git, environment variables

## 📋 Roadmap

### Phase 1: Foundation ✅
- Project scaffolding and architecture
- Supabase integration and security
- Core services and models

### Phase 2: Core Navigation 🚧
- Map integration and search
- Basic routing and directions
- Navigation HUD

### Phase 3: Community Features 📋
- Lightweight reporting system
- Saved places functionality
- Offline fallback

### Phase 4: Polish & Launch 📋
- Settings and privacy controls
- Performance optimization
- App Store preparation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`feat/your-feature`)
3. Make your changes with tests
4. Update documentation
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Shvil MVP: Fast, Simple, Private Navigation for iOS** 🗺️✨
