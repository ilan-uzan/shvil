//
//  SavedPlacesView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct SavedPlacesView: View {
    @State private var savedPlaces: [SavedPlace] = []
    @State private var collections: [PlaceCollection] = []
    @State private var searchText = ""
    @State private var selectedCollection: PlaceCollection?
    @State private var showAddCollection = false
    @State private var showPlaceDetails = false
    @State private var selectedPlace: SavedPlace?
    
    // Sample data for demonstration
    @State private var samplePlaces: [SavedPlace] = [
        SavedPlace(
            id: UUID(),
            name: "Home",
            address: "123 Main Street, San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            type: .home,
            createdAt: Date(),
            userId: UUID()
        ),
        SavedPlace(
            id: UUID(),
            name: "Work Office",
            address: "456 Market Street, San Francisco, CA",
            latitude: 37.7849,
            longitude: -122.4094,
            type: .work,
            createdAt: Date(),
            userId: UUID()
        ),
        SavedPlace(
            id: UUID(),
            name: "Blue Bottle Coffee",
            address: "789 Valencia Street, San Francisco, CA",
            latitude: 37.7649,
            longitude: -122.4294,
            type: .favorite,
            createdAt: Date(),
            userId: UUID()
        ),
        SavedPlace(
            id: UUID(),
            name: "Golden Gate Park",
            address: "Golden Gate Park, San Francisco, CA",
            latitude: 37.7694,
            longitude: -122.4862,
            type: .custom,
            createdAt: Date(),
            userId: UUID()
        )
    ]
    
    @State private var sampleCollections: [PlaceCollection] = [
        PlaceCollection(
            id: UUID(),
            name: "Coffee Shops",
            color: .orange,
            places: []
        ),
        PlaceCollection(
            id: UUID(),
            name: "Restaurants",
            color: .red,
            places: []
        ),
        PlaceCollection(
            id: UUID(),
            name: "Parks",
            color: .green,
            places: []
        )
    ]
    
    var filteredPlaces: [SavedPlace] {
        if searchText.isEmpty {
            return samplePlaces
        } else {
            return samplePlaces.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                place.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    SearchPill(searchText: $searchText) {
                        // Search focused
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    if !searchText.isEmpty {
                        // Search Results
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPlaces) { place in
                                    SavedPlaceRow(place: place) {
                                        selectedPlace = place
                                        showPlaceDetails = true
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    } else {
                        // Main Content
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                // Quick Access Section
                                QuickAccessSection(places: samplePlaces) { place in
                                    selectedPlace = place
                                    showPlaceDetails = true
                                }
                                
                                // Collections Section
                                CollectionsSection(
                                    collections: sampleCollections,
                                    onCollectionTap: { collection in
                                        selectedCollection = collection
                                    },
                                    onAddCollection: {
                                        showAddCollection = true
                                    }
                                )
                                
                                // All Places Section
                                AllPlacesSection(places: samplePlaces) { place in
                                    selectedPlace = place
                                    showPlaceDetails = true
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    }
                }
                
                Spacer()
            }
            .background(LiquidGlassColors.mapBase)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddCollection) {
            AddCollectionView { collection in
                sampleCollections.append(collection)
            }
        }
        .sheet(isPresented: $showPlaceDetails) {
            if let place = selectedPlace {
                PlaceDetailsView(
                    place: SearchResult(
                        name: place.name,
                        subtitle: place.type.rawValue.capitalized,
                        address: place.address,
                        coordinate: place.coordinate
                    ),
                    isPresented: $showPlaceDetails
                )
            }
        }
    }
}

// MARK: - Quick Access Section
struct QuickAccessSection: View {
    let places: [SavedPlace]
    let onPlaceTap: (SavedPlace) -> Void
    
    var homePlace: SavedPlace? {
        places.first { $0.type == .home }
    }
    
    var workPlace: SavedPlace? {
        places.first { $0.type == .work }
    }
    
    var favoritePlaces: [SavedPlace] {
        places.filter { $0.type == .favorite }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Access")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            HStack(spacing: 12) {
                if let home = homePlace {
                    QuickAccessCard(
                        title: "Home",
                        subtitle: home.name,
                        icon: "house.fill",
                        color: LiquidGlassColors.accentText
                    ) {
                        onPlaceTap(home)
                    }
                }
                
                if let work = workPlace {
                    QuickAccessCard(
                        title: "Work",
                        subtitle: work.name,
                        icon: "building.2.fill",
                        color: LiquidGlassColors.accentDeepAqua
                    ) {
                        onPlaceTap(work)
                    }
                }
            }
            
