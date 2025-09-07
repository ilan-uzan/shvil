//
//  SavedPlacesView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct SavedPlacesView: View {
    @State private var savedPlaces: [SavedPlace] = []
    @State private var collections: [PlaceCollection] = []
    @State private var searchText = ""
    @State private var selectedCollection: PlaceCollection?
    @State private var showAddCollection = false
    @State private var showPlaceDetails = false
    @State private var selectedPlace: SavedPlace?

    @State private var samplePlaces: [SavedPlace] = []
    @State private var sampleCollections: [PlaceCollection] = []

    var filteredPlaces: [SavedPlace] {
        if searchText.isEmpty {
            samplePlaces
        } else {
            samplePlaces.filter { place in
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
            .background(AppleColors.background)
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
                        address: place.address,
                        latitude: place.latitude,
                        longitude: place.longitude
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
        places.first { $0.placeType == .home }
    }

    var workPlace: SavedPlace? {
        places.first { $0.placeType == .work }
    }

    var favoritePlaces: [SavedPlace] {
        places.filter { $0.placeType == .favorite }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Access")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            HStack(spacing: 12) {
                if let home = homePlace {
                    QuickAccessCard(
                        title: "Home",
                        subtitle: home.name,
                        icon: "house.fill",
                        color: AppleColors.brandPrimary
                    ) {
                        onPlaceTap(home)
                    }
                }

                if let work = workPlace {
                    QuickAccessCard(
                        title: "Work",
                        subtitle: work.name,
                        icon: "building.2.fill",
                        color: AppleColors.brandPrimary
                    ) {
                        onPlaceTap(work)
                    }
                }
            }

            if !favoritePlaces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Favorites")
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)

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
                        .foregroundColor(AppleColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)

                    Text(subtitle)
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppleColors.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
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
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textPrimary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppleColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
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
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                Spacer()

                Button(action: onAddCollection) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppleColors.brandPrimary)
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
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(collection.color.opacity(0.2))
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)

                    Text("\(collection.places.count) places")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppleColors.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
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
                .foregroundColor(AppleColors.textSecondary.opacity(0.6))

            VStack(spacing: 8) {
                Text("No Collections Yet")
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                Text("Create collections to organize your places")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onAddCollection) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Collection")
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppleColors.brandGradient)
                .cornerRadius(20)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppleColors.surfaceSecondary)
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
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

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
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(place.address)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
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
                            .foregroundColor(AppleColors.brandPrimary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(AppleColors.brandPrimary.opacity(0.1))
                            )
                    }
                    .accessibilityLabel("Route to \(place.name)")

                    // Type Badge
                    Text(placeTypeText)
                        .font(AppleTypography.caption1)
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
                    .fill(AppleColors.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    private var placeIcon: String {
        switch place.placeType {
        case .home: "house.fill"
        case .work: "building.2.fill"
        case .favorite: "heart.fill"
        case .other: "location.fill"
        }
    }

    private var placeColor: Color {
        switch place.placeType {
        case .home: AppleColors.brandPrimary
        case .work: AppleColors.brandPrimary
        case .favorite: Color.pink
        case .other: AppleColors.textSecondary
        }
    }

    private var placeTypeText: String {
        switch place.placeType {
        case .home: "HOME"
        case .work: "WORK"
        case .favorite: "FAV"
        case .other: "OTHER"
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
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)

                    TextField("Enter collection name", text: $collectionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(AppleTypography.body)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Color")
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)

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
