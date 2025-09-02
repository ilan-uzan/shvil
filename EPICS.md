# Shvil Development Epics - MVP Focus

## EPIC-1: Onboarding & Permissions
**Branch**: `feat/auth-onboarding`
**Status**: 🚧 In Progress

### Stories
- [ ] Quick start welcome screens
- [ ] Guest mode (no account required)
- [ ] Optional Supabase login for sync
- [ ] Clear location permission flows
- [ ] Privacy-first onboarding

### Acceptance Criteria
- [ ] User can start immediately as guest
- [ ] Optional account creation for cloud sync
- [ ] Clear, privacy-focused permission requests
- [ ] Smooth onboarding flow (< 30 seconds)
- [ ] Guest to authenticated upgrade path

### Test Plan
- [ ] Guest mode functionality
- [ ] Permission flow testing
- [ ] Account creation and login
- [ ] Data sync between guest and authenticated modes

### Risks
- Permission denial handling
- Guest data migration complexity
- Privacy compliance requirements

---

## EPIC-2: Instant Search & Recents
**Branch**: `feat/search-recents`
**Status**: 📋 Planned

### Stories
- [ ] Native MapKit search integration
- [ ] Fast autocomplete with region biasing
- [ ] Recent searches local storage
- [ ] Search result display and selection

### Acceptance Criteria
- [ ] Search latency < 500ms
- [ ] Relevant results with region biasing
- [ ] Recent searches stored locally
- [ ] Empty and error states handled
- [ ] Works offline for recent searches

### Performance
- [ ] Search response time measured
- [ ] Memory usage optimized
- [ ] Network efficiency verified

---

## EPIC-3: Turn-by-Turn Directions
**Branch**: `feat/directions`
**Status**: 📋 Planned

### Stories
- [ ] MapKit routing integration
- [ ] Driving and walking modes
- [ ] ETA and distance display
- [ ] Step-by-step guidance
- [ ] Alternative routes toggle

### Acceptance Criteria
- [ ] Accurate routing for both modes
- [ ] Clear ETA and distance information
- [ ] Step-by-step instructions
- [ ] Alternative route options
- [ ] Reroute on deviation

### Safety
- [ ] Driving UI avoids distractions
- [ ] Clear, readable instructions
- [ ] Haptic feedback for maneuvers

---

## EPIC-4: Navigation HUD
**Branch**: `feat/navigation-hud`
**Status**: 📋 Planned

### Stories
- [ ] Full-screen navigation interface
- [ ] Next maneuver display
- [ ] Live reroute handling
- [ ] Haptic feedback integration
- [ ] Dark/light mode optimization

### Acceptance Criteria
- [ ] Distraction-free interface
- [ ] Readable in bright sunlight
- [ ] Clear next maneuver display
- [ ] Smooth reroute transitions
- [ ] Haptic feedback for key actions

### Accessibility
- [ ] VoiceOver support
- [ ] Dynamic Type compatibility
- [ ] High contrast mode support

---

## EPIC-5: Community Reports (Lightweight)
**Branch**: `feat/community-reports`
**Status**: 📋 Planned

### Stories
- [ ] Simple report creation (hazard/traffic/roadwork)
- [ ] Automatic expiry system
- [ ] Map icon display
- [ ] Rate limiting for abuse prevention
- [ ] Minimal PII collection

### Acceptance Criteria
- [ ] Easy report creation (< 3 taps)
- [ ] Reports expire automatically
- [ ] Clear map visualization
- [ ] Abuse prevention measures
- [ ] Privacy-compliant data collection

### Data Management
- [ ] Public read, owner modify
- [ ] Automatic cleanup system
- [ ] Rate limiting implementation

---

## EPIC-6: Saved Places
**Branch**: `feat/saved-places`
**Status**: 📋 Planned

### Stories
- [ ] Add favorites with names and emojis
- [ ] Local storage with optional cloud sync
- [ ] Easy access to saved locations
- [ ] Custom categories and notes
- [ ] Guest vs authenticated storage

### Acceptance Criteria
- [ ] Quick save functionality
- [ ] Custom names and emojis
- [ ] Local storage for guests
- [ ] Cloud sync for authenticated users
- [ ] Easy access from main interface

### Privacy
- [ ] Clear data ownership
- [ ] Local-first approach
- [ ] Optional cloud sync

---

## EPIC-7: Offline Fallback
**Branch**: `feat/offline-fallback`
**Status**: 📋 Planned

### Stories
- [ ] Route detail caching
- [ ] Static map snapshot generation
- [ ] Offline guidance continuation
- [ ] Cache invalidation policy
- [ ] Network status detection

### Acceptance Criteria
- [ ] Guidance continues without network
- [ ] Cached route details available
- [ ] Static map snapshot for context
- [ ] Automatic cache cleanup
- [ ] Graceful degradation

### Performance
- [ ] Cache size management
- [ ] Storage efficiency
- [ ] Battery optimization

---

## EPIC-8: Settings & Privacy
**Branch**: `feat/settings-privacy`
**Status**: 📋 Planned

### Stories
- [ ] Privacy controls and data clearing
- [ ] System/dark mode preferences
- [ ] Data retention management
- [ ] Account management
- [ ] App preferences

### Acceptance Criteria
- [ ] Clear privacy controls
- [ ] Easy data clearing options
- [ ] Theme preference handling
- [ ] Account sign out functionality
- [ ] Transparent data policies

### Compliance
- [ ] Privacy policy compliance
- [ ] Data retention policies
- [ ] User consent management

---

## EPIC-9: App Polish & Launch
**Branch**: `feat/polish-launch`
**Status**: 📋 Planned

### Stories
- [ ] Performance optimization
- [ ] UI/UX polish and animations
- [ ] Error handling and edge cases
- [ ] App Store preparation
- [ ] Launch readiness

### Acceptance Criteria
- [ ] 60fps performance on target devices
- [ ] Smooth animations and transitions
- [ ] Comprehensive error handling
- [ ] App Store guidelines compliance
- [ ] Launch checklist complete

### Quality Assurance
- [ ] Performance benchmarks met
- [ ] Accessibility compliance
- [ ] Privacy audit passed
- [ ] User testing completed

---

## MVP Success Criteria

### **Core Functionality:**
- ✅ Fast, reliable navigation
- ✅ Intuitive search and directions
- ✅ Community reporting system
- ✅ Offline fallback capability
- ✅ Privacy-respecting design

### **Performance Targets:**
- ✅ Cold start < 2 seconds
- ✅ Search latency < 500ms
- ✅ 60fps map interactions
- ✅ < 100MB memory usage

### **User Experience:**
- ✅ No learning curve
- ✅ Native iOS feel
- ✅ Smooth animations
- ✅ Accessible design

---

**Shvil MVP: Fast, Simple, Private Navigation for iOS** 🗺️✨
