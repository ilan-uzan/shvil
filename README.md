# Shvil - Apple-Grade Navigation & Adventure App

Shvil is a comprehensive, production-ready navigation and adventure app built with SwiftUI, featuring AI-powered adventure generation, turn-by-turn guidance, and full localization support for English and Hebrew.

## 🚀 Features

### Core Navigation
- **Multi-mode routing** (driving, walking, cycling, public transport, mixed)
- **Turn-by-turn guidance** with voice and haptic feedback
- **Real-time traffic** and incident avoidance
- **Offline fallback** with cached map tiles and routes
- **Dynamic rerouting** when deviating from planned route

### AI-Powered Adventures
- **"Create Me an Adventure"** - AI-generated personalized itineraries
- **Contextual tour mode** with audio guidance and fun facts
- **Dynamic re-planning** when stops are closed or time runs late
- **Multiple themes and moods** (adventure, cultural, food, family, etc.)

### Social Features
- **Group trips** and collaborative planning
- **Real-time location sharing** with friends
- **Scavenger hunts** with photo verification
- **Social groups** and friend management

### Safety & Wellbeing
- **SOS shortcuts** with emergency contact integration
- **Location sharing** during emergencies
- **Safety incident reporting** and filtering
- **Night mode safety** with well-lit route suggestions

### Localization & Accessibility
- **Full EN/HE support** with RTL layout mirroring
- **VoiceOver compatibility** with comprehensive labels
- **Dynamic Type support** for text scaling
- **High contrast** color variants
- **Haptic feedback** for navigation cues

### Modern iOS Features
- **Liquid Glass design** with iOS 26 support
- **Glassmorphism fallback** for iOS 16-25
- **Live Activities** for Lock Screen updates
- **Dynamic Island integration** for ongoing navigation
- **Smooth animations** and transitions

## 🏗️ Architecture

### Core Services
- `NavigationService` - Turn-by-turn guidance with voice/haptics
- `RoutingService` - Multi-mode routing with optimization
- `SearchService` - Advanced search with autocomplete
- `AdventureService` - AI-powered adventure generation
- `SafetyService` - SOS and emergency features
- `OfflineManager` - Offline data and tile management
- `GuidanceService` - Voice and haptic guidance
- `LiveActivityService` - Dynamic Island and Live Activities

### Data Models
- `Route` - Comprehensive route representation
- `AdventurePlan` - AI-generated adventure structure
- `SearchResult` - Enhanced search results
- `SafetyReport` - Safety incident reporting
- `EmergencyContact` - Emergency contact management

### UI Components
- `GlassSearchBar` - Liquid Glass search component
- `GlassTabBar` - Floating navigation bar
- `GlassFAB` - Floating action button
- `GlassListRow` - List item component
- `GlassEmptyState` - Empty state component

## 🧪 Testing

