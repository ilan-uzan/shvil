# Shvil - Adventure Companion

A modern iOS app built with SwiftUI and Supabase, designed to help users discover and plan amazing adventures.

## 🚀 Features

### Core Features
- **Interactive Maps**: Explore locations with multiple map styles (2D, 3D, Satellite, Hybrid)
- **Adventure Planning**: Create and manage personalized adventure plans
- **Social Features**: Connect with friends and share adventures
- **Scavenger Hunts**: Participate in location-based scavenger hunts
- **Smart Navigation**: AI-powered route optimization and suggestions

### Design System
- **Liquid Glass UI**: Modern, translucent design with blur effects
- **Accessibility First**: Full VoiceOver, Dynamic Type, and RTL support
- **Performance Optimized**: Lazy loading, caching, and smooth animations
- **Dark Mode**: Complete dark mode support with adaptive colors

## 🏗️ Architecture

### Tech Stack
- **Frontend**: SwiftUI, Combine, CoreLocation, MapKit
- **Backend**: Supabase (Auth, Database, Storage, Functions)
- **Design**: Custom Liquid Glass design system
- **Testing**: XCTest, SwiftLint, Performance monitoring

### Project Structure
```
shvil/
├── AppCore/                 # App configuration and state
├── Core/                    # Core services and models
├── Features/                # Feature-specific views
├── Shared/                  # Shared components and utilities
│   ├── Components/          # Reusable UI components
│   ├── Design/              # Design system and tokens
│   └── Services/            # Shared services
└── Resources/               # Assets and localization
```

## 🎨 Design System

### Liquid Glass Components
- **GlassTabBar**: Floating navigation with glass effects
- **LiquidGlassButton**: Interactive buttons with haptic feedback
- **LiquidGlassCard**: Content cards with blur and shadows
- **LiquidGlassTextField**: Input fields with glass styling

### Design Tokens
- **Colors**: Brand, Semantic, Surface, Text, Stroke
- **Typography**: SF Pro with Dynamic Type support
- **Spacing**: 8pt grid system
- **Shadows**: Multiple elevation levels
- **Animations**: Spring-based with accessibility support

## ♿ Accessibility

### VoiceOver Support
- All interactive elements have proper labels
- Logical navigation order
- Custom actions for complex interactions
- Helpful hints and descriptions

### Dynamic Type
- Text scales from XS to XXXL
- Layout adapts to larger text sizes
- Maintains readability at all sizes
- 44pt minimum hit targets

### RTL Support
- Complete Hebrew language support
- Proper text alignment and layout
- Mirrored icons and navigation
- Cultural considerations

## 🚀 Performance

### Optimization Features
- **Lazy Loading**: Lists and images load on demand
- **Caching**: Intelligent memory and disk caching
- **Background Processing**: Main thread offloading
- **Memory Management**: Automatic cache cleanup
- **Frame Rate Monitoring**: Real-time performance tracking

### Performance Targets
- 60fps smooth scrolling
- <2s app launch time
- <100MB memory usage
- <1s screen transitions

## 🧪 Testing

### Test Coverage
- **Unit Tests**: Core services and utilities
- **Performance Tests**: Memory and CPU monitoring
- **Accessibility Tests**: VoiceOver and Dynamic Type
- **Integration Tests**: API and database operations

### Quality Gates
- 0 force unwraps in production code
- 0 main thread blocking operations
- 100% DesignTokens usage
- All accessibility requirements met

## 🛠️ Development

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Setup
1. Clone the repository
2. Open `shvil.xcodeproj` in Xcode
3. Configure Supabase credentials in `Configuration.swift`
4. Build and run

### Code Quality
- **SwiftLint**: Automated code style checking
- **Conventional Commits**: Standardized commit messages
- **PR Templates**: Structured pull request process
- **Code Reviews**: Required for all changes

## 📱 Screenshots

### Main Features
- Interactive map with multiple layers
- Adventure planning interface
- Social features and friend connections
- Scavenger hunt participation
- Settings and preferences

### Design System
- Liquid Glass navigation
- Accessible form controls
- Dark mode support
- RTL layout examples

## 🔧 Configuration

### Environment Variables
```swift
// Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

// Feature Flags
SOCIALIZE_V1=true
HUNT_V1=true
LIQUID_GLASS_NAV_V1=true
```

### Build Configurations
- **Debug**: Development with logging
- **Release**: Production with optimizations
- **Testing**: Test-specific configuration

## 📊 Analytics

### Performance Metrics
- App launch time
- Screen load times
- Memory usage
- Frame rate stability
- Cache hit rates

### User Experience
- Feature usage statistics
- Accessibility feature adoption
- Error rates and crash reports
- User feedback and ratings

## 🚀 Deployment

### CI/CD Pipeline
- **Automated Testing**: Unit, integration, and UI tests
- **Code Quality**: SwiftLint and security scanning
- **Performance**: Automated performance testing
- **Accessibility**: Automated accessibility validation
- **Deployment**: Automated TestFlight distribution

### Release Process
1. Feature development in feature branches
2. Pull request with required checks
3. Code review and approval
4. Merge to main branch
5. Automated deployment to TestFlight
6. Manual App Store submission

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request
5. Address review feedback
6. Merge after approval

### Code Standards
- Follow SwiftLint configuration
- Write comprehensive tests
- Document public APIs
- Use conventional commits
- Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Supabase**: Backend infrastructure
- **Apple**: SwiftUI and iOS frameworks
- **Design System**: Custom Liquid Glass implementation
- **Community**: Open source contributors and testers

## 📞 Support

For support, feature requests, or bug reports:
- Create an issue on GitHub
- Contact the development team
- Check the documentation wiki
- Join the community discussions

---

**Built with ❤️ using SwiftUI and Supabase**