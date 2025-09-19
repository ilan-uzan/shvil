import SwiftUI
import MapKit
import CoreLocation
import CoreHaptics
import AVFoundation
import Combine

/// Shvil Home/Map Page - Apple Maps inspired with clean hierarchy
/// iOS 26+ Liquid Glass, iOS 16-25 glassmorphism fallback
struct MapView: View {
    @StateObject private var locationService = DependencyContainer.shared.locationService
    @StateObject private var searchService = DependencyContainer.shared.searchService
    @StateObject private var adventureKit = DependencyContainer.shared.adventureKit
    @StateObject private var socialKit = DependencyContainer.shared.socialKit
    
    // MARK: - State Management
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var isListening = false
    @State private var selectedMode: MapMode = .explore
    @State private var mapStyle: MKMapType = .standard
    @State private var showingSearchResults = false
    @State private var showingMapModeMenu = false
    @State private var showingProfile = false
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var searchResults: [SearchResult] = []
    @State private var suggestionChips: [SuggestionChip] = []
    @State private var nearbyAdventures: [AdventurePlan] = []
    @State private var nearbyHunts: [ScavengerHunt] = []
    
    // Map Configuration
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Haptics
    @State private var hapticEngine: CHHapticEngine?
    
    // App Storage
    @AppStorage("lastMapStyle") private var lastMapStyle: Int = 0
    @AppStorage("lastSelectedMode") private var lastSelectedMode: Int = 1
    
    // MARK: - Computed Properties
    private var safeAreaTop: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    private var tabBarHeight: CGFloat {
        83 // Standard iOS tab bar height
    }
    
    var body: some View {
        ZStack {
            // MARK: - Map Background (Edge-to-Edge)
            mapView
                .ignoresSafeArea(.all)
            
            // MARK: - Top Chrome Group (Stacked)
            VStack(spacing: 8) {
                // Search Pill
                searchPill
                
                // Smart Suggestion Pills
                suggestionPillsScroll
                
                // Mode Toggle
                modeSegmentedControl
            }
            .padding(.horizontal, 16)
            .padding(.top, safeAreaTop + 8)
            .frame(maxWidth: .infinity, alignment: .top)
            
            // MARK: - Floating Map Controls (Right-Bottom)
            VStack(spacing: 12) {
                // Map Type Button (Top)
                mapTypeButton
                
                // Locate Me Button (Bottom)
                locateMeButton
            }
            .padding(.trailing, 16)
            .padding(.bottom, tabBarHeight + 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
            // MARK: - Search Results Overlay
            if showingSearchResults {
                searchResultsOverlay
            }
        }
        .environment(\.colorScheme, .light)
        .onAppear {
            setupInitialState()
        }
        .onChange(of: locationService.currentLocation) { location in
            updateMapRegion(with: location)
        }
        .onChange(of: region.center.latitude) { _ in
            loadNearbyContent()
        }
        .onChange(of: region.center.longitude) { _ in
            loadNearbyContent()
        }
        .onChange(of: selectedMode) { mode in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                updateModeContent()
            }
            triggerHaptic(.light)
            lastSelectedMode = mode.rawValue
        }
        .onChange(of: mapStyle) { style in
            withAnimation(.easeInOut(duration: 0.3)) {
                // Map style change animation
            }
            lastMapStyle = Int(style.rawValue)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
    
    // MARK: - Map Background
    private var mapView: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode)
        .mapStyle(mapStyleForCurrentStyle)
        .onTapGesture {
            dismissSearch()
        }
        .overlay(
            mapAnnotationsOverlay
        )
    }
    
