# Shvil MVP Description

## Vision
Shvil is a lightweight, iOS-first navigation app that combines the clean polish of Apple Maps with the community feedback of Waze. The MVP focuses on delivering a fast, reliable, and privacy-respecting navigation experience with just the essentials.

## Core MVP Features

### 🚀 **Instant Search & Recents**
- Find places quickly with native search
- Keep track of recent destinations
- Fast autocomplete with region biasing
- Local storage for offline access

### 🧭 **Turn-by-Turn Directions**
- Driving and walking modes
- ETA, distance, and step-by-step guidance
- Alternative routes toggle
- Simple reroute on deviation

### 📱 **Navigation HUD**
- Distraction-free full-screen interface
- Next maneuver display
- Live reroutes
- Haptic feedback for key actions
- Readable in bright sunlight and dark mode

### 📢 **Community Reports (Lightweight)**
- Simple hazard, traffic, and roadwork reports
- Automatic expiry after short time
- Minimal PII collection
- Rate limiting for abuse prevention
- Map icons with priority stacking

### ⭐ **Saved Places**
- Add favorites with names and emojis
- Easy access to frequently visited locations
- Local storage with optional cloud sync
- Custom categories and notes

### 📶 **Offline Fallback**
- Cache route details and static snapshot
- Guidance continues if network drops
- Basic offline functionality
- Cache invalidation policy

### 👤 **Onboarding & Permissions**
- Quick start with guest mode
- Optional Supabase login for sync
- Clear location permission flows
- Privacy-first approach

### ⚙️ **Settings**
- Privacy controls and data clearing
- System/dark mode preferences
- Data retention management
- Opt-in analytics (future)

## Deliberate Exclusions (MVP)

### ❌ **Not in MVP:**
- CarPlay integration
- Full offline maps
- Social features and user profiles
- Advertisement system
- Complex route optimization
- Multi-modal transportation
- Advanced reporting features

### 🎯 **MVP Focus:**
- **Speed** - Fast app launch and navigation
- **Simplicity** - Clean, intuitive interface
- **Privacy** - Minimal data collection
- **Reliability** - Works consistently
- **iOS Polish** - Native feel and performance

## Technical Architecture

### **Platform & Tech Stack:**
- **iOS 17+** - Latest iOS features and performance
- **SwiftUI** - Modern, declarative UI framework
- **MapKit** - Native Apple mapping and navigation
- **Supabase** - Backend for authentication and sync
- **Core Location** - Location services and permissions

### **Architecture Principles:**
- **MVVM Pattern** - Clean separation of concerns
- **Repository Pattern** - Abstract data access
- **Dependency Injection** - Testable and modular
- **Privacy by Design** - Minimal data collection
- **Offline First** - Works without internet

## Success Metrics

### **Performance Targets:**
- **Cold Start**: < 2 seconds
- **Search Latency**: < 500ms
- **Map Interactions**: 60fps
- **Memory Usage**: < 100MB

### **User Experience:**
- **Intuitive Navigation** - No learning curve
- **Reliable Directions** - Accurate routing
- **Fast Search** - Quick place finding
- **Smooth Animations** - Native iOS feel

### **Privacy & Security:**
- **Minimal Permissions** - Only what's needed
- **Local Storage** - Data stays on device
- **Transparent Policies** - Clear data usage
- **User Control** - Easy data management

## Development Phases

### **Phase 1: Foundation** ✅
- Project scaffolding and architecture
- Supabase integration and security
- Core services and models
- Basic UI framework

### **Phase 2: Core Navigation** 🚧
- Map integration and location services
- Search functionality
- Basic routing and directions
- Navigation HUD

### **Phase 3: Community Features** 📋
- Lightweight reporting system
- Saved places functionality
- Offline fallback implementation

### **Phase 4: Polish & Launch** 📋
- Settings and privacy controls
- Onboarding flow
- Performance optimization
- App Store preparation

## Future Expansion

### **Post-MVP Features:**
- CarPlay integration
- Advanced offline capabilities
- Enhanced community features
- Multi-modal transportation
- Advanced analytics and insights

---

**Shvil MVP: Fast, Simple, Private Navigation for iOS** 🗺️✨
