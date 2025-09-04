# Shvil - Apple-Grade Navigation & Trip Companion

Shvil is a comprehensive, production-ready navigation and trip companion app built with SwiftUI, featuring AI-powered adventure generation, turn-by-turn guidance, and full localization support for English and Hebrew.

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
- **Dynamic Island integration** for ongoing navigation
- **Live Activities** for Lock Screen updates
- **Glassmorphism design** with Apple-grade aesthetics
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
- `SearchPill` - Glassmorphism search component
- `RouteCard` - Route information display
- `OnboardingView` - User onboarding flow
- `NavigationLiveActivityView` - Live Activity widget

## 🧪 Testing

### Test Structure
```
Tests/
├── UnitTests/
│   ├── SearchServiceTests.swift
│   ├── NavigationServiceTests.swift
│   ├── AdventureServiceTests.swift
│   ├── LocalizationManagerTests.swift
│   └── SafetyServiceTests.swift
├── UITests/
│   ├── SearchViewUITests.swift
│   └── MapViewUITests.swift
├── TestConfiguration.swift
└── TestSuiteRunner.swift
```

### Running Tests
```swift
// Run all tests
TestSuiteRunner.shared.runAllTests()

// Run specific test category
TestSuiteRunner.shared.runTests(category: .unit)

// Generate test report
let report = TestSuiteRunner.shared.generateTestReport()
```

## 🧹 Code Quality

### Cleanup Tools
- **CodeCleanup** - Comprehensive code cleanup utility
- **Unused code removal** - Automatic detection and removal
- **Naming convention enforcement** - PascalCase for types, camelCase for methods
- **Import optimization** - Duplicate removal and alphabetical sorting
- **Dead code elimination** - Old commented code and unused assets

### Code Standards
- **SwiftUI best practices** - Modern, declarative UI
- **Combine integration** - Reactive programming patterns
- **Async/await** - Modern Swift concurrency
- **Protocol-oriented design** - Flexible and testable architecture
- **Dependency injection** - Centralized service management

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

## 🔧 Technical Implementation

### Dependencies
- **SwiftUI** - Modern UI framework
- **CoreLocation** - Location services
- **MapKit** - Map display and routing
- **Combine** - Reactive programming
- **AVFoundation** - Voice synthesis
- **CoreHaptics** - Haptic feedback
- **ActivityKit** - Live Activities

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
- **Certificate pinning** where possible
- **Clear data deletion** flows

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `shvil.xcodeproj` in Xcode
3. Configure API keys in `Configuration.swift`
4. Build and run

### Configuration
```swift
// Set your API keys
Configuration.openAIAPIKey = "your-openai-key"
Configuration.supabaseURL = "your-supabase-url"
Configuration.supabaseAnonKey = "your-supabase-anon-key"
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For support, email support@shvil.app or create an issue in the repository.

---

**Shvil** - Your ultimate navigation and trip companion. 🗺️✨
