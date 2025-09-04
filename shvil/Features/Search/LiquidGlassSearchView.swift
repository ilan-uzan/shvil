//
//  LiquidGlassSearchView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct LiquidGlassSearchView: View {
    @EnvironmentObject private var searchService: SearchService
    @EnvironmentObject private var navigationService: NavigationService
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory: SearchCategory = .all
    @State private var showFilters = false
    
    var body: some View {
        ZStack {
            // Background
            LiquidGlassDesign.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Search Content
                if searchText.isEmpty {
                    searchSuggestions
                } else {
                    searchResults
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            LiquidGlassSearchFilters()
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: LiquidGlassDesign.Spacing.md) {
            // Search Bar
            HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    
                    TextField("Search places, addresses...", text: $searchText)
                        .font(LiquidGlassDesign.Typography.body)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                .padding(.vertical, LiquidGlassDesign.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                        .fill(LiquidGlassDesign.Colors.glassWhite)
                        .shadow(color: LiquidGlassDesign.Shadows.light, radius: 8, x: 0, y: 4)
                )
                
                // Filter Button
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                                .fill(LiquidGlassDesign.Colors.glassWhite)
                                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                        )
                }
            }
            
            // Category Selector
            categorySelector
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
        .padding(.top, LiquidGlassDesign.Spacing.md)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        )
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14, weight: .medium))
                            Text(category.title)
                                .font(LiquidGlassDesign.Typography.callout)
                        }
                        .foregroundColor(selectedCategory == category ? .white : LiquidGlassDesign.Colors.liquidBlue)
                        .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                        .padding(.vertical, LiquidGlassDesign.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.round)
                                .fill(selectedCategory == category ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.glassWhite)
                                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, LiquidGlassDesign.Spacing.md)
        }
    }
    
    // MARK: - Search Suggestions
    private var searchSuggestions: some View {
        ScrollView {
            LazyVStack(spacing: LiquidGlassDesign.Spacing.md) {
                // Quick Actions
                quickActionsSection
                
                // Recent Searches
                if !searchService.recentSearches.isEmpty {
                    recentSearchesSection
                }
                
                // Popular Places
                popularPlacesSection
                
                // Categories
                categoriesSection
            }
            .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            .padding(.top, LiquidGlassDesign.Spacing.lg)
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
            Text("Quick Actions")
                .font(LiquidGlassDesign.Typography.headline)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: LiquidGlassDesign.Spacing.sm) {
                QuickActionCard(
                    icon: "location.fill",
                    title: "Current Location",
                    subtitle: "Use my location",
                    color: LiquidGlassDesign.Colors.liquidBlue
                ) {
                    // Handle current location
                }
                
                QuickActionCard(
                    icon: "house.fill",
                    title: "Home",
                    subtitle: "Navigate to home",
                    color: LiquidGlassDesign.Colors.accentGreen
                ) {
                    // Handle home navigation
                }
                
                QuickActionCard(
                    icon: "briefcase.fill",
                    title: "Work",
                    subtitle: "Navigate to work",
                    color: LiquidGlassDesign.Colors.accentOrange
                ) {
                    // Handle work navigation
                }
                
                QuickActionCard(
                    icon: "star.fill",
                    title: "Favorites",
                    subtitle: "View saved places",
                    color: LiquidGlassDesign.Colors.accentPurple
                ) {
                    // Handle favorites
                }
            }
        }
    }
    
    // MARK: - Recent Searches Section
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
            HStack {
                Text("Recent Searches")
                    .font(LiquidGlassDesign.Typography.headline)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Spacer()
                
                Button("Clear All") {
                    searchService.clearRecentSearches()
                }
                .font(LiquidGlassDesign.Typography.callout)
                .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
            }
            
            ForEach(searchService.recentSearches.prefix(5), id: \.id) { search in
                RecentSearchCard(search: search) {
                    searchText = search.title
                    performSearch()
                }
            }
        }
    }
    
    // MARK: - Popular Places Section
    private var popularPlacesSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
            Text("Popular Places")
                .font(LiquidGlassDesign.Typography.headline)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            
            ForEach(popularPlaces, id: \.id) { place in
                PopularPlaceCard(place: place) {
                    // Handle place selection
                }
            }
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
            Text("Explore Categories")
                .font(LiquidGlassDesign.Typography.headline)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: LiquidGlassDesign.Spacing.sm) {
                ForEach(SearchCategory.allCases.dropFirst(), id: \.self) { category in
                    CategoryCard(category: category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: LiquidGlassDesign.Spacing.sm) {
                if isSearching {
                    ForEach(0..<5, id: \.self) { _ in
                        SearchResultSkeleton()
                    }
                } else {
                    ForEach(searchService.searchResults, id: \.self) { result in
                        SearchResultCard(result: result) {
                            // Handle result selection
                        }
                    }
                }
            }
            .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            .padding(.top, LiquidGlassDesign.Spacing.lg)
        }
    }
    
    // MARK: - Helper Methods
    private func performSearch() {
        isSearching = true
        Task {
            await searchService.search(query: searchText)
            isSearching = false
        }
    }
    
    // MARK: - Mock Data
    private var popularPlaces: [PopularPlace] {
        [
            PopularPlace(id: "1", name: "Golden Gate Bridge", category: "Landmark", distance: "2.3 km", rating: 4.8),
            PopularPlace(id: "2", name: "Fisherman's Wharf", category: "Tourist Spot", distance: "1.8 km", rating: 4.5),
            PopularPlace(id: "3", name: "Union Square", category: "Shopping", distance: "3.1 km", rating: 4.3),
            PopularPlace(id: "4", name: "Lombard Street", category: "Landmark", distance: "2.7 km", rating: 4.6)
        ]
    }
}

