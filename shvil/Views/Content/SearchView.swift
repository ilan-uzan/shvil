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
    @StateObject private var locationManager = DependencyContainer.shared.locationManager

    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    @State private var showFilters = false
    @State private var selectedResult: SearchResult?
    @State private var showPlaceDetails = false
    @State private var searchHistory: [String] = []
    @State private var recentSearches: [String] = []

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DesignTokens.Surface.background
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
        }
        .appleNavigationBar()
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
        .onAppear {
            loadRecentSearches()
        }
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignTokens.Text.secondary)
                    .padding(.leading, DesignTokens.Spacing.sm)
                
                TextField("Search places, activities, or locations", text: $searchText)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.primary)
                    .onSubmit {
                        if !searchText.isEmpty {
                            searchService.search(for: searchText)
                        }
                    }
                    .accessibilityLabel("Search field")
                    .accessibilityHint("Enter a place, activity, or location to search")
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchService.searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(DesignTokens.Glass.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .stroke(DesignTokens.Glass.light, lineWidth: 1)
                    )
            )
            .appleShadow(DesignTokens.Shadow.light)

            // Category Filters
            categoryFilters
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.sm)
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    categoryChip(for: category)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xs)
        }
    }

    private func categoryChip(for category: SearchCategory) -> some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Image(systemName: category.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedCategory == category ? .white : DesignTokens.Brand.primary)
            
            Text(category.displayName)
                .font(DesignTokens.Typography.caption1)
                .foregroundColor(selectedCategory == category ? .white : DesignTokens.Text.primary)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(selectedCategory == category ? DesignTokens.Brand.primary : DesignTokens.Glass.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(selectedCategory == category ? Color.clear : DesignTokens.Glass.light, lineWidth: 1)
                )
        )
        .appleShadow(DesignTokens.Shadow.light)
        .onTapGesture {
            withAnimation(DesignTokens.Animation.spring) {
                selectedCategory = category
            }
            HapticFeedback.shared.impact(style: .light)
            performSearch()
        }
        .accessibilityLabel("Category: \(category.displayName)")
        .accessibilityHint(selectedCategory == category ? "Currently selected" : "Double tap to select this category")
        .accessibilityAddTraits(selectedCategory == category ? .isSelected : [])
    }

    // MARK: - Empty State

    private var emptyState: some View {
        AppleGlassEmptyState(
            title: "No Results Found",
            description: "Try searching for something else or check your spelling.",
            icon: "magnifyingglass",
            actionTitle: "Clear Search",
            action: {
                searchText = ""
                searchService.searchResults = []
            }
        )
    }

    // MARK: - Suggestions View

    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                // Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        HStack {
                            Text("Recent Searches")
                                .font(DesignTokens.Typography.title3)
                                .foregroundColor(DesignTokens.Text.primary)
                            
                            Spacer()
                            
                            Button("Clear") {
                                recentSearches.removeAll()
                                UserDefaults.standard.set([], forKey: "recent_searches")
                            }
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Brand.primary)
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        
                        LazyVStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(Array(recentSearches.enumerated()), id: \.offset) { index, search in
                                recentSearchRow(for: search)
                                    .id("recent-\(index)")
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                    }
                }
                
                // Popular Searches
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Popular Searches")
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(DesignTokens.Text.primary)
                        .padding(.horizontal, DesignTokens.Spacing.md)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.sm), count: 2), spacing: DesignTokens.Spacing.sm) {
                        ForEach(popularSearches, id: \.self) { search in
                            suggestionCard(for: search)
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                }
            }
            .padding(.top, DesignTokens.Spacing.lg)
        }
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
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: searchIcon(for: search))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.Brand.primary)
                .frame(width: 24)

            Text(search)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(DesignTokens.Shadow.light)
        .onTapGesture {
            searchText = search
            performSearch()
            HapticFeedback.shared.impact(style: .light)
        }
        .accessibilityLabel("Search suggestion: \(search)")
        .accessibilityHint("Double tap to search for \(search)")
        .accessibilityAddTraits(.isButton)
    }
    
    private func recentSearchRow(for search: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "clock")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.Text.secondary)
                .frame(width: 20)
            
            Text(search)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: {
                removeRecentSearch(search)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DesignTokens.Text.tertiary)
            }
            .accessibilityLabel("Remove from recent searches")
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(DesignTokens.Shadow.light)
        .onTapGesture {
            searchText = search
            performSearch()
            HapticFeedback.shared.impact(style: .light)
        }
        .accessibilityLabel("Recent search: \(search)")
        .accessibilityHint("Double tap to search for \(search)")
        .accessibilityAddTraits(.isButton)
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("\(searchService.searchResults.count) Results")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.secondary)

                Spacer()

                AppleButton(
                    "Filters",
                    icon: "slider.horizontal.3",
                    style: .ghost,
                    size: .small
                ) {
                    showFilters = true
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)

            ScrollView {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(Array(searchService.searchResults.enumerated()), id: \.offset) { index, result in
                        searchResultCard(for: result)
                            .id("result-\(index)")
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
        }
    }

    private func searchResultCard(for result: SearchResult) -> some View {
        AppleGlassCard(style: .elevated) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Place Image/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .fill(DesignTokens.Surface.secondary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                                .stroke(DesignTokens.Glass.light, lineWidth: 1)
                        )
                        .appleShadow(DesignTokens.Shadow.light)

                    Image(systemName: placeIcon(for: result))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(result.name)
                        .font(DesignTokens.Typography.bodyEmphasized)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(1)

                    Text(result.address)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(2)

                    Text("Tap to view details")
                        .font(AppleTypography.caption2)
                        .foregroundColor(DesignTokens.Brand.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignTokens.Text.tertiary)
            }
        }
        .onTapGesture {
            selectedResult = result
            showPlaceDetails = true
            HapticFeedback.shared.impact(style: .light)
        }
        .accessibilityLabel("Search result: \(result.name)")
        .accessibilityHint("Double tap to view details for \(result.name)")
        .accessibilityAddTraits(.isButton)
    }

    private func placeIcon(for _: SearchResult) -> String {
        "location"
    }

    // MARK: - Actions

    private func performSearch() {
        guard !searchText.isEmpty else { return }

        // Add to recent searches
        addToRecentSearches(searchText)

        Task {
            print("Searching for: \(searchText) in category: \(selectedCategory)")
            // TODO: Implement actual search logic
        }
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recent_searches") ?? []
    }
    
    private func addToRecentSearches(_ search: String) {
        // Remove if already exists
        recentSearches.removeAll { $0 == search }
        
        // Add to beginning
        recentSearches.insert(search, at: 0)
        
        // Keep only last 10 searches
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "recent_searches")
    }
    
    private func removeRecentSearch(_ search: String) {
        recentSearches.removeAll { $0 == search }
        UserDefaults.standard.set(recentSearches, forKey: "recent_searches")
    }
}

// MARK: - Search Category

public enum SearchCategory: String, CaseIterable, Codable {
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