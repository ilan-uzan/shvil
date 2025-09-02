# Shvil Development Epics

## EPIC-0: Project Scaffolding & CI
**Branch**: `feat/bootstrap-project`
**Status**: 🚧 In Progress

### Stories
- [ ] Project structure setup
- [ ] CI/CD pipeline configuration
- [ ] Documentation framework
- [ ] Code quality tools setup

### Acceptance Criteria
- [ ] Xcode project with modules/groups (App, Features, Shared) planned
- [ ] Info.plist privacy keys listed (location permissions)
- [ ] Config approach documented (plist/xcconfig keys for Supabase URL/Key)
- [ ] CI plan written (build + tests on PR)
- [ ] README skeleton with architecture overview, run instructions, and branch policy

### Definition of Done
- [ ] PR template created
- [ ] Issue templates created
- [ ] Labels configured
- [ ] CODEOWNERS defined

---

## EPIC-1: Authentication & Onboarding
**Branch**: `feat/auth-onboarding`
**Status**: 📋 Planned

### Stories
- [ ] Welcome screens
- [ ] Supabase email/pass auth
- [ ] Guest mode
- [ ] Permission flows (location)

### Acceptance Criteria
- [ ] User can sign in/sign up, sign out; guest can continue without account
- [ ] Permission copy reviewed for clarity and privacy
- [ ] Error states defined (network/offline/auth)

### Test Plan
- [ ] Positive/negative sign-in cases
- [ ] Guest upgrade path described

### Risks
- Rate limits
- Anonymous to authenticated data linking (document strategy)

---

## EPIC-2: Home Map
**Branch**: `feat/home-map`
**Status**: 📋 Planned

### Stories
- [ ] User location dot
- [ ] Compass
- [ ] Recenter action
- [ ] Long-press to drop pin
- [ ] Place sheet actions

### Acceptance Criteria
- [ ] Map centers around user when requested
- [ ] Dropped pin triggers a details sheet with actions: Navigate, Save, Report
- [ ] Edge cases defined: denied location permissions, no GPS fix

### Performance
- [ ] Smooth panning baseline documented

---

## EPIC-3: Search (Places)
**Branch**: `feat/search-places`
**Status**: 📋 Planned

### Stories
- [ ] Autocomplete via native search
- [ ] Recents
- [ ] Region biasing

### Acceptance Criteria
- [ ] Query returns relevant results with latency target documented
- [ ] Recent searches stored locally; behavior defined for guest vs signed-in
- [ ] Empty & error states defined

### Privacy
- [ ] No PII stored beyond what's necessary
- [ ] Retention policy written

---

## EPIC-4: Directions (Drive/Walk)
**Branch**: `feat/directions`
**Status**: 📋 Planned

### Stories
- [ ] Route planning
- [ ] Steps list
- [ ] Alternative routes toggle
- [ ] Reroute on deviation (simple)

### Acceptance Criteria
- [ ] User sees ETA, distance, steps; mode switching is clear
- [ ] Reroute behavior defined (thresholds documented)
- [ ] Fallback behavior when network drops mid-route

### Safety
- [ ] Driving UI avoids distracting elements
- [ ] Copy reviewed

---

## EPIC-5: Navigation HUD
**Branch**: `feat/navigation-hud`
**Status**: 📋 Planned

### Stories
- [ ] Full-screen guidance
- [ ] Next maneuver display
- [ ] Lane/simple hints (if available)
- [ ] Ending trip

### Acceptance Criteria
- [ ] HUD readable in bright sunlight and in dark mode
- [ ] Haptics points identified (start/stop nav, reroute, report submitted)
- [ ] Accessibility: VoiceOver reads next instruction clearly

### Definition of Done
- [ ] End-trip summary UX outlined (time, distance)

---

## EPIC-6: Community Reports (Lightweight)
**Branch**: `feat/reports`
**Status**: 📋 Planned

### Stories
- [ ] Create report (hazard/traffic/roadwork)
- [ ] Short note
- [ ] TTL auto-expiry
- [ ] Map icons

### Acceptance Criteria
- [ ] Reports have category, optional note, coordinates, expiry policy documented
- [ ] Display rules when overlapping multiple reports (priority/stacking documented)
- [ ] Abuse mitigation noted (rate limit strategy, minimal PII)

### Data
- [ ] Public read, owner modify
- [ ] RLS policy described (no SQL here—just behavior)

---

## EPIC-7: Saved Places & Recents
**Branch**: `feat/saved-and-recents`
**Status**: 📋 Planned

### Stories
- [ ] Save place (name + emoji)
- [ ] List/edit
- [ ] Recent routes (local, opt-out)

### Acceptance Criteria
- [ ] Saved places persistence behavior for guest vs signed-in documented
- [ ] Recents stored locally with retention window; deletion UX defined

### Privacy
- [ ] Clear toggle to disable recents
- [ ] Copy reviewed

---

## EPIC-8: Offline Fallback (Basic)
**Branch**: `feat/offline-fallback`
**Status**: 📋 Planned

### Stories
- [ ] Cache active route details
- [ ] Static map snapshot
- [ ] Destination metadata

### Acceptance Criteria
- [ ] If connection drops during navigation, user still sees step list and a snapshot
- [ ] Cache invalidation policy documented (expiry, size limits)

### Non-goals
- [ ] Full offline tile packs (future)

---

## EPIC-9: Settings
**Branch**: `feat/settings`
**Status**: 📋 Planned

### Stories
- [ ] Privacy controls
- [ ] Data management (clear recents, sign out)
- [ ] Theme toggle
- [ ] About

### Acceptance Criteria
- [ ] Data clearing actions documented and reversible (confirmation UX)
- [ ] Theme follows system with optional override
- [ ] Link to privacy policy (placeholder)

---

## EPIC-10: App Polish
**Branch**: `feat/polish`
**Status**: 📋 Planned

### Stories
- [ ] Animations
- [ ] Micro-interactions
- [ ] Iconography
- [ ] Copy review
- [ ] Haptics tuning

### Acceptance Criteria
- [ ] Performance targets documented (e.g., 60fps on map interactions)
- [ ] Launch screen narrative and brand alignment described
- [ ] Empty state illustrations/copy decided

---

## EPIC-11: Telemetry (Opt-in, Post-MVP toggleable)
**Branch**: `feat/telemetry-optin`
**Status**: 📋 Planned

### Stories
- [ ] Anonymous, opt-in only
- [ ] Session, screen views
- [ ] Non-PII event counts

### Acceptance Criteria
- [ ] Default OFF; explicit opt-in copy written
- [ ] Data dictionary and retention policy documented

### Compliance
- [ ] No location trails or user identifiers stored without consent
