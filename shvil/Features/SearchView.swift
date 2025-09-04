//
//  SearchView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct SearchView: View {
    @StateObject private var searchService = DependencyContainer.shared.searchService
    @StateObject private var mapEngine = DependencyContainer.shared.mapEngine
    @StateObject private var locationService = DependencyContainer.shared.locationService

    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    @State private var showFilters = false
    @State private var selectedResult: SearchResult?
    @State private var showPlaceDetails = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LiquidGlassColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Header
                    searchHeader

                    // Results
                    if searchService.searchResults.isEmpty, !searchText.isEmpty {
                        emptyState
                    } else if searchService.searchResults.isEmpty {
                        suggestionsView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPlaceDetails) {
            if let result = selectedResult {
                PlaceDetailsView(place: result, isPresented: $showPlaceDetails)
            }
        }
        .onChange(of: searchText) {
            if !searchText.isEmpty {
                performSearch()
            } else {
                searchService.searchResults = []
            }
        }
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LiquidGlassColors.secondaryText)

                TextField("Search places, activities, or locations", text: $searchText)
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .textFieldStyle(PlainTextFieldStyle())

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchService.searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface1)
            )

            // Category Filters
            categoryFilters
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    categoryChip(for: category)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func categoryChip(for category: SearchCategory) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
            HapticFeedback.shared.impact(style: .light)
            performSearch()
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))

                Text(category.displayName)
                    .font(LiquidGlassTypography.caption)
            }
            .foregroundColor(selectedCategory == category ? .white : LiquidGlassColors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedCategory == category ? AnyShapeStyle(LiquidGlassGradients.primaryGradient) : AnyShapeStyle(LiquidGlassColors.glassSurface1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(LiquidGlassColors.secondaryText)

            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text("Try searching for something else or check your spelling.")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Suggestions View

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Popular Searches")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
                .padding(.horizontal, 20)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(popularSearches, id: \.self) { search in
                    suggestionCard(for: search)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.top, 20)
    }

    private var popularSearches: [String] {
        [
            "Coffee Shops",
            "Restaurants",
            "Museums",
            "Parks",
            "Shopping",
            "Bars",
            "Gas Stations",
            "Hotels",
        ]
    }

    private func suggestionCard(for search: String) -> some View {
        Button(action: {
            searchText = search
            performSearch()
        }) {
            HStack(spacing: 12) {
                Image(systemName: searchIcon(for: search))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)

                Text(search)
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func searchIcon(for search: String) -> String {
        switch search.lowercased() {
        case "coffee shops": "cup.and.saucer"
        case "restaurants": "fork.knife"
        case "museums": "building.columns"
        case "parks": "tree"
        case "shopping": "bag"
        case "bars": "wineglass"
        case "gas stations": "fuelpump"
        case "hotels": "bed.double"
        default: "location"
        }
    }

    // MARK: - Results List

    private var resultsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(searchService.searchResults.count) Results")
                    .font(LiquidGlassTypography.bodyMedium)
                    .foregroundColor(LiquidGlassColors.secondaryText)

                Spacer()

                Button(action: { showFilters = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .medium))

                        Text("Filters")
                            .font(LiquidGlassTypography.caption)
                    }
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)
                }
            }
            .padding(.horizontal, 20)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(searchService.searchResults) { result in
                        searchResultCard(for: result)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func searchResultCard(for result: SearchResult) -> some View {
        Button(action: {
            selectedResult = result
            showPlaceDetails = true
            HapticFeedback.shared.impact(style: .light)
        }) {
            HStack(spacing: 16) {
                // Place Image/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LiquidGlassColors.glassSurface2)
                        .frame(width: 60, height: 60)

                    Image(systemName: placeIcon(for: result))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(LiquidGlassTypography.bodyMedium)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)

                    Text(result.address ?? "Address not available")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .lineLimit(2)

                    // Distance calculation would go here if needed
                    Text("Tap to view details")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassColors.glassSurface1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func placeIcon(for _: SearchResult) -> String {
        // This would be determined by the result's category or type
        "location"
    }

    // MARK: - Actions

    private func performSearch() {
        guard !searchText.isEmpty else { return }

        Task {
            // TODO: Implement search functionality
            print("Searching for: \(searchText) in category: \(selectedCategory)")
        }
    }
}

// MARK: - Search Category

enum SearchCategory: String, CaseIterable {
    case all
    case food
    case shopping
    case entertainment
    case services
    case transportation

    var displayName: String {
        switch self {
        case .all: "All"
        case .food: "Food"
        case .shopping: "Shopping"
        case .entertainment: "Entertainment"
        case .services: "Services"
        case .transportation: "Transport"
        }
    }

    var icon: String {
        switch self {
        case .all: "square.grid.2x2"
        case .food: "fork.knife"
        case .shopping: "bag"
        case .entertainment: "tv"
        case .services: "wrench.and.screwdriver"
        case .transportation: "car"
        }
    }
}

#Preview {
    SearchView()
}
