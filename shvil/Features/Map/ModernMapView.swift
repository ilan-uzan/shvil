//
//  ModernMapView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct ModernMapView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var navigationService: NavigationService
    @EnvironmentObject private var searchService: SearchService
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    @State private var selectedTransportMode: TransportMode = .car
    @State private var showingTransportSelector = false
    @State private var showingSearch = false
    @State private var showingRouteOptions = false
    @State private var isNavigating = false
    @State private var searchText = ""
    @State private var showingLocationPermissionAlert = false
    
    var body: some View {
        ZStack {
            // Map
            ModernMapKitView(
                region: $region,
                selectedTransportMode: selectedTransportMode,
                isNavigating: isNavigating
            )
            .ignoresSafeArea()
            
            // Top Controls
            VStack {
                topControls
                Spacer()
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialLocation()
        }
        .onChange(of: locationService.currentLocation) { _, newLocation in
            if let location = newLocation {
                withAnimation(.easeInOut(duration: 1.0)) {
                    region.center = location.coordinate
                }
            }
        }
        .sheet(isPresented: $showingTransportSelector) {
            TransportModeSheet(selectedMode: $selectedTransportMode)
        }
        .sheet(isPresented: $showingSearch) {
            ModernSearchSheet(searchText: $searchText)
        }
        .sheet(isPresented: $showingRouteOptions) {
            RouteOptionsSheet()
        }
        .alert("Location Permission Required", isPresented: $showingLocationPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to use navigation features.")
        }
    }
    
    // MARK: - Top Controls
    private var topControls: some View {
        HStack {
            // Location Button
            Button(action: centerOnUserLocation) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Search Bar
            Button(action: { showingSearch = true }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                    
                    Text("Search places")
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .font(ShvilDesign.Typography.body)
                    
                    Spacer()
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
                .padding(.vertical, ShvilDesign.Spacing.sm)
                .background(.ultraThinMaterial)
                .cornerRadius(ShvilDesign.CornerRadius.pill)
            }
            .frame(maxWidth: 200)
            
            Spacer()
            
            // Route Options
            Button(action: { showingRouteOptions = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.top, ShvilDesign.Spacing.sm)
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: ShvilDesign.Spacing.md) {
            // Transport Mode Selector
            transportModeSelector
            
            // Navigation Controls
            if isNavigating {
                navigationControls
            } else {
                quickActions
            }
        }
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.bottom, ShvilDesign.Spacing.lg)
    }
    
    // MARK: - Transport Mode Selector
    private var transportModeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            transportModeButtons
        }
        .padding(.vertical, ShvilDesign.Spacing.sm)
        .background(.ultraThinMaterial)
        .cornerRadius(ShvilDesign.CornerRadius.large)
    }
    
    private var transportModeButtons: some View {
        HStack(spacing: ShvilDesign.Spacing.sm) {
            ForEach(TransportMode.allCases, id: \.self) { mode in
                transportModeButton(for: mode)
            }
        }
        .padding(.horizontal, ShvilDesign.Spacing.sm)
    }
    
    private func transportModeButton(for mode: TransportMode) -> some View {
        let isSelected = selectedTransportMode == mode
        let foregroundColor = isSelected ? Color.white : ShvilDesign.Colors.primary
        let backgroundColor = isSelected ? ShvilDesign.Colors.primary : Color.clear
        
        return Button(action: {
            withAnimation(ShvilDesign.Animation.spring) {
                selectedTransportMode = mode
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .foregroundColor(foregroundColor)
                
                Text(mode.shortName)
                    .font(ShvilDesign.Typography.caption2)
                    .foregroundColor(foregroundColor)
            }
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: ShvilDesign.CornerRadius.medium)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: ShvilDesign.CornerRadius.medium)
                            .stroke(.ultraThinMaterial, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Navigation Controls
    private var navigationControls: some View {
        HStack(spacing: ShvilDesign.Spacing.md) {
            // Stop Navigation
            Button(action: stopNavigation) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop")
                }
                .font(ShvilDesign.Typography.bodyEmphasized)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ShvilDesign.Spacing.md)
                .background(ShvilDesign.Colors.error)
                .cornerRadius(ShvilDesign.CornerRadius.medium)
            }
            
            // Route Info
            if let route = navigationService.currentRoute {
                VStack(alignment: .leading, spacing: 2) {
                    Text(route.formattedTime)
                        .font(ShvilDesign.Typography.headline)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                    
                    Text(route.formattedDistance)
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
                .padding(.vertical, ShvilDesign.Spacing.sm)
                .background(.ultraThinMaterial)
                .cornerRadius(ShvilDesign.CornerRadius.medium)
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: ShvilDesign.Spacing.md) {
            // Get Directions
            Button(action: { showingSearch = true }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Get Directions")
                }
                .font(ShvilDesign.Typography.bodyEmphasized)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ShvilDesign.Spacing.md)
                .background(ShvilDesign.Colors.primary)
                .cornerRadius(ShvilDesign.CornerRadius.medium)
            }
            
            // My Location
            Button(action: centerOnUserLocation) {
                Image(systemName: "location.circle.fill")
                    .font(.title)
                    .foregroundColor(ShvilDesign.Colors.primary)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Helper Methods
    private func setupInitialLocation() {
        if let location = locationService.currentLocation {
            region.center = location.coordinate
        } else if locationService.authorizationStatus == .denied {
            showingLocationPermissionAlert = true
        }
    }
    
    private func centerOnUserLocation() {
        guard let location = locationService.currentLocation else {
            if locationService.authorizationStatus == .denied {
                showingLocationPermissionAlert = true
            } else {
                locationService.requestLocationPermission()
            }
            return
        }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region.center = location.coordinate
        }
    }
    
    private func stopNavigation() {
        withAnimation(ShvilDesign.Animation.spring) {
            isNavigating = false
        }
        navigationService.stopNavigation()
    }
}