// MARK: - Search Category
enum SearchCategory: CaseIterable {
    case all, restaurants, gas, parking, hotels, shopping, entertainment, healthcare
    
    var title: String {
        switch self {
        case .all: return "All"
        case .restaurants: return "Food"
        case .gas: return "Gas"
        case .parking: return "Parking"
        case .hotels: return "Hotels"
        case .shopping: return "Shopping"
        case .entertainment: return "Fun"
        case .healthcare: return "Health"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "globe"
        case .restaurants: return "fork.knife"
        case .gas: return "fuelpump.fill"
        case .parking: return "p.circle.fill"
        case .hotels: return "bed.double.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .healthcare: return "cross.fill"
        }
    }
}

// MARK: - Quick Action Card
// Note: QuickActionCard is now defined in SharedComponents.swift

// MARK: - Recent Search Card
struct RecentSearchCard: View {
    let search: SearchResult
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(search.title)
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Text(search.subtitle)
                        .font(LiquidGlassDesign.Typography.caption)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Popular Place Card
struct PopularPlaceCard: View {
    let place: PopularPlace
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        Text(place.category)
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        
                        Text("•")
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        
                        Text(place.distance)
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(LiquidGlassDesign.Colors.accentOrange)
                        
                        Text(String(format: "%.1f", place.rating))
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                    }
                }
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: SearchCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(LiquidGlassDesign.Colors.liquidBlue.opacity(0.1))
                    )
                
                Text(category.title)
                    .font(LiquidGlassDesign.Typography.caption)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(LiquidGlassDesign.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    let result: MKMapItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name ?? "Unknown Location")
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .lineLimit(1)
                    
                    if let subtitle = result.placemark.title {
                        Text(subtitle)
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(LiquidGlassDesign.Colors.liquidBlue.opacity(0.1))
                        )
                }
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Result Skeleton
struct SearchResultSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: LiquidGlassDesign.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(LiquidGlassDesign.Colors.glassMedium)
                    .frame(width: 120, height: 16)
                    .opacity(isAnimating ? 0.3 : 0.7)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(LiquidGlassDesign.Colors.glassMedium)
                    .frame(width: 80, height: 12)
                    .opacity(isAnimating ? 0.7 : 0.3)
            }
            
            Spacer()
            
            Circle()
                .fill(LiquidGlassDesign.Colors.glassMedium)
                .frame(width: 32, height: 32)
                .opacity(isAnimating ? 0.3 : 0.7)
        }
        .padding(LiquidGlassDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                .fill(LiquidGlassDesign.Colors.glassWhite)
                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Search Filters
struct LiquidGlassSearchFilters: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilters: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: LiquidGlassDesign.Spacing.lg) {
                // Filter Options
                VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
                    Text("Filter Results")
                        .font(LiquidGlassDesign.Typography.title2)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    ForEach(filterOptions, id: \.id) { option in
                        FilterOptionRow(option: option, isSelected: selectedFilters.contains(option.id)) {
                            if selectedFilters.contains(option.id) {
                                selectedFilters.remove(option.id)
                            } else {
                                selectedFilters.insert(option.id)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Apply Button
                LiquidGlassButton("Apply Filters", icon: "checkmark", style: .primary) {
                    dismiss()
                }
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        selectedFilters.removeAll()
                    }
                }
            }
        }
    }
    
    private var filterOptions: [FilterOption] {
        [
            FilterOption(id: "open", title: "Open Now", icon: "clock"),
            FilterOption(id: "rating", title: "High Rating", icon: "star.fill"),
            FilterOption(id: "distance", title: "Nearby", icon: "location"),
            FilterOption(id: "price", title: "Affordable", icon: "dollarsign.circle")
        ]
    }
}

struct FilterOptionRow: View {
    let option: FilterOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                Image(systemName: option.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.textSecondary)
                    .frame(width: 20)
                
                Text(option.title)
                    .font(LiquidGlassDesign.Typography.callout)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.textSecondary)
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(isSelected ? LiquidGlassDesign.Colors.liquidBlue.opacity(0.1) : LiquidGlassDesign.Colors.glassWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                            .stroke(isSelected ? LiquidGlassDesign.Colors.liquidBlue : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models
struct PopularPlace {
    let id: String
    let name: String
    let category: String
    let distance: String
    let rating: Double
}

struct FilterOption {
    let id: String
    let title: String
    let icon: String
}



// MARK: - Preview
#Preview {
    LiquidGlassSearchView()
        .environmentObject(SearchService.shared)
        .environmentObject(NavigationService.shared)
}
