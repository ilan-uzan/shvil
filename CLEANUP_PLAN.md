# Cleanup Plan

## Phase 1: Design System Migration (P0)

### 1.1 Replace AppleColors with DesignTokens
- [ ] Find all `AppleColors` usage (200+ instances)
- [ ] Replace with `DesignTokens` equivalents
- [ ] Update all view files
- [ ] Update all component files
- [ ] Remove `AppleDesignSystem.swift` (deprecated)

### 1.2 Centralize Design Tokens
- [ ] Move all design tokens to `DesignSystem/Theme.swift`
- [ ] Create proper token categories (Brand, Semantic, Surface, Text, Glass)
- [ ] Add proper documentation
- [ ] Add accessibility variants

## Phase 2: Remove Duplicates (P0)

### 2.1 Model Definitions
- [ ] Keep `APIModels.swift` as canonical
- [ ] Remove duplicates from `AdventureKit.swift`
- [ ] Remove duplicates from `MapEngine.swift`
- [ ] Remove duplicates from `SafetyKit.swift`
- [ ] Update all references to use canonical models

### 2.2 Service Duplicates
- [ ] Consolidate similar services
- [ ] Remove unused service methods
- [ ] Update dependency injection

## Phase 3: Add Missing Features (P0)

### 3.1 Social Features
- [ ] Add Socialize tab to main navigation
- [ ] Create `SocialHubView.swift`
- [ ] Add friend management
- [ ] Add group creation and invites
- [ ] Add QR code sharing

### 3.2 Scavenger Hunt Features
- [ ] Add Hunt tab to main navigation
- [ ] Create `HuntHubView.swift`
- [ ] Add hunt creation flow
- [ ] Add hunt joining flow
- [ ] Add leaderboard system

## Phase 4: Fix Code Quality (P1)

### 4.1 Force Unwraps
- [ ] Find all force unwraps
- [ ] Replace with proper optional handling
- [ ] Add error handling where needed

### 4.2 Main Thread Issues
- [ ] Find main thread blocking code
- [ ] Move to background queues
- [ ] Add proper async/await patterns

### 4.3 Memory Leaks
- [ ] Find potential memory leaks
- [ ] Add proper cleanup
- [ ] Use weak references where needed

## Phase 5: Accessibility & i18n (P1)

### 5.1 Accessibility
- [ ] Add accessibility labels
- [ ] Add accessibility hints
- [ ] Ensure 44pt hit targets
- [ ] Add Dynamic Type support

### 5.2 Internationalization
- [ ] Replace hardcoded strings
- [ ] Add RTL support
- [ ] Test Hebrew layout

## Phase 6: Performance (P2)

### 6.1 Lazy Loading
- [ ] Implement pagination for lists
- [ ] Use `LazyVStack` for performance
- [ ] Add proper caching

### 6.2 Asset Optimization
- [ ] Remove unused assets
- [ ] Convert PNGs to PDFs/SF Symbols
- [ ] Optimize image sizes

## Phase 7: Testing (P1)

### 7.1 Re-enable Tests
- [ ] Uncomment test files
- [ ] Fix compilation issues
- [ ] Add basic test coverage

### 7.2 Add New Tests
- [ ] Unit tests for services
- [ ] Integration tests for API
- [ ] UI tests for critical flows

## Implementation Order

### Week 1: Foundation
1. Design system migration
2. Remove duplicates
3. Add basic social features

### Week 2: Features
1. Complete social features
2. Add scavenger hunt features
3. Fix critical code quality issues

### Week 3: Polish
1. Accessibility improvements
2. Performance optimization
3. Testing implementation

### Week 4: Final
1. Bug fixes
2. Documentation
3. Release preparation

## Success Metrics

### Code Quality
- [ ] 0 force unwraps
- [ ] 0 main thread blocking
- [ ] 0 memory leaks
- [ ] 100% DesignTokens usage

### Features
- [ ] Socialize tab functional
- [ ] Hunt tab functional
- [ ] All critical flows working

### Accessibility
- [ ] All elements have labels
- [ ] Dynamic Type support
- [ ] RTL layout working

### Performance
- [ ] 60fps on all screens
- [ ] < 2s app launch time
- [ ] < 100MB memory usage