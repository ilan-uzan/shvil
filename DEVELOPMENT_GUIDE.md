# Shvil Development Guide

## 🎯 Project Vision
Transform Shvil into a comprehensive navigation platform that combines the best of Apple Maps, Waze, and social connectivity with offline capabilities.

## 🌿 Feature Branch Strategy

### Current Branches

#### `main` - Production Ready
- ✅ Authentication & Onboarding
- ✅ Search & Discovery
- ✅ Core Navigation (Multi-modal)

#### `feat/navigation-core` - ✅ COMPLETED
**Status**: Ready for merge to main
- Multi-modal routing engine (Car, Bike, Walking, Transit, Truck)
- Turn-by-turn directions with MapKit
- Route options (tolls, highways, bike lanes, truck restrictions)
- Interactive map visualization
- Real-time traffic integration ready

#### `feat/social-platform` - 🚧 IN DEVELOPMENT
**Features**:
- User profiles and friend connections
- Location sharing and privacy controls
- Group navigation and meetup features
- Social recommendations and reviews
- Real-time friend location updates

#### `feat/offline-maps` - 📋 PLANNED
**Features**:
- Map tile caching and storage
- Offline routing algorithms
- Sync and update mechanisms
- Storage optimization
- Background map downloads

#### `feat/api-integration` - 📋 PLANNED
**Features**:
- Traffic data providers (Google, HERE, TomTom)
- Transit APIs (GTFS, real-time feeds)
- Gas price APIs (GasBuddy, AAA)
- Weather and incident data
- Real-time route optimization

#### `feat/recommendations` - 📋 PLANNED
**Features**:
- Machine learning place discovery
- Personalized suggestions
- Context-aware recommendations
- Integration with social data
- AI-powered route suggestions

#### `feat/advanced-ui` - 📋 PLANNED
**Features**:
- Beautiful map visualizations
- Custom map styles and themes
- Advanced gesture controls
- Accessibility enhancements
- Dark mode optimizations

## 🚀 Development Workflow

### Branch Management
```bash
# Create new feature branch
git checkout -b feat/feature-name

# Work on feature
# ... make changes ...

# Commit with conventional commits
git commit -m "feat: add new feature"

# Push to remote
git push origin feat/feature-name

# Create PR when ready
gh pr create --title "feat: Feature Name" --body "Description"
```

### Merge Strategy
1. **Feature Complete**: All tests pass, code reviewed
2. **Integration Test**: Test with main branch
3. **Performance Check**: Ensure < 500ms latency targets
4. **Accessibility**: VoiceOver and Dynamic Type support
5. **Merge to Main**: Squash and merge for clean history

### Code Standards
- **Swift 6 Compatible**: Use proper concurrency
- **Apple HIG**: Follow Human Interface Guidelines
- **MVVM Pattern**: Clean separation of concerns
- **Accessibility First**: VoiceOver, Dynamic Type, high contrast
- **Performance**: 60fps, <2s cold start, <500ms search

## 📱 Current Architecture

### Core Services
- **AuthenticationManager**: User sessions and onboarding
- **LocationService**: GPS and location permissions
- **SearchService**: MapKit-powered search with recents
- **NavigationService**: Multi-modal routing engine
- **SupabaseManager**: Backend and real-time features

### Transport Modes
- **Car**: Standard driving with traffic and toll options
- **Bike**: Cycling-optimized paths with bike lane preferences
- **Walking**: Pedestrian-friendly routes and accessibility
- **Transit**: Real-time bus, train, and subway integration
- **Truck**: Commercial vehicle routing with restrictions

### Advanced Features Ready
- **Route Options**: Avoid tolls, highways, ferries, prefer bike lanes
- **Truck Routing**: Height, weight, and hazmat restrictions
- **Gas Stations**: Real-time fuel prices along routes
- **Toll Information**: Cost-aware routing with alternatives
- **Traffic Incidents**: Real-time road conditions and alerts

## 🔧 Technical Stack

### Core Technologies
- **SwiftUI**: Modern iOS interface
- **MapKit**: Native Apple mapping
- **Core Location**: GPS and location services
- **Combine**: Reactive programming
- **Core Data**: Local data persistence

### External APIs (Ready for Integration)
- **Supabase**: Backend and real-time features
- **Google Maps API**: Enhanced mapping data
- **HERE API**: Traffic and routing
- **Transit APIs**: Public transportation data
- **Weather APIs**: Environmental conditions

### Performance Targets
- **Cold Start**: < 2 seconds
- **Search Latency**: < 500ms
- **Map Rendering**: 60fps
- **Memory Usage**: < 150MB
- **Battery Impact**: < 5% per hour

## 🔒 Privacy & Security

### Data Protection
- **Local-First**: Data stays on device by default
- **End-to-End Encryption**: Secure social communications
- **Privacy Controls**: Granular sharing permissions
- **GDPR Compliance**: European data protection

### Security Measures
- **OAuth 2.0**: Secure authentication
- **JWT Tokens**: Stateless session management
- **API Rate Limiting**: Prevent abuse
- **Input Validation**: Prevent injection attacks

## 📊 Success Metrics

### Performance Targets
- **Cold Start**: < 2 seconds
- **Search Latency**: < 500ms
- **Map Rendering**: 60fps
- **Memory Usage**: < 150MB
- **Battery Impact**: < 5% per hour

### User Engagement
- **Daily Active Users**: Growth tracking
- **Session Duration**: Usage patterns
- **Feature Adoption**: Social and offline usage
- **User Retention**: 7-day, 30-day retention

## 🎨 Design Principles

### Apple Human Interface Guidelines
- **Native iOS Feel**: Use system components
- **Accessibility First**: VoiceOver, Dynamic Type, high contrast
- **Privacy by Design**: Local-first, opt-in sharing
- **Performance**: 60fps, <2s cold start, <500ms search

### Key Flows
1. **Onboarding**: Quick setup with privacy controls
2. **Search & Discovery**: Find places with recommendations
3. **Multi-modal Planning**: Choose transport mode and preferences
4. **Navigation**: Turn-by-turn with real-time updates
5. **Social**: Connect and share with friends
6. **Offline**: Seamless offline experience

## 🚀 Next Steps

### Immediate (Week 1-2)
1. **Merge Navigation Core**: Integrate multi-modal routing
2. **Social Platform**: Start user profiles and friend connections
3. **API Integration**: Connect to real-time traffic data

### Short Term (Week 3-4)
1. **Offline Maps**: Implement map tile caching
2. **Recommendations**: Add AI-powered place discovery
3. **Advanced UI**: Enhance map visualizations

### Long Term (Month 2+)
1. **Performance Optimization**: Achieve all performance targets
2. **Advanced Features**: Weather, incidents, real-time updates
3. **Platform Expansion**: iPad, Apple Watch support

---

**Shvil: The Future of Navigation** 🗺️✨

*Built with Apple engineering standards and user privacy at its core.*
