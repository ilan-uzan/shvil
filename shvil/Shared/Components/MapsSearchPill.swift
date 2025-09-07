//
//  MapsSearchPill.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Rounded search pill for the maps page with Shvil logo, search text, voice option, and profile button
struct MapsSearchPill: View {
    @State private var searchText: String = ""
    @State private var isSearchFocused: Bool = false
    @State private var showingProfile: Bool = false
    @State private var isVoiceSearching: Bool = false
    
    let onSearch: (String) -> Void
    let onVoiceSearch: () -> Void
    let dynamicTextColor: Color
    let dynamicIconColor: Color
    
    init(onSearch: @escaping (String) -> Void, 
         onVoiceSearch: @escaping () -> Void,
         dynamicTextColor: Color = DesignTokens.Text.primary,
         dynamicIconColor: Color = Color.gray.opacity(0.6)) {
        self.onSearch = onSearch
        self.onVoiceSearch = onVoiceSearch
        self.dynamicTextColor = dynamicTextColor
        self.dynamicIconColor = dynamicIconColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Shvil logo
            ShvilLogo(size: 20, showGlow: false)
            
            // Search text field
            searchTextField
            
            // Voice search button
            voiceSearchButton
            
            // Profile button
            profileButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            // Liquid glass background
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .saturation(1.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .sheet(isPresented: $showingProfile) {
            ProfileStatsView()
        }
    }
    
    private var searchTextField: some View {
        HStack {
            TextField("Search here", text: $searchText)
                .font(DesignTokens.Typography.body)
                .foregroundColor(dynamicTextColor)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSearch(searchText)
                    }
                }
                .onTapGesture {
                    isSearchFocused = true
                }
                .onChange(of: searchText) { _, newValue in
                    // Auto-search as user types (with debouncing)
                    if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if searchText == newValue { // Only search if text hasn't changed
                                onSearch(newValue)
                            }
                        }
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearchFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(dynamicIconColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var voiceSearchButton: some View {
        Button(action: {
            performVoiceSearch()
        }) {
            ZStack {
                Circle()
                    .fill(
                        isVoiceSearching ? 
                        DesignTokens.Brand.primary :
                        DesignTokens.Surface.secondary
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: isVoiceSearching ? "mic.fill" : "mic")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                        isVoiceSearching ? 
                        .white : 
                        dynamicIconColor
                    )
            }
        }
        .scaleEffect(isVoiceSearching ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isVoiceSearching)
    }
    
    private var profileButton: some View {
        Button(action: {
            showingProfile = true
        }) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Surface.secondary)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(dynamicIconColor)
            }
        }
    }
    
    private func performVoiceSearch() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isVoiceSearching = true
        }
        
        // Simulate voice search
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isVoiceSearching = false
            }
            
            // Mock voice search result
            searchText = "Gas station near me"
            onSearch(searchText)
        }
        
        onVoiceSearch()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        MapsSearchPill(
            onSearch: { text in
                print("Search: \(text)")
            },
            onVoiceSearch: {
                print("Voice search activated")
            }
        )
        
        MapsSearchPill(
            onSearch: { text in
                print("Search: \(text)")
            },
            onVoiceSearch: {
                print("Voice search activated")
            }
        )
        .environment(\.colorScheme, .dark)
    }
    .padding()
    .background(DesignTokens.Surface.background)
}
