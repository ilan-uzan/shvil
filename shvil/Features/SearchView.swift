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
    @State private var searchHistory: [String] = []
    @State private var recentSearches: [String] = []

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppleColors.background
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
            .appleNavigationBar()
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
        .onAppear {
            loadRecentSearches()
        }
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        VStack(spacing: AppleSpacing.md) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppleColors.textSecondary)
                    .padding(.leading, AppleSpacing.sm)
                
                TextField("Search places, activities, or locations", text: $searchText)
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textPrimary)
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
                            .foregroundColor(AppleColors.textTertiary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                    .fill(AppleColors.glassMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                            .stroke(AppleColors.glassLight, lineWidth: 1)
                    )
            )
            .appleShadow(AppleShadows.light)

            // Category Filters
            categoryFilters
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.top, AppleSpacing.sm)
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppleSpacing.sm) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    categoryChip(for: category)
                }
            }
            .padding(.horizontal, AppleSpacing.xs)
        }
    }

    private func categoryChip(for category: SearchCategory) -> some View {
        HStack(spacing: AppleSpacing.xs) {
            Image(systemName: category.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedCategory == category ? .white : AppleColors.accent)
            
            Text(category.displayName)
                .font(AppleTypography.caption1)
                .foregroundColor(selectedCategory == category ? .white : AppleColors.textPrimary)
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(selectedCategory == category ? AppleColors.brandPrimary : AppleColors.glassMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .stroke(selectedCategory == category ? Color.clear : AppleColors.glassLight, lineWidth: 1)
                )
        )
        .appleShadow(AppleShadows.light)
        .onTapGesture {
            withAnimation(AppleAnimations.spring) {
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
            VStack(alignment: .leading, spacing: AppleSpacing.xl) {
                // Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: AppleSpacing.md) {
                        HStack {
                            Text("Recent Searches")
                                .font(AppleTypography.title3)
                                .foregroundColor(AppleColors.textPrimary)
                            
                            Spacer()
                            
                            Button("Clear") {
                                recentSearches.removeAll()
                                UserDefaults.standard.set([], forKey: "recent_searches")
                            }
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.brandPrimary)
                        }
                        .padding(.horizontal, AppleSpacing.md)
                        
                        LazyVStack(spacing: AppleSpacing.sm) {
                            ForEach(recentSearches, id: \.self) { search in
                                recentSearchRow(for: search)
                            }
                        }
                        .padding(.horizontal, AppleSpacing.md)
                    }
                }
                
                // Popular Searches
                VStack(alignment: .leading, spacing: AppleSpacing.md) {
                    Text("Popular Searches")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)
                        .padding(.horizontal, AppleSpacing.md)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppleSpacing.sm), count: 2), spacing: AppleSpacing.sm) {
                        ForEach(popularSearches, id: \.self) { search in
                            suggestionCard(for: search)
                        }
                    }
                    .padding(.horizontal, AppleSpacing.md)
                }
            }
            .padding(.top, AppleSpacing.lg)
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
        HStack(spacing: AppleSpacing.sm) {
            Image(systemName: searchIcon(for: search))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppleColors.accent)
                .frame(width: 24)

            Text(search)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textPrimary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(AppleShadows.light)
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
        HStack(spacing: AppleSpacing.md) {
            Image(systemName: "clock")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppleColors.textSecondary)
                .frame(width: 20)
            
            Text(search)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textPrimary)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: {
                removeRecentSearch(search)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppleColors.textTertiary)
            }
            .accessibilityLabel("Remove from recent searches")
        }
        .padding(.horizontal, AppleSpacing.md)
        .padding(.vertical, AppleSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(AppleShadows.light)
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
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            HStack {
                Text("\(searchService.searchResults.count) Results")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textSecondary)

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
            .padding(.horizontal, AppleSpacing.md)

            ScrollView {
                LazyVStack(spacing: AppleSpacing.sm) {
                    ForEach(searchService.searchResults) { result in
                        searchResultCard(for: result)
                    }
                }
                .padding(.horizontal, AppleSpacing.md)
            }
        }
    }

    private func searchResultCard(for result: SearchResult) -> some View {
        AppleGlassCard(style: .elevated) {
            HStack(spacing: AppleSpacing.md) {
                // Place Image/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                        .fill(AppleColors.surfaceSecondary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.md)
                                .stroke(AppleColors.glassLight, lineWidth: 1)
                        )
                        .appleShadow(AppleShadows.light)

                    Image(systemName: placeIcon(for: result))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppleColors.accent)
                }

                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    Text(result.name)
                        .font(AppleTypography.bodyEmphasized)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)

                    Text(result.address ?? "Address not available")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                        .lineLimit(2)

                    Text("Tap to view details")
                        .font(AppleTypography.caption2)
                        .foregroundColor(AppleColors.accent)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppleColors.textTertiary)
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