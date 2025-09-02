//
//  ModernSearchView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct ModernSearchView: View {
    @EnvironmentObject private var searchService: SearchService
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var authManager: AuthenticationManager
    
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    @State private var showingFilters = false
    @State private var selectedResult: MKMapItem?
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Category Filter
                categoryFilter
                
                // Content
                if searchText.isEmpty {
                    if searchService.recentSearches.isEmpty {
                        emptyStateView
                    } else {
                        recentSearchesView
                    }
                } else {
                    searchResultsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadRecentSearches()
            }
            .onChange(of: searchText) { _, newValue in
                handleSearchTextChange(newValue)
            }
        }
        .sheet(isPresented: Binding(
            get: { selectedResult != nil },
            set: { if !$0 { selectedResult = nil } }
        )) {
            if let mapItem = selectedResult {
                ModernPlaceDetailView(mapItem: mapItem)
            }
        }
        .sheet(isPresented: $showingFilters) {
            SearchFiltersSheet(selectedCategory: $selectedCategory)
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: ShvilDesign.Spacing.md) {
            HStack {
                // Search Field
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
                            searchService.clearSearch()
                        }
                        .foregroundColor(ShvilDesign.Colors.primary)
                    }
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
                .padding(.vertical, ShvilDesign.Spacing.sm)
                .background(ShvilDesign.Colors.secondaryBackground)
                .cornerRadius(ShvilDesign.CornerRadius.medium)
                
                // Filters Button
                Button(action: { showingFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(ShvilDesign.Colors.primary)
                        .frame(width: 44, height: 44)
                        .background(ShvilDesign.Colors.secondaryBackground)
                        .clipShape(Circle())
                }
            }
            
            // Search Status
            if searchService.isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                }
            } else if let error = searchService.searchError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(ShvilDesign.Colors.warning)
                    Text(error.localizedDescription)
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                }
            }
        }
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.top, ShvilDesign.Spacing.sm)
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ShvilDesign.Spacing.sm) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(ShvilDesign.Animation.spring) {
                            selectedCategory = category
                        }
                        if !searchText.isEmpty {
                            performSearch()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            
                            Text(category.title)
                                .font(ShvilDesign.Typography.caption)
                        }
                        .foregroundColor(selectedCategory == category ? .white : ShvilDesign.Colors.primary)
                        .padding(.horizontal, ShvilDesign.Spacing.sm)
                        .padding(.vertical, ShvilDesign.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: ShvilDesign.CornerRadius.pill)
                                .fill(selectedCategory == category ? ShvilDesign.Colors.primary : ShvilDesign.Colors.secondaryBackground)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, ShvilDesign.Spacing.md)
        }
        .padding(.vertical, ShvilDesign.Spacing.sm)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: ShvilDesign.Spacing.lg) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(ShvilDesign.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(ShvilDesign.Colors.primary)
            }
            
            VStack(spacing: ShvilDesign.Spacing.sm) {
                Text("Discover Places")
                    .font(ShvilDesign.Typography.title2)
                    .foregroundColor(ShvilDesign.Colors.primaryText)
                
                Text("Search for restaurants, shops, and other places near you")
                    .font(ShvilDesign.Typography.body)
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ShvilDesign.Spacing.xl)
            }
            
            // Quick Actions
            VStack(spacing: ShvilDesign.Spacing.sm) {
                if locationService.isLocationEnabled {
                    QuickActionButton(
                        icon: "fork.knife",
                        title: "Restaurants Near Me",
                        color: ShvilDesign.Colors.success
                    ) {
                        searchText = "restaurants near me"
                        performSearch()
                    }
                }
                
                QuickActionButton(
                    icon: "fuelpump",
                    title: "Gas Stations",
                    color: ShvilDesign.Colors.warning
                ) {
                    searchText = "gas stations"
                    performSearch()
                }
                
                QuickActionButton(
                    icon: "building.2",
                    title: "Shopping Centers",
                    color: ShvilDesign.Colors.info
                ) {
                    searchText = "shopping centers"
                    performSearch()
                }
            }
            .padding(.top, ShvilDesign.Spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Recent Searches View
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
            HStack {
                Text("Recent Searches")
                    .font(ShvilDesign.Typography.title3)
                    .foregroundColor(ShvilDesign.Colors.primaryText)
                
                Spacer()
                
                if !searchService.recentSearches.isEmpty {
                    Button("Clear All") {
                        searchService.clearRecentSearches()
                    }
                    .font(ShvilDesign.Typography.caption)
                    .foregroundColor(ShvilDesign.Colors.primary)
                }
            }
            .padding(.horizontal, ShvilDesign.Spacing.md)
            
            LazyVStack(spacing: ShvilDesign.Spacing.sm) {
                ForEach(searchService.recentSearches) { search in
                    ModernRecentSearchRow(search: search) {
                        selectSearchResult(search)
                    } onRemove: {
                        searchService.removeRecentSearch(search)
                    }
                }
            }
            .padding(.horizontal, ShvilDesign.Spacing.md)
        }
    }
    
    // MARK: - Search Results View
    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
            HStack {
                Text("Search Results")
                    .font(ShvilDesign.Typography.title3)
                    .foregroundColor(ShvilDesign.Colors.primaryText)
                
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
                    
                    Text("Try a different search term or category")
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: ShvilDesign.Spacing.sm) {
                    ForEach(searchService.searchResults, id: \.self) { mapItem in
                        ModernSearchResultRow(mapItem: mapItem) {
                            selectedResult = mapItem
                        }
                    }
                }
                .padding(.horizontal, ShvilDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadRecentSearches() {
        // Recent searches are loaded automatically by SearchService
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        if newValue.isEmpty {
            searchService.clearSearch()
        } else {
            // Debounce search requests
            Task {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                if searchText == newValue {
                    await performSearch()
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        Task {
            await searchService.search(
                query: searchText,
                region: locationService.currentLocation.map { location in
                    MKCoordinateRegion(
                        center: location.coordinate,
                        latitudinalMeters: 10000,
                        longitudinalMeters: 10000
                    )
                }
            )
        }
    }
    
    private func selectSearchResult(_ search: SearchResult) {
        // Create a mock MKMapItem from the search result
        let placemark = MKPlacemark(coordinate: search.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = search.title
        selectedResult = mapItem
    }
}

// MARK: - Search Category
enum SearchCategory: String, CaseIterable {
    case all = "all"
    case restaurants = "restaurants"
    case gas = "gas"
    case shopping = "shopping"
    case hotels = "hotels"
    case attractions = "attractions"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .restaurants: return "Food"
        case .gas: return "Gas"
        case .shopping: return "Shopping"
        case .hotels: return "Hotels"
        case .attractions: return "Attractions"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "globe"
        case .restaurants: return "fork.knife"
        case .gas: return "fuelpump"
        case .shopping: return "bag"
        case .hotels: return "bed.double"
        case .attractions: return "star"
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ShvilDesign.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(ShvilDesign.Typography.body)
                    .foregroundColor(ShvilDesign.Colors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                    .font(.caption)
            }
            .padding(.horizontal, ShvilDesign.Spacing.md)
            .padding(.vertical, ShvilDesign.Spacing.sm)
            .background(ShvilDesign.Colors.secondaryBackground)
            .cornerRadius(ShvilDesign.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Recent Search Row
struct ModernRecentSearchRow: View {
    let search: SearchResult
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ShvilDesign.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(ShvilDesign.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "clock")
                        .foregroundColor(ShvilDesign.Colors.primary)
                        .font(.system(size: 16))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(search.title)
                        .font(ShvilDesign.Typography.body)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                        .lineLimit(1)
                    
                    Text(search.subtitle)
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Remove Button
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .font(.system(size: 20))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, ShvilDesign.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Search Result Row
struct ModernSearchResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ShvilDesign.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(ShvilDesign.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(ShvilDesign.Colors.primary)
                        .font(.system(size: 16))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Unknown")
                        .font(ShvilDesign.Typography.body)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                        .lineLimit(1)
                    
                    Text(mapItem.placemark.title ?? "")
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Distance (if available)
                if let distance = calculateDistance() {
                    Text(distance)
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .padding(.horizontal, ShvilDesign.Spacing.sm)
                        .padding(.vertical, ShvilDesign.Spacing.xs)
                        .background(ShvilDesign.Colors.secondaryBackground)
                        .cornerRadius(ShvilDesign.CornerRadius.small)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                    .font(.caption)
            }
            .padding(.vertical, ShvilDesign.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func calculateDistance() -> String? {
        // This would calculate distance from user's current location
        // For now, return nil
        return nil
    }
}

// MARK: - Modern Place Detail View
struct ModernPlaceDetailView: View {
    let mapItem: MKMapItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationService: NavigationService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ShvilDesign.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
                        Text(mapItem.name ?? "Unknown Place")
                            .font(ShvilDesign.Typography.title1)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        if let address = mapItem.placemark.title {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                                Text(address)
                                    .font(ShvilDesign.Typography.body)
                                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(ShvilDesign.Spacing.lg)
                    .background(ShvilDesign.Colors.secondaryBackground)
                    .cornerRadius(ShvilDesign.CornerRadius.large)
                    
                    // Action Buttons
                    VStack(spacing: ShvilDesign.Spacing.md) {
                        Button(action: {
                            // Start navigation
                            if let coordinate = mapItem.placemark.location?.coordinate {
                                navigationService.setDestination(coordinate)
                            }
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Start Navigation")
                            }
                            .font(ShvilDesign.Typography.bodyEmphasized)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ShvilDesign.Spacing.md)
                            .background(ShvilDesign.Colors.primary)
                            .cornerRadius(ShvilDesign.CornerRadius.medium)
                        }
                        
                        HStack(spacing: ShvilDesign.Spacing.md) {
                            Button(action: {
                                // Add to saved places
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "star")
                                    Text("Save")
                                }
                                .font(ShvilDesign.Typography.body)
                                .foregroundColor(ShvilDesign.Colors.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, ShvilDesign.Spacing.sm)
                                .background(ShvilDesign.Colors.primary.opacity(0.1))
                                .cornerRadius(ShvilDesign.CornerRadius.medium)
                            }
                            
                            Button(action: {
                                // Share
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(ShvilDesign.Typography.body)
                                .foregroundColor(ShvilDesign.Colors.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, ShvilDesign.Spacing.sm)
                                .background(ShvilDesign.Colors.primary.opacity(0.1))
                                .cornerRadius(ShvilDesign.CornerRadius.medium)
                            }
                        }
                    }
                }
                .padding(ShvilDesign.Spacing.md)
            }
            .navigationTitle("Place Details")
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

// MARK: - Search Filters Sheet
struct SearchFiltersSheet: View {
    @Binding var selectedCategory: SearchCategory
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(SearchCategory.allCases, id: \.self) { category in
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(ShvilDesign.Colors.primary)
                        .frame(width: 30)
                    
                    Text(category.title)
                        .font(ShvilDesign.Typography.body)
                    
                    Spacer()
                    
                    if selectedCategory == category {
                        Image(systemName: "checkmark")
                            .foregroundColor(ShvilDesign.Colors.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = category
                    dismiss()
                }
            }
            .navigationTitle("Categories")
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
    ModernSearchView()
        .environmentObject(SearchService.shared)
        .environmentObject(LocationService.shared)
        .environmentObject(AuthenticationManager.shared)
}