### Test Structure
```
Tests/
├── UnitTests/
│   ├── SupabaseServiceTests.swift
│   ├── DesignSystemTests.swift
│   ├── APIModelsTests.swift
│   └── FeatureFlagsTests.swift
├── UITests/
│   ├── SearchViewUITests.swift
│   └── MapViewUITests.swift
└── TestConfiguration.swift
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project shvil.xcodeproj -scheme shvil -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -project shvil.xcodeproj -scheme shvilTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 🔧 Technical Implementation

### Dependencies
- **SwiftUI** - Modern UI framework
- **CoreLocation** - Location services
- **MapKit** - Map display and routing
- **Combine** - Reactive programming
- **AVFoundation** - Voice synthesis
- **CoreHaptics** - Haptic feedback
- **ActivityKit** - Live Activities
- **Supabase** - Backend as a Service

### Performance
- **App launch** ≤ 2.0s on iPhone 12+
- **Search keystroke** → suggestions ≤ 200ms
- **Route calculation** ≤ 2.5s
- **Map rendering** ≥ 55 FPS during pan/zoom
- **Battery drain** < 8%/hr during guidance

### Security
- **Minimal PII** collection
- **Secure storage** for tokens
- **TLS 1.2+** for network communication
- **Row Level Security** (RLS) in Supabase
- **Clear data deletion** flows

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+
- Supabase account (for backend)

### Installation
1. Clone the repository
2. Open `shvil.xcodeproj` in Xcode
3. Follow the [Configuration Guide](CONFIGURATION.md)
4. Build and run

### Quick Setup
1. **Supabase Setup**:
   - Create a new Supabase project
   - Run the SQL script from `supabase/setup.sql`
   - Add your project URL and anon key to Info.plist

2. **Environment Variables**:
   ```xml
   <key>SUPABASE_URL</key>
   <string>https://your-project-ref.supabase.co</string>
   <key>SUPABASE_ANON_KEY</key>
   <string>your-anon-key-here</string>
   ```

3. **Build and Run**:
   - Select your target device
   - Build and run the project

## 📱 User Experience

### Onboarding Flow
1. **Welcome screen** with app branding
2. **Language selection** (EN/HE)
3. **Theme selection** (Light/Dark/System)
4. **Permission requests** with clear explanations

### Search Experience
- **Real-time autocomplete** with mixed EN/HE support
- **Category filtering** and advanced search options
- **Recent searches** and popular suggestions
- **Voice search** capability

### Navigation Experience
- **Multiple route options** with optimization strategies
- **Turn-by-turn guidance** with voice and haptics
- **Dynamic Island integration** for iOS 16+
- **Offline fallback** support

### Adventure Experience
- **AI-generated personalized adventures**
- **Tour mode** with step-by-step guidance
- **Stop alternatives** and dynamic re-planning
- **Adventure history** and favorites

## 🎨 Design System

### Liquid Glass Design
- **iOS 26 Liquid Glass** materials for modern appearance
- **Glassmorphism fallback** for iOS 16-25
- **Consistent spacing** with 8-point grid system
- **Semantic colors** with proper contrast ratios
- **Typography scale** following Apple guidelines

### Components
- **GlassSearchBar** - Search input with glass effect
- **GlassTabBar** - Floating navigation with blur
- **GlassFAB** - Floating action button
- **GlassListRow** - List item with glass background
- **GlassEmptyState** - Empty state with illustration

## 🔄 CI/CD

### GitHub Actions
- **Automated testing** on every push
- **SwiftLint** code quality checks
- **Build verification** for multiple iOS versions
- **Release automation** for production builds

### Quality Gates
- All tests must pass
- Code coverage > 80%
- No SwiftLint warnings
- Successful build on latest Xcode

## 📊 Analytics & Monitoring

### Analytics Events
- User interactions and navigation
- Feature usage and adoption
- Performance metrics
- Error tracking and crash reporting

### Privacy
- **Minimal data collection**
- **User consent** for analytics
- **Data anonymization**
- **GDPR compliance**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Standards
- Follow Swift style guidelines
- Write comprehensive tests
- Update documentation
- Use conventional commits

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: [CONFIGURATION.md](CONFIGURATION.md)
- **Issues**: [GitHub Issues](https://github.com/ilan-uzan/shvil/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ilan-uzan/shvil/discussions)

## 🗺️ Roadmap

### Phase 1: Foundation (Current)
- [x] Core architecture and design system
- [x] Supabase integration
- [x] Basic navigation features
- [x] Testing framework

### Phase 2: Features
- [ ] AI adventure generation
- [ ] Social features and groups
- [ ] Scavenger hunt mode
- [ ] Advanced search

### Phase 3: Polish
- [ ] Performance optimization
- [ ] Accessibility enhancements
- [ ] Localization improvements
- [ ] UI/UX refinements

### Phase 4: Launch
- [ ] App Store submission
- [ ] Marketing materials
- [ ] User onboarding
- [ ] Community building

---

**Shvil** - Your ultimate navigation and adventure companion. 🗺️✨

*Built with ❤️ using SwiftUI and Supabase*