    // MARK: - Search Pill
    private var searchPill: some View {
        HStack(spacing: 12) {
            // Shvil Logo (Left)
            Image(systemName: "star.fill")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(ShvilColors.accentPrimary)
                .frame(width: 20, height: 20)
            
            // Search Field (Center)
            TextField("Search places, adventures, hunts…", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(ShvilColors.textPrimary)
                .onSubmit {
                    performSearch()
                }
                .onTapGesture {
                    focusSearch()
                }
            
            // Right Icons (Mic + Profile)
            HStack(spacing: 16) {
                // Microphone
                Button(action: toggleVoiceSearch) {
                    Image(systemName: isListening ? "waveform" : "mic.fill")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(isListening ? ShvilColors.accentPrimary : ShvilColors.textSecondary)
                        .frame(width: 20, height: 20)
                        .scaleEffect(isListening ? 1.1 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isListening)
                }
                .accessibilityLabel(isListening ? "Voice search (listening)" : "Voice search")
                
                // Profile
                Button(action: openProfile) {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(ShvilColors.textSecondary)
                        .frame(width: 20, height: 20)
                }
                .accessibilityLabel("Open Profile")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 48)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            isSearchFocused ? ShvilColors.accentPrimary : Color.clear,
                            lineWidth: 1.5
                        )
                )
        )
        .scaleEffect(isSearchFocused ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSearchFocused)
    }
    
    // MARK: - Smart Suggestion Pills
    private var suggestionPillsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(suggestionChips) { chip in
                    SuggestionChipView(chip: chip) {
                        selectSuggestionChip(chip)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 36)
    }
    
    // MARK: - Mode Segmented Control
    private var modeSegmentedControl: some View {
        Picker("Mode", selection: $selectedMode) {
            Text("Navigate").tag(MapMode.navigate)
            Text("Explore").tag(MapMode.explore)
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(height: 36)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - Map Type Button
    private var mapTypeButton: some View {
        Button(action: {
            showingMapModeMenu = true
            triggerHaptic(.light)
        }) {
            Image(systemName: "map.fill")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(ShvilColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(ShvilColors.borderDivider.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Map style: \(mapStyleName)")
        .popover(isPresented: $showingMapModeMenu) {
            mapModeMenu
        }
    }
    
    // MARK: - Locate Me Button
    private var locateMeButton: some View {
        Button(action: {
            locateUser()
            triggerHaptic(.medium)
        }) {
            Image(systemName: "location.fill")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(ShvilColors.accentPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(
                                    userTrackingMode == .follow ? ShvilColors.accentPrimary : ShvilColors.accentPrimary.opacity(0.3),
                                    lineWidth: userTrackingMode == .follow ? 2 : 1
                                )
                        )
                )
                .shadow(
                    color: userTrackingMode == .follow ? ShvilColors.accentPrimary.opacity(0.3) : Color.black.opacity(0.08),
                    radius: userTrackingMode == .follow ? 12 : 8,
                    x: 0,
                    y: userTrackingMode == .follow ? 6 : 4
                )
                .scaleEffect(userTrackingMode == .follow ? 1.08 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: userTrackingMode == .follow)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Locate me")
    }
    
    // MARK: - Map Mode Menu
    private var mapModeMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(MapStyleOption.allCases, id: \.self) { option in
                Button(action: {
                    selectMapStyle(option)
                    showingMapModeMenu = false
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: option.icon)
                            .font(.title3)
                            .foregroundColor(ShvilColors.textPrimary)
                            .frame(width: 24, height: 24)
                        
                        Text(option.name)
                            .font(.subheadline)
                            .foregroundColor(ShvilColors.textPrimary)
                        
                        Spacer()
                        
                        if option.mapType == mapStyle {
                            Image(systemName: "checkmark")
                                .font(.subheadline)
                                .foregroundColor(ShvilColors.accentPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                if option != MapStyleOption.allCases.last {
                    Divider()
                        .background(ShvilColors.borderDivider)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ShvilColors.borderDivider, lineWidth: 0.5)
                )
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Search Results Overlay
    private var searchResultsOverlay: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Search Results")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ShvilColors.textPrimary)
                    
                    Spacer()
                    
                    Button("Clear") {
                        clearSearch()
                    }
                    .font(.subheadline)
                    .foregroundColor(ShvilColors.accentPrimary)
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(searchResults) { result in
                        SearchResultRow(result: result) {
                            selectSearchResult(result)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ShvilColors.borderDivider, lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .background(
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissSearch()
                }
        )
    }
    
    // MARK: - Map Annotations Overlay
    private var mapAnnotationsOverlay: some View {
        ZStack {
            // Adventure Pins (Explore mode)
            if selectedMode == .explore {
                ForEach(nearbyAdventures) { adventure in
                    if let coordinate = adventure.stops.first?.coordinate {
                        AdventurePin(adventure: adventure) {
                            selectAdventure(adventure)
                        }
                        .position(convertToMapPoint(coordinate))
                    }
                }
            }
            
            // Hunt Pins (Explore mode)
            if selectedMode == .explore {
                ForEach(nearbyHunts) { hunt in
                    if let firstCheckpoint = hunt.checkpoints.first {
                        HuntPin(hunt: hunt) {
                            selectHunt(hunt)
                        }
                        .position(convertToMapPoint(CLLocationCoordinate2D(
                            latitude: firstCheckpoint.latitude,
                            longitude: firstCheckpoint.longitude
                        )))
                    }
                }
            }
            
            // POI Pins (Navigate mode)
            if selectedMode == .navigate {
                ForEach(searchResults) { result in
                    POIPin(result: result) {
                        selectSearchResult(result)
                    }
                    .position(convertToMapPoint(result.coordinate))
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var mapStyleForCurrentStyle: MapStyle {
        switch mapStyle {
        case .standard:
            return .standard
        case .hybrid:
            return .hybrid
        case .satellite:
            return .standard // Fallback to standard for now
        case .satelliteFlyover:
            return .standard
        case .hybridFlyover:
            return .hybrid
        case .mutedStandard:
            return .standard
        @unknown default:
            return .standard
        }
    }
    
    private var mapStyleName: String {
        switch mapStyle {
        case .standard: return "Standard"
        case .hybrid: return "Hybrid"
        case .satellite: return "Satellite"
        case .satelliteFlyover: return "Satellite Flyover"
        case .hybridFlyover: return "Hybrid Flyover"
        case .mutedStandard: return "Muted Standard"
        @unknown default: return "Standard"
        }
    }
    
    // MARK: - Actions
    private func setupInitialState() {
        setupHaptics()
        loadSuggestionChips()
        loadStoredPreferences()
        loadNearbyContent()
    }
    
    private func setupHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptics not available: \(error)")
        }
    }
    
    private func loadSuggestionChips() {
        suggestionChips = [
            SuggestionChip(id: UUID(), title: "Coffee", icon: "cup.and.saucer", color: ShvilColors.markerFood),
            SuggestionChip(id: UUID(), title: "Parks", icon: "tree", color: ShvilColors.markerNature),
            SuggestionChip(id: UUID(), title: "Markets", icon: "cart", color: ShvilColors.markerCity),
            SuggestionChip(id: UUID(), title: "Museums", icon: "building.columns", color: ShvilColors.markerCulture),
            SuggestionChip(id: UUID(), title: "Restaurants", icon: "fork.knife", color: ShvilColors.markerFood),
            SuggestionChip(id: UUID(), title: "Gas", icon: "fuelpump", color: ShvilColors.markerCity),
            SuggestionChip(id: UUID(), title: "Hotels", icon: "bed.double", color: ShvilColors.markerCity)
        ]
    }
    
    private func loadStoredPreferences() {
        mapStyle = MKMapType(rawValue: UInt(lastMapStyle)) ?? .standard
        selectedMode = MapMode(rawValue: lastSelectedMode) ?? .explore
    }
    
    private func updateMapRegion(with location: CLLocation?) {
        guard let location = location else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = location.coordinate
        }
    }
    
    private func loadNearbyContent() {
        // Load adventures and hunts within current viewport
        Task {
            await loadAdventures()
            await loadHunts()
        }
    }
    
    private func loadAdventures() async {
        // This would typically call Supabase APIs
        // For now, we'll use the existing adventureKit data
        await MainActor.run {
            nearbyAdventures = adventureKit.activeAdventures
        }
    }
    
    private func loadHunts() async {
        // This would typically call Supabase APIs
        // For now, we'll use the existing socialKit data
        await MainActor.run {
            nearbyHunts = socialKit.activeHunts
        }
    }
    
    private func updateModeContent() {
        // Update content based on selected mode
        if selectedMode == .navigate {
            // Show navigation-focused content
            searchResults = []
        } else {
            // Show exploration-focused content
            loadNearbyContent()
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        Task {
            do {
                let results = try await searchService.performSearch(query: searchText)
                await MainActor.run {
                    searchResults = results
                    showingSearchResults = true
                }
            } catch {
                print("Search error: \(error)")
            }
        }
    }
    
    private func focusSearch() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isSearchFocused = true
        }
        triggerHaptic(.light)
    }
    
    private func dismissSearch() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isSearchFocused = false
            showingSearchResults = false
        }
    }
    
    private func clearSearch() {
        searchText = ""
        searchResults = []
        showingSearchResults = false
    }
    
    private func toggleVoiceSearch() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            isListening.toggle()
        }
        triggerHaptic(.light)
        
        if isListening {
            // Start voice recognition (stub)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isListening = false
                }
            }
        }
    }
    
    private func openProfile() {
        showingProfile = true
        triggerHaptic(.light)
    }
    
    private func selectSuggestionChip(_ chip: SuggestionChip) {
        searchText = chip.title
        performSearch()
        triggerHaptic(.light)
    }
    
    private func locateUser() {
        if let location = locationService.currentLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = location.coordinate
                userTrackingMode = .follow
            }
            triggerHaptic(.medium)
        }
    }
    
    private func selectMapStyle(_ option: MapStyleOption) {
        mapStyle = option.mapType
        triggerHaptic(.light)
    }
    
    private func selectSearchResult(_ result: SearchResult) {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.center = result.coordinate
            dismissSearch()
        }
        triggerHaptic(.light)
    }
    
    private func selectAdventure(_ adventure: AdventurePlan) {
        // Handle adventure selection
        triggerHaptic(.light)
    }
    
    private func selectHunt(_ hunt: ScavengerHunt) {
        // Handle hunt selection
        triggerHaptic(.light)
    }
    
    private func convertToMapPoint(_ coordinate: CLLocationCoordinate2D) -> CGPoint {
        // Simplified coordinate to point conversion
        let x = (coordinate.longitude - region.center.longitude) / region.span.longitudeDelta * 300 + 200
        let y = (region.center.latitude - coordinate.latitude) / region.span.latitudeDelta * 300 + 200
        return CGPoint(x: x, y: y)
    }
    
    private func triggerHaptic(_ intensity: MapHapticIntensity) {
        guard let engine = hapticEngine else { return }
        
        let hapticIntensity: Float
        switch intensity {
        case .light: hapticIntensity = 0.3
        case .medium: hapticIntensity = 0.6
        case .heavy: hapticIntensity = 0.9
        }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: hapticIntensity)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic feedback failed: \(error)")
        }
    }
}

