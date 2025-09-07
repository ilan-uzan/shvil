//
//  MapSearchBar.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct MapSearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let onSearch: (String) -> Void
    let onCancel: () -> Void
    
    @State private var showPopularSearches = false
    @State private var isFocused = false
    
    private let popularSearches = [
        PopularSearch(icon: "fuelpump.fill", title: "Gas Station", category: "Fuel"),
        PopularSearch(icon: "cart.fill", title: "Grocery Store", category: "Shopping"),
        PopularSearch(icon: "cup.and.saucer.fill", title: "Coffee Shop", category: "Food"),
        PopularSearch(icon: "fork.knife", title: "Restaurant", category: "Food"),
        PopularSearch(icon: "bed.double.fill", title: "Hotel", category: "Lodging"),
        PopularSearch(icon: "cross.fill", title: "Hospital", category: "Health"),
        PopularSearch(icon: "banknote.fill", title: "ATM", category: "Banking"),
        PopularSearch(icon: "car.fill", title: "Parking", category: "Transportation"),
        PopularSearch(icon: "building.2.fill", title: "Shopping Mall", category: "Shopping"),
        PopularSearch(icon: "leaf.fill", title: "Park", category: "Recreation")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: DesignTokens.Spacing.md) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignTokens.Text.tertiary)
                    
                    TextField("Search places...", text: $searchText)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.primary)
                        .onTapGesture {
                            isFocused = true
                            showPopularSearches = true
                        }
                        .onSubmit {
                            if !searchText.isEmpty {
                                onSearch(searchText)
                                showPopularSearches = false
                                isFocused = false
                            }
                        }
                        .onChange(of: searchText) { newValue in
                            if newValue.isEmpty {
                                showPopularSearches = isFocused
                            } else {
                                showPopularSearches = false
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            showPopularSearches = isFocused
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DesignTokens.Text.tertiary)
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Surface.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .stroke(isFocused ? DesignTokens.Brand.primary : DesignTokens.Glass.light, lineWidth: isFocused ? 2 : 1)
                        )
                        .shadow(
                            color: DesignTokens.Shadow.light.color,
                            radius: DesignTokens.Shadow.light.radius,
                            x: DesignTokens.Shadow.light.x,
                            y: DesignTokens.Shadow.light.y
                        )
                )
                
                if isFocused {
                    Button("Cancel") {
                        searchText = ""
                        isFocused = false
                        showPopularSearches = false
                        onCancel()
                    }
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Brand.primary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.md)
            
            // Popular Searches Dropdown
            if showPopularSearches {
                ScrollView {
                    LazyVStack(spacing: DesignTokens.Spacing.xs) {
                        ForEach(popularSearches) { search in
                            PopularSearchRow(search: search) {
                                searchText = search.title
                                onSearch(search.title)
                                showPopularSearches = false
                                isFocused = false
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Surface.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .stroke(DesignTokens.Glass.light, lineWidth: 1)
                        )
                        .shadow(
                            color: DesignTokens.Shadow.light.color,
                            radius: DesignTokens.Shadow.light.radius,
                            x: DesignTokens.Shadow.light.x,
                            y: DesignTokens.Shadow.light.y
                        )
                )
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.sm)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showPopularSearches)
            }
        }
        .onTapGesture {
            if !isFocused {
                isFocused = true
                showPopularSearches = true
            }
        }
    }
}

struct PopularSearch: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let category: String
}

struct PopularSearchRow: View {
    let search: PopularSearch
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: search.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(search.title)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(1)
                    
                    Text(search.category)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.tertiary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignTokens.Text.tertiary)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(isPressed ? DesignTokens.Surface.secondary : Color.clear)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DesignTokens.Surface.background
            .ignoresSafeArea()
        
        MapSearchBar(
            searchText: .constant(""),
            isSearching: .constant(false),
            onSearch: { _ in },
            onCancel: { }
        )
    }
}
