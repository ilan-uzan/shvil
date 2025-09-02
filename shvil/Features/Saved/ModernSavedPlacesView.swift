//
//  ModernSavedPlacesView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct ModernSavedPlacesView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var savedPlaces: [SavedPlace] = []
    @State private var selectedCategory: PlaceCategory = .all
    @State private var showingAddPlace = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Category Filter
                categoryFilter
                
                // Content
                if savedPlaces.isEmpty {
                    emptyStateView
                } else {
                    placesList
                }
            }
            .navigationTitle("Saved Places")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlace = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(ShvilDesign.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddPlace) {
                AddPlaceSheet()
            }
            .onAppear {
                loadSavedPlaces()
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ShvilDesign.Colors.secondaryText)
            
            TextField("Search saved places", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.vertical, ShvilDesign.Spacing.sm)
        .background(ShvilDesign.Colors.secondaryBackground)
        .cornerRadius(ShvilDesign.CornerRadius.medium)
        .padding(.horizontal, ShvilDesign.Spacing.md)
        .padding(.top, ShvilDesign.Spacing.sm)
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ShvilDesign.Spacing.sm) {
                ForEach(PlaceCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(ShvilDesign.Animation.spring) {
                            selectedCategory = category
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
                
                Image(systemName: "star")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(ShvilDesign.Colors.primary)
            }
            
            VStack(spacing: ShvilDesign.Spacing.sm) {
                Text("No Saved Places")
                    .font(ShvilDesign.Typography.title2)
                    .foregroundColor(ShvilDesign.Colors.primaryText)
                
                Text("Save your favorite places for quick access")
                    .font(ShvilDesign.Typography.body)
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ShvilDesign.Spacing.xl)
            }
            
            // Add Place Button
            Button(action: { showingAddPlace = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Your First Place")
                }
                .font(ShvilDesign.Typography.bodyEmphasized)
                .foregroundColor(.white)
                .padding(.horizontal, ShvilDesign.Spacing.lg)
                .padding(.vertical, ShvilDesign.Spacing.md)
                .background(ShvilDesign.Colors.primary)
                .cornerRadius(ShvilDesign.CornerRadius.medium)
            }
            .padding(.top, ShvilDesign.Spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Places List
    private var placesList: some View {
        LazyVStack(spacing: ShvilDesign.Spacing.sm) {
            ForEach(filteredPlaces) { place in
                ModernSavedPlaceRow(place: place) {
                    // Handle tap
                } onDelete: {
                    deletePlace(place)
                }
            }
        }
        .padding(.horizontal, ShvilDesign.Spacing.md)
    }
    
    // MARK: - Computed Properties
    private var filteredPlaces: [SavedPlace] {
        var places = savedPlaces
        
        // Filter by category
        if selectedCategory != .all {
            places = places.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            places = places.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                place.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return places
    }
    
    // MARK: - Helper Methods
    private func loadSavedPlaces() {
        // Load from backend or local storage
        // For now, create some mock data
        savedPlaces = [
            SavedPlace(
                id: UUID(),
                name: "Home",
                address: "123 Main St, San Francisco, CA",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                category: .home,
                emoji: "🏠",
                createdAt: Date()
            ),
            SavedPlace(
                id: UUID(),
                name: "Work",
                address: "456 Market St, San Francisco, CA",
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                category: .work,
                emoji: "💼",
                createdAt: Date()
            ),
            SavedPlace(
                id: UUID(),
                name: "Favorite Coffee Shop",
                address: "789 Valencia St, San Francisco, CA",
                coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                category: .food,
                emoji: "☕",
                createdAt: Date()
            )
        ]
    }
    
    private func deletePlace(_ place: SavedPlace) {
        withAnimation(ShvilDesign.Animation.spring) {
            savedPlaces.removeAll { $0.id == place.id }
        }
    }
}

// MARK: - Saved Place Model
struct SavedPlace: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: PlaceCategory
    let emoji: String
    let createdAt: Date
}

// MARK: - Place Category
enum PlaceCategory: String, CaseIterable, Codable {
    case all = "all"
    case home = "home"
    case work = "work"
    case food = "food"
    case shopping = "shopping"
    case entertainment = "entertainment"
    case travel = "travel"
    case other = "other"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .home: return "Home"
        case .work: return "Work"
        case .food: return "Food"
        case .shopping: return "Shopping"
        case .entertainment: return "Entertainment"
        case .travel: return "Travel"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "star.fill"
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .food: return "fork.knife"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .travel: return "airplane"
        case .other: return "mappin.circle.fill"
        }
    }
}

// MARK: - Modern Saved Place Row
struct ModernSavedPlaceRow: View {
    let place: SavedPlace
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ShvilDesign.Spacing.md) {
                // Emoji Icon
                ZStack {
                    Circle()
                        .fill(ShvilDesign.Colors.primary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Text(place.emoji)
                        .font(.title2)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(place.name)
                            .font(ShvilDesign.Typography.bodyEmphasized)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        Spacer()
                        
                        Text(place.category.title)
                            .font(ShvilDesign.Typography.caption)
                            .foregroundColor(ShvilDesign.Colors.primary)
                            .padding(.horizontal, ShvilDesign.Spacing.sm)
                            .padding(.vertical, ShvilDesign.Spacing.xs)
                            .background(ShvilDesign.Colors.primary.opacity(0.1))
                            .cornerRadius(ShvilDesign.CornerRadius.small)
                    }
                    
                    Text(place.address)
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                        .lineLimit(2)
                }
                
                // Actions
                VStack(spacing: ShvilDesign.Spacing.xs) {
                    Button(action: {
                        // Navigate to place
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(ShvilDesign.Colors.primary)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(ShvilDesign.Colors.error)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(ShvilDesign.Spacing.md)
            .background(ShvilDesign.Colors.secondaryBackground)
            .cornerRadius(ShvilDesign.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Place Sheet
struct AddPlaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var placeName = ""
    @State private var selectedCategory: PlaceCategory = .other
    @State private var selectedEmoji = "📍"
    @State private var showingEmojiPicker = false
    
    let emojis = ["🏠", "💼", "☕", "🍕", "🛍️", "🎬", "✈️", "📍", "❤️", "⭐"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Place Details") {
                    TextField("Place name", text: $placeName)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PlaceCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.title)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Emoji") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: {
                                selectedEmoji = emoji
                            }) {
                                Text(emoji)
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedEmoji == emoji ? ShvilDesign.Colors.primary.opacity(0.2) : Color.clear)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save place
                        dismiss()
                    }
                    .disabled(placeName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ModernSavedPlacesView()
        .environmentObject(AuthenticationManager.shared)
}
