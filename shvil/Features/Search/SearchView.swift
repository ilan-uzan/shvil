//
//  SearchView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @EnvironmentObject private var searchService: SearchService
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var authManager: AuthenticationManager
    
    @State private var searchText = ""
    @State private var showRecentSearches = true
    @State private var selectedResult: MKMapItem?
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Content
                if showRecentSearches && searchText.isEmpty {
                    recentSearchesView
                } else if searchText.isEmpty {
                    emptyStateView
                } else {
                    searchResultsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
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
                PlaceDetailView(mapItem: mapItem)
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
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
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Search Status
            if searchService.isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let error = searchService.searchError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Recent Searches View
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !searchService.recentSearches.isEmpty {
                    Button("Clear All") {
                        searchService.clearRecentSearches()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            
            if searchService.recentSearches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No Recent Searches")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your recent searches will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(searchService.recentSearches) { search in
                        RecentSearchRow(search: search) {
                            selectSearchResult(search)
                        } onRemove: {
                            searchService.removeRecentSearch(search)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Search for Places")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Find restaurants, shops, and other places near you")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Quick Actions
            VStack(spacing: 12) {
                if locationService.isLocationEnabled {
                    Button(action: {
                        searchText = "restaurants near me"
                        performSearch()
                    }) {
                        HStack {
                            Image(systemName: "fork.knife")
                            Text("Restaurants Near Me")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Button(action: {
                    searchText = "gas stations"
                    performSearch()
                }) {
                    HStack {
                        Image(systemName: "fuelpump")
                        Text("Gas Stations")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Search Results View
    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Search Results")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(searchService.searchResults.count) results")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            
            if searchService.searchResults.isEmpty && !searchService.isSearching {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No Results Found")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Try a different search term")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(searchService.searchResults, id: \.self) { mapItem in
                        SearchResultRow(mapItem: mapItem) {
                            selectedResult = mapItem
                        }
                    }
                }
                .padding(.horizontal, 16)
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
            showRecentSearches = true
        } else {
            showRecentSearches = false
            // Debounce search requests
            Task {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                if searchText == newValue {
                    await searchService.search(
                        query: newValue,
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

// MARK: - Recent Search Row
struct RecentSearchRow: View {
    let search: SearchResult
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(search.title)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(search.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Unknown")
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(mapItem.placemark.title ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Place Detail View
struct PlaceDetailView: View {
    let mapItem: MKMapItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Place Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(mapItem.name ?? "Unknown Place")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let address = mapItem.placemark.title {
                        Text(address)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // TODO: Start navigation
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Start Navigation")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Add to saved places
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "star")
                            Text("Save Place")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
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

#Preview {
    SearchView()
        .environmentObject(SearchService.shared)
        .environmentObject(LocationService.shared)
        .environmentObject(AuthenticationManager.shared)
}
