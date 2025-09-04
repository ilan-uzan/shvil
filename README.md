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

## 🔐 Privacy & Security

Shvil Minimal is built with privacy and security as core principles:

### Privacy
- All social features are opt-in and temporary
- Location data stays on-device unless explicitly shared
- No tracking or analytics without explicit consent
- Clear privacy controls and kill-switches

### Security
- **API Key Protection**: All API keys are stored securely using environment variables
- **No Hardcoded Secrets**: No sensitive information is committed to version control
- **Secure Configuration**: Use `./setup_environment.sh` for secure key setup
- **Validation**: API keys are validated for proper format and security
- **Documentation**: See [SECURITY_GUIDE.md](SECURITY_GUIDE.md) for detailed security practices

### Quick Security Setup
```bash
# Secure setup (recommended)
./setup_environment.sh

# Or manual setup
cp environment.example .env
# Edit .env with your actual keys
chmod 600 .env
```

**⚠️ Important**: Never commit `.env` files or API keys to version control!

## 🔧 Troubleshooting

### Why Changes Don't Show Up

If you've made changes but don't see them in the running app, check these common issues:

#### 1. Repository & GitHub Status
- **Check branch status**: Ensure work is on a feature branch, not main
- **Verify PR status**: Check if PRs are failing CI or awaiting review
- **Confirm main tip**: Compare latest main commit to local
- **Check CI pipeline**: Ensure all CI checks are passing

#### 2. Local Build Issues
- **Clean build**: Run `xcodebuild clean` and rebuild
- **Delete DerivedData**: Clear Xcode cache
- **Check scheme/target**: Ensure building correct target (Debug/Release)
- **Verify dependencies**: Check SPM packages are resolved
- **Bump build number**: Force app reinstall

#### 3. CI Pipeline Problems
- **SwiftFormat issues**: Run `swiftformat .` to fix formatting
- **Security scan failures**: Check for hardcoded secrets or blocking TODO comments
- **Build failures**: Verify CI environment matches local
- **Test failures**: Run tests locally before pushing

#### 4. Runtime & Configuration
- **Feature flags**: Check if features are enabled in configuration
- **Environment variables**: Verify API keys are properly set
- **App state**: Check if app is running from correct build
- **Cache issues**: Clear app data and restart

#### 5. Quick Fixes
```bash
# Fix SwiftFormat issues
swiftformat .

# Clean and rebuild
xcodebuild clean
xcodebuild -project shvil.xcodeproj -scheme shvil build

# Check CI status
gh pr checks

# Verify local changes
git status
git log --oneline -5
```

### Common Issues
- **CI failing**: Usually SwiftFormat or security scan issues
- **Build errors**: Check for missing imports or syntax errors
- **App not updating**: Delete app and reinstall from Xcode
- **Changes not visible**: Ensure PRs are merged to main branch

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