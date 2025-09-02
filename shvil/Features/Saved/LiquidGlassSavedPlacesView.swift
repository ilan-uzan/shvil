//
//  LiquidGlassSavedPlacesView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation

struct LiquidGlassSavedPlacesView: View {
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @EnvironmentObject private var navigationService: NavigationService
    @State private var selectedCategory: PlaceCategory = .all
    @State private var searchText = ""
    @State private var showAddPlace = false
    
    var body: some View {
        ZStack {
            // Background
            LiquidGlassDesign.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if supabaseManager.savedPlaces.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
        }
        .sheet(isPresented: $showAddPlace) {
            LiquidGlassAddPlaceView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: LiquidGlassDesign.Spacing.md) {
            // Title and Add Button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved Places")
                        .font(LiquidGlassDesign.Typography.largeTitle)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    Text("\(supabaseManager.savedPlaces.count) places saved")
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: { showAddPlace.toggle() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(LiquidGlassDesign.Colors.liquidBlue)
                                .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .liquidGlassGlow(color: LiquidGlassDesign.Colors.liquidBlue, radius: 12)
            }
            
            // Search Bar
            HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                
                TextField("Search saved places...", text: $searchText)
                    .font(LiquidGlassDesign.Typography.body)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            .padding(.vertical, LiquidGlassDesign.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 6, x: 0, y: 3)
            )
            
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
                ForEach(PlaceCategory.allCases, id: \.self) { category in
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
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: LiquidGlassDesign.Spacing.md) {
                ForEach(filteredPlaces, id: \.id) { place in
                    SavedPlaceCard(place: place) {
                        // Handle place selection
                    }
                }
            }
            .padding(.horizontal, LiquidGlassDesign.Spacing.md)
            .padding(.top, LiquidGlassDesign.Spacing.lg)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: LiquidGlassDesign.Spacing.xl) {
            Spacer()
            
            // Icon
            Image(systemName: "bookmark")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                .frame(width: 120, height: 120)
                .background(
                    Circle()
                        .fill(LiquidGlassDesign.Colors.glassWhite)
                        .shadow(color: LiquidGlassDesign.Shadows.light, radius: 20, x: 0, y: 10)
                )
            
            // Text
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Text("No Saved Places")
                    .font(LiquidGlassDesign.Typography.title2)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Text("Save your favorite places to access them quickly")
                    .font(LiquidGlassDesign.Typography.body)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Add Button
            LiquidGlassButton("Add Your First Place", icon: "plus", style: .primary) {
                showAddPlace.toggle()
            }
            
            Spacer()
        }
        .padding(.horizontal, LiquidGlassDesign.Spacing.xl)
    }
    
    // MARK: - Computed Properties
    private var filteredPlaces: [SavedPlace] {
        let places = supabaseManager.savedPlaces
        
        let categoryFiltered = selectedCategory == .all ? places : places.filter { $0.category == selectedCategory.rawValue }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Place Category
enum PlaceCategory: String, CaseIterable {
    case all = "all"
    case home = "home"
    case work = "work"
    case restaurant = "restaurant"
    case gas = "gas"
    case parking = "parking"
    case hotel = "hotel"
    case shopping = "shopping"
    case entertainment = "entertainment"
    case healthcare = "healthcare"
    case other = "other"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .home: return "Home"
        case .work: return "Work"
        case .restaurant: return "Food"
        case .gas: return "Gas"
        case .parking: return "Parking"
        case .hotel: return "Hotels"
        case .shopping: return "Shopping"
        case .entertainment: return "Fun"
        case .healthcare: return "Health"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .restaurant: return "fork.knife"
        case .gas: return "fuelpump.fill"
        case .parking: return "p.circle.fill"
        case .hotel: return "bed.double.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .healthcare: return "cross.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Saved Place Card
struct SavedPlaceCard: View {
    let place: SavedPlace
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(color: categoryColor.opacity(0.3), radius: 6, x: 0, y: 3)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(LiquidGlassDesign.Typography.headline)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .lineLimit(1)
                    
                    if let address = place.address {
                        Text(address)
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        Text(PlaceCategory(rawValue: place.category)?.title ?? "Other")
                            .font(LiquidGlassDesign.Typography.caption)
                            .foregroundColor(categoryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(categoryColor.opacity(0.1))
                            )
                        
                        if let distance = place.distance {
                            Text(distance)
                                .font(LiquidGlassDesign.Typography.caption)
                                .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: LiquidGlassDesign.Spacing.sm) {
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
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(LiquidGlassDesign.Colors.glassMedium)
                            )
                    }
                }
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryColor: Color {
        switch PlaceCategory(rawValue: place.category) {
        case .home: return LiquidGlassDesign.Colors.accentGreen
        case .work: return LiquidGlassDesign.Colors.accentOrange
        case .restaurant: return LiquidGlassDesign.Colors.accentRed
        case .gas: return LiquidGlassDesign.Colors.liquidBlue
        case .parking: return LiquidGlassDesign.Colors.accentPurple
        case .hotel: return LiquidGlassDesign.Colors.accentOrange
        case .shopping: return LiquidGlassDesign.Colors.accentPurple
        case .entertainment: return LiquidGlassDesign.Colors.accentRed
        case .healthcare: return LiquidGlassDesign.Colors.accentGreen
        default: return LiquidGlassDesign.Colors.textSecondary
        }
    }
    
    private var categoryIcon: String {
        PlaceCategory(rawValue: place.category)?.icon ?? "mappin.circle.fill"
    }
}

// MARK: - Add Place View
struct LiquidGlassAddPlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @State private var placeName = ""
    @State private var placeAddress = ""
    @State private var selectedCategory: PlaceCategory = .other
    @State private var selectedEmoji = "📍"
    
    let emojis = ["🏠", "🏢", "🍽️", "⛽", "🅿️", "🏨", "🛍️", "🎮", "🏥", "📍"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: LiquidGlassDesign.Spacing.lg) {
                // Emoji Selector
                VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
                    Text("Choose an emoji")
                        .font(LiquidGlassDesign.Typography.headline)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: LiquidGlassDesign.Spacing.sm) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: { selectedEmoji = emoji }) {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                                            .fill(selectedEmoji == emoji ? LiquidGlassDesign.Colors.liquidBlue.opacity(0.1) : LiquidGlassDesign.Colors.glassWhite)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                                                    .stroke(selectedEmoji == emoji ? LiquidGlassDesign.Colors.liquidBlue : Color.clear, lineWidth: 2)
                                            )
                                    )
                            }
                        }
                    }
                }
                
                // Form Fields
                VStack(spacing: LiquidGlassDesign.Spacing.md) {
                    VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
                        Text("Place Name")
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        
                        TextField("Enter place name", text: $placeName)
                            .font(LiquidGlassDesign.Typography.body)
                            .padding(LiquidGlassDesign.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                                    .fill(LiquidGlassDesign.Colors.glassWhite)
                                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
                        Text("Address")
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        
                        TextField("Enter address", text: $placeAddress)
                            .font(LiquidGlassDesign.Typography.body)
                            .padding(LiquidGlassDesign.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                                    .fill(LiquidGlassDesign.Colors.glassWhite)
                                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.sm) {
                        Text("Category")
                            .font(LiquidGlassDesign.Typography.callout)
                            .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: LiquidGlassDesign.Spacing.sm) {
                            ForEach(PlaceCategory.allCases.dropFirst(), id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 14, weight: .medium))
                                        Text(category.title)
                                            .font(LiquidGlassDesign.Typography.caption)
                                    }
                                    .foregroundColor(selectedCategory == category ? .white : LiquidGlassDesign.Colors.liquidBlue)
                                    .padding(.horizontal, LiquidGlassDesign.Spacing.sm)
                                    .padding(.vertical, LiquidGlassDesign.Spacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.sm)
                                            .fill(selectedCategory == category ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.glassWhite)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.sm)
                                                    .stroke(selectedCategory == category ? LiquidGlassDesign.Colors.liquidBlue : LiquidGlassDesign.Colors.glassMedium, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Save Button
                LiquidGlassButton("Save Place", icon: "checkmark", style: .primary) {
                    savePlace()
                }
                .disabled(placeName.isEmpty)
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func savePlace() {
        let newPlace = SavedPlace(
            id: UUID(),
            name: placeName,
            address: placeAddress.isEmpty ? nil : placeAddress,
            category: selectedCategory.rawValue,
            emoji: selectedEmoji,
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), // TODO: Get actual coordinate
            distance: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        Task {
            await supabaseManager.savePlace(newPlace)
            dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    LiquidGlassSavedPlacesView()
        .environmentObject(SupabaseManager.shared)
        .environmentObject(NavigationService.shared)
}