// MARK: - Modern MapKit View
struct ModernMapKitView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let selectedTransportMode: TransportMode
    let isNavigating: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.mapType = .standard
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.pointOfInterestFilter = .includingAll
        
        // Custom styling
        mapView.pointOfInterestFilter = .includingAll
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // Update map appearance based on transport mode
        switch selectedTransportMode {
        case .car:
            mapView.mapType = .standard
        case .walking:
            mapView.mapType = .standard
        case .transit:
            mapView.mapType = .standard
        case .bike:
            mapView.mapType = .standard
        case .truck:
            mapView.mapType = .standard
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ModernMapKitView
        
        init(_ parent: ModernMapKitView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = UIColor.systemBlue
                markerView.glyphImage = UIImage(systemName: "mappin.circle.fill")
            }
            
            return annotationView
        }
    }
}

// MARK: - Transport Mode Sheet
struct TransportModeSheet: View {
    @Binding var selectedMode: TransportMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(TransportMode.allCases, id: \.self) { mode in
                HStack {
                    Image(systemName: mode.icon)
                        .foregroundColor(ShvilDesign.Colors.primary)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.displayName)
                            .font(ShvilDesign.Typography.bodyEmphasized)
                        
                        Text(mode.description)
                            .font(ShvilDesign.Typography.caption)
                            .foregroundColor(ShvilDesign.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    if selectedMode == mode {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ShvilDesign.Colors.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedMode = mode
                    dismiss()
                }
            }
            .navigationTitle("Transport Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Modern Search Sheet
struct ModernSearchSheet: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var searchService: SearchService
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                    
                    TextField("Search for places", text: $searchText)
                        .focused($isSearchFieldFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                        }
                        .foregroundColor(ShvilDesign.Colors.primary)
                    }
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
                .padding(.vertical, ShvilDesign.Spacing.sm)
                .background(ShvilDesign.Colors.secondaryBackground)
                .cornerRadius(ShvilDesign.CornerRadius.medium)
                .padding(.horizontal, ShvilDesign.Spacing.md)
                .padding(.top, ShvilDesign.Spacing.sm)
                
                // Search Results
                if searchText.isEmpty {
                    recentSearchesView
                } else {
                    searchResultsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isSearchFieldFocused = true
            }
        }
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
            Text("Recent Searches")
                .font(ShvilDesign.Typography.headline)
                .padding(.horizontal, ShvilDesign.Spacing.md)
            
            if searchService.recentSearches.isEmpty {
                VStack(spacing: ShvilDesign.Spacing.md) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                    
                    Text("No Recent Searches")
                        .font(ShvilDesign.Typography.bodyEmphasized)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                    
                    Text("Your recent searches will appear here")
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: ShvilDesign.Spacing.sm) {
                    ForEach(searchService.recentSearches) { search in
                        RecentSearchRow(search: search) {
                            searchText = search.title
                            performSearch()
                        } onRemove: {
                            searchService.removeRecentSearch(search)
                        }
                    }
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
            }
        }
    }
    
    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
            HStack {
                Text("Search Results")
                    .font(ShvilDesign.Typography.headline)
                
                Spacer()
                
                Text("\(searchService.searchResults.count) results")
                    .font(ShvilDesign.Typography.caption)
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
            }
            .padding(.horizontal, ShvilDesign.Spacing.md)
            
            if searchService.searchResults.isEmpty && !searchService.isSearching {
                VStack(spacing: ShvilDesign.Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                    
                    Text("No Results Found")
                        .font(ShvilDesign.Typography.bodyEmphasized)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                    
                    Text("Try a different search term")
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: ShvilDesign.Spacing.sm) {
                    ForEach(searchService.searchResults, id: \.self) { mapItem in
                        SearchResultRow(mapItem: mapItem) {
                            // Handle selection
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        Task {
            await searchService.search(
                query: searchText,
                region: nil // Will use current location
            )
        }
    }
}

// MARK: - Route Options Sheet
struct RouteOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationService: NavigationService
    
    var body: some View {
        NavigationView {
            Form {
                Section("Avoid") {
                    Toggle("Tolls", isOn: $navigationService.routeOptions.avoidTolls)
                    Toggle("Highways", isOn: $navigationService.routeOptions.avoidHighways)
                    Toggle("Ferries", isOn: $navigationService.routeOptions.avoidFerries)
                }
                
                Section("Preferences") {
                    Toggle("Prefer Bike Lanes", isOn: $navigationService.routeOptions.preferBikeLanes)
                }
            }
            .navigationTitle("Route Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ModernMapView()
        .environmentObject(LocationService.shared)
        .environmentObject(NavigationService.shared)
        .environmentObject(SearchService.shared)
}