            if !favoritePlaces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Favorites")
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(favoritePlaces.prefix(4)) { place in
                            FavoriteCard(place: place) {
                                onPlaceTap(place)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Quick Access Card
struct QuickAccessCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Text(subtitle)
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassColors.glassSurface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Favorite Card
struct FavoriteCard: View {
    let place: SavedPlace
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.pink)
                
                Text(place.name)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Collections Section
struct CollectionsSection: View {
    let collections: [PlaceCollection]
    let onCollectionTap: (PlaceCollection) -> Void
    let onAddCollection: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Collections")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button(action: onAddCollection) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(LiquidGlassColors.accentText)
                }
                .accessibilityLabel("Add Collection")
            }
            
            if collections.isEmpty {
                EmptyCollectionView {
                    onAddCollection()
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(collections) { collection in
                        CollectionCard(collection: collection) {
                            onCollectionTap(collection)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Collection Card
struct CollectionCard: View {
    let collection: PlaceCollection
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 20))
                        .foregroundColor(collection.color)
                    
                    Spacer()
                    
                    Text("\(collection.places.count)")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(collection.color.opacity(0.2))
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)
                    
                    Text("\(collection.places.count) places")
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassColors.glassSurface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Empty Collection View
struct EmptyCollectionView: View {
    let onAddCollection: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 40))
                .foregroundColor(LiquidGlassColors.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Collections Yet")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Text("Create collections to organize your places")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddCollection) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Collection")
                }
                .font(LiquidGlassTypography.bodySemibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(LiquidGlassGradients.primaryGradient)
                .cornerRadius(20)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - All Places Section
struct AllPlacesSection: View {
    let places: [SavedPlace]
    let onPlaceTap: (SavedPlace) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Places")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            LazyVStack(spacing: 12) {
                ForEach(places) { place in
                    SavedPlaceRow(place: place) {
                        onPlaceTap(place)
                    }
                }
            }
        }
    }
}

// MARK: - Saved Place Row
struct SavedPlaceRow: View {
    let place: SavedPlace
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Place Icon
                Image(systemName: placeIcon)
                    .font(.system(size: 24))
                    .foregroundColor(placeColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(place.address)
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    // Route Button
                    Button(action: {
                        print("Route to \(place.name)")
                    }) {
                        Image(systemName: "arrow.turn.up.right")
                            .font(.system(size: 16))
                            .foregroundColor(LiquidGlassColors.accentText)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(LiquidGlassColors.accentText.opacity(0.1))
                            )
                    }
                    .accessibilityLabel("Route to \(place.name)")
                    
                    // Type Badge
                    Text(placeTypeText)
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(placeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(placeColor.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassColors.glassSurface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(LiquidGlassAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var placeIcon: String {
        switch place.type {
        case .home: return "house.fill"
        case .work: return "building.2.fill"
        case .favorite: return "heart.fill"
        case .custom: return "location.fill"
        }
    }
    
    private var placeColor: Color {
        switch place.type {
        case .home: return LiquidGlassColors.accentText
        case .work: return LiquidGlassColors.accentDeepAqua
        case .favorite: return Color.pink
        case .custom: return LiquidGlassColors.secondaryText
        }
    }
    
    private var placeTypeText: String {
        switch place.type {
        case .home: return "HOME"
        case .work: return "WORK"
        case .favorite: return "FAV"
        case .custom: return "CUSTOM"
        }
    }
}

// MARK: - Place Collection Model
struct PlaceCollection: Identifiable {
    let id: UUID
    let name: String
    let color: Color
    var places: [SavedPlace]
    
    init(id: UUID = UUID(), name: String, color: Color, places: [SavedPlace] = []) {
        self.id = id
        self.name = name
        self.color = color
        self.places = places
    }
}

// MARK: - Add Collection View
struct AddCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName = ""
    @State private var selectedColor: Color = .blue
    
    let onSave: (PlaceCollection) -> Void
    
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Collection Name")
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    TextField("Enter collection name", text: $collectionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(LiquidGlassTypography.body)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Color")
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let collection = PlaceCollection(
                            name: collectionName,
                            color: selectedColor
                        )
                        onSave(collection)
                        dismiss()
                    }
                    .disabled(collectionName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SavedPlacesView()
        .background(Color.black)
}
