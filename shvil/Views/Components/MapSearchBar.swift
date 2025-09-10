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
    
    @State private var isFocused = false
    
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
                        }
                        .onSubmit {
                            if !searchText.isEmpty {
                                onSearch(searchText)
                                isFocused = false
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
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
                        onCancel()
                    }
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Brand.primary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.md)
        }
        .onTapGesture {
            if !isFocused {
                isFocused = true
            }
        }
    }
}


