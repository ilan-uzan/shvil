//
//  SearchPill.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Glassmorphism search pill component with autocomplete
struct SearchPill: View {
    @Binding var searchText: String
    let onTap: () -> Void
    @StateObject private var searchService = DependencyContainer.shared.searchService
    @State private var isFocused = false
    @State private var showSuggestions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main search pill
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
                
                TextField("search_placeholder".localized, text: $searchText)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        onTap()
                        isFocused = true
                    }
                    .onChange(of: searchText) { _, newValue in
                        if !newValue.isEmpty {
                            searchService.getAutocompleteSuggestions(for: newValue)
                            showSuggestions = true
                        } else {
                            showSuggestions = false
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        showSuggestions = false
                        searchService.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(DesignTokens.Surface.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            
            // Autocomplete suggestions
            if showSuggestions && !searchService.autocompleteSuggestions.isEmpty {
                suggestionsList
            }
        }
    }
    
    private var suggestionsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(searchService.autocompleteSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                suggestionRow(suggestion)
                
                if let lastSuggestion = searchService.autocompleteSuggestions.last, suggestion.id != lastSuggestion.id {
                    Divider()
                        .background(DesignTokens.Surface.primary)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignTokens.Surface.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        )
        .padding(.top, 8)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
    
    private func suggestionRow(_ suggestion: SearchSuggestion) -> some View {
        Button(action: {
            searchService.selectSuggestion(suggestion)
            showSuggestions = false
            isFocused = false
        }) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.text)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(1)
                    
                    Text(suggestion.category ?? "Unknown")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Compact search pill for use in navigation bars
struct CompactSearchPill: View {
    @Binding var searchText: String
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignTokens.Text.secondary)
            
            Text("search_placeholder".localized)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignTokens.Surface.tertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onTapGesture {
            onTap()
        }
    }
}

/// Search pill with voice search capability
struct VoiceSearchPill: View {
    @Binding var searchText: String
    let onTap: () -> Void
    let onVoiceTap: () -> Void
    @State private var isListening = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.Text.secondary)
            
            TextField("search_placeholder".localized, text: $searchText)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
                .textFieldStyle(PlainTextFieldStyle())
                .onTapGesture {
                    onTap()
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }
            
            Button(action: {
                onVoiceTap()
                isListening.toggle()
                
                // Simulate listening state
                if isListening {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isListening = false
                    }
                }
            }) {
                Image(systemName: isListening ? "mic.fill" : "mic")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isListening ? DesignTokens.Semantic.error : DesignTokens.Brand.primary)
                    .scaleEffect(isListening ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isListening)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(DesignTokens.Surface.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

/// Search pill with category filter
struct CategorySearchPill: View {
    @Binding var searchText: String
    @Binding var selectedCategory: SearchCategory
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Main search pill
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
                
                TextField("search_placeholder".localized, text: $searchText)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        onTap()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(DesignTokens.Surface.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SearchCategory.allCases, id: \.self) { category in
                        categoryChip(category)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func categoryChip(_ category: SearchCategory) -> some View {
        Button(action: {
            selectedCategory = category
            HapticFeedback.shared.impact(style: .light)
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(category.displayName)
                    .font(DesignTokens.Typography.caption1)
            }
            .foregroundColor(selectedCategory == category ? .white : DesignTokens.Text.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedCategory == category ? 
                          AnyShapeStyle(DesignTokens.Brand.gradient) : 
                          AnyShapeStyle(DesignTokens.Surface.tertiary))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

