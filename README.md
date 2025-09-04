# Shvil Minimal

A distraction-free navigation app with a signature Liquid Glass interface, built for iOS 17+ with SwiftUI and MapKit.

## 🌿 Product Vision

Shvil Minimal is a privacy-first navigation app that combines powerful A→B navigation with subtle social features. The app features a distinctive Liquid Glass aesthetic with translucent depth, animated micro-ripples, and a calming turquoise-to-aqua color palette.

### Key Features (MVP)

- **Fast, Clear Navigation**: Driving, walking, and cycling modes with fastest/safest route options
- **Powerful Search**: Location search with recent searches and distance-based ranking
- **Saved Places**: Collections for Home/Work/Favorites with quick access
- **Light Social**: Share ETA, optional Friends on Map, quick reactions
- **Offline Ready**: Tile/route caching for weak signal areas
- **Privacy First**: All social features opt-in & temporary

## 🎨 Liquid Glass Design

Every container is designed as living glass with:
- **Accents**: Icy turquoise → deep aqua gradient
- **Panels/Buttons**: Translucent depth with subtle specular highlights
- **Animations**: Micro-ripples on tap, subtle parallax on scroll
- **Route Lines**: Radiant gradient with soft glow
- **Motion**: 120fps-friendly, battery-safe animations

## 🛠️ Tech Stack

- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Maps**: MapKit
- **Location**: Core Location
- **Reactive**: Combine
- **Backend**: Supabase (Auth, DB, Realtime)
- **Target**: iOS 17+, iPhone first

## 🚀 Quick Start

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ Simulator or Device
- Supabase account (for social features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ilan-uzan/shvil.git
cd shvil
```

2. Open in Xcode:
```bash
open shvil.xcodeproj
```

3. Configure Supabase (optional for core features):
   - Create a new project at [supabase.com](https://supabase.com)
   - Copy your project URL and anon key
   - Update `Config.swift` with your credentials

4. Build and run:
   - Select your target device/simulator
   - Press `Cmd+R` to build and run

## 📱 Screenshots

*Screenshots will be added as features are implemented*

## 🏗️ Architecture

The app follows a modular architecture with clear separation of concerns:

- **AppCore**: App state, dependency injection, feature flags
- **LocationKit**: GPS permissions, location updates, background handling
- **MapKit+**: Search, geocoding, directions, annotations/overlays
- **RoutingEngine**: Mode selection, route options, ETA formatting, rerouting
- **Persistence**: Cached tiles, route summaries, saved places (local + cloud sync)
- **SocialKit**: Supabase Auth/Realtime for ETA sharing and friends presence
- **PrivacyGuard**: Share toggles, session timeouts, kill-switch
- **DesignSystem**: Liquid Glass components, tokens, motion

## 🧪 Testing

Run the test suite:
```bash
xcodebuild test -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 📚 Documentation

- [Design System](DESIGN.md) - Liquid Glass tokens, components, and motion rules
- [Social Features](SOCIAL_SPEC.md) - ETA sharing, friends presence, reactions
- [Architecture](ARCHITECTURE.md) - Module boundaries, data flow, error handling
- [Test Plan](TEST_PLAN.md) - Manual QA scenarios and acceptance criteria

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feat/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔐 Privacy

Shvil Minimal is built with privacy as a core principle:
- All social features are opt-in and temporary
- Location data stays on-device unless explicitly shared
- No tracking or analytics without explicit consent
- Clear privacy controls and kill-switches

## 🎯 Roadmap

- [x] Project setup and architecture
- [ ] Liquid Glass design system
- [ ] Core map and search functionality
- [ ] Turn-by-turn navigation
- [ ] Saved places management
- [ ] Social ETA sharing
- [ ] Friends on map (opt-in)
- [ ] Quick reactions
- [ ] Offline capabilities
- [ ] Privacy controls
- [ ] Analytics and telemetry
- [ ] Accessibility compliance

## 📞 Support

For support, email support@shvil.app or create an issue on GitHub.

---

Built with ❤️ for iOS