// MARK: - Supporting Types

enum MapMode: Int, CaseIterable {
    case navigate = 0
    case explore = 1
}

enum MapHapticIntensity {
    case light
    case medium
    case heavy
}

enum MapStyleOption: CaseIterable {
    case standard
    case hybrid
    case satellite
    
    var name: String {
        switch self {
        case .standard: return "Standard"
        case .hybrid: return "Hybrid"
        case .satellite: return "Satellite"
        }
    }
    
    var icon: String {
        switch self {
        case .standard: return "map"
        case .hybrid: return "map.fill"
        case .satellite: return "globe"
        }
    }
    
    var mapType: MKMapType {
        switch self {
        case .standard: return .standard
        case .hybrid: return .hybrid
        case .satellite: return .satellite
        }
    }
}

struct SuggestionChip: Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let color: Color
}

// MARK: - Reusable Components

struct SuggestionChipView: View {
    let chip: SuggestionChip
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: chip.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(chip.color)
                
                Text(chip.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ShvilColors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(chip.color.opacity(0.25), lineWidth: 0.5)
                    )
            )
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Ensure 44pt tap area
        .accessibilityLabel("\(chip.title) suggestion")
    }
}

// MARK: - Map Annotations

struct AdventurePin: View {
    let adventure: AdventurePlan
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(ShvilColors.accentPrimary)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: ShvilColors.accentPrimary.opacity(0.4), radius: 6, x: 0, y: 3)
                
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HuntPin: View {
    let hunt: ScavengerHunt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Diamond()
                    .fill(ShvilColors.accentSecondary)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Diamond()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: ShvilColors.accentSecondary.opacity(0.4), radius: 4, x: 0, y: 2)
                
                Image(systemName: "target")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct POIPin: View {
    let result: SearchResult
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(ShvilColors.textSecondary)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                
                Image(systemName: "mappin")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(ShvilColors.accentPrimary)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(.subheadline)
                        .foregroundColor(ShvilColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(result.subtitle ?? "")
                        .font(.caption)
                        .foregroundColor(ShvilColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ShvilColors.textSecondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .foregroundColor(ShvilColors.textPrimary)
                
                Text("Profile screen coming soon")
                    .font(.body)
                    .foregroundColor(ShvilColors.textSecondary)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MapView()
}