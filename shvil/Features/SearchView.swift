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
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        VStack(spacing: AppleSpacing.md) {
            // Search Bar
            ShvilSearchField(
                text: $searchText,
                placeholder: "Search places, activities, or locations",
                onVoiceSearch: {
                    // TODO: Implement voice search
                }
            )

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
        ShvilGlassChip(
            category.displayName,
            icon: category.icon,
            isSelected: selectedCategory == category
        ) {
            withAnimation(AppleAnimations.spring) {
                selectedCategory = category
            }
            HapticFeedback.shared.impact(style: .light)
            performSearch()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        AppleGlassEmptyState(
            icon: "magnifyingglass",
            title: "No Results Found",
            description: "Try searching for something else or check your spelling.",
            actionTitle: "Clear Search",
            action: {
                searchText = ""
                searchService.searchResults = []
            }
        )
    }

    // MARK: - Suggestions View

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.lg) {
            Text("Popular Searches")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)
                .padding(.horizontal, AppleSpacing.md)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppleSpacing.sm) {
                ForEach(popularSearches, id: \.self) { search in
                    suggestionCard(for: search)
                }
            }
            .padding(.horizontal, AppleSpacing.md)

            Spacer()
        }
        .padding(.top, AppleSpacing.lg)
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
        AppleGlassCard(style: .glassmorphism) {
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
        }
        .onTapGesture {
            searchText = search
            performSearch()
        }
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

                AppleGlassButton(
                    title: "Filters",
                    icon: "slider.horizontal.3",
                    style: .tertiary,
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
        AppleGlassCard(style: .glassmorphism) {
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
    }

    private func placeIcon(for _: SearchResult) -> String {
        "location"
    }

    // MARK: - Actions

    private func performSearch() {
        guard !searchText.isEmpty else { return }

        Task {
            print("Searching for: \(searchText) in category: \(selectedCategory)")
        }
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