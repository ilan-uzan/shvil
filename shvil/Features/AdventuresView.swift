//
//  AdventuresView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation

struct AdventuresView: View {
    @ObservedObject private var adventureKit = DependencyContainer.shared.adventureKit
    @ObservedObject private var locationService = DependencyContainer.shared.locationService
    @State private var showingCreateAdventure = false
    @State private var selectedAdventure: AdventurePlan?
    @State private var showingAdventureDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LiquidGlassBackground()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Header
                        headerView
                        
                        // Quick Actions
                        quickActionsView
                        
                        // Active Adventures
                        if !adventureKit.activeAdventures.isEmpty {
                            activeAdventuresSection
                        }
                        
                        // Recent Adventures
                        if !adventureKit.recentAdventures.isEmpty {
                            recentAdventuresSection
                        }
                        
                        // Empty State
                        if adventureKit.activeAdventures.isEmpty && adventureKit.recentAdventures.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Adventures")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateAdventure = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(LiquidGlassColors.accentText)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateAdventure) {
            AdventureSetupView()
        }
        .sheet(isPresented: $showingAdventureDetails) {
            if let adventure = selectedAdventure {
                AdventureDetailView(adventure: adventure)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Discover Your Next Adventure")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            Text("AI-powered adventures tailored to your interests")
                .font(.subheadline)
                .foregroundColor(LiquidGlassColors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            QuickActionCard(
                title: "Quick Adventure",
                subtitle: "Start exploring now",
                icon: "star.fill",
                color: LiquidGlassColors.accentText
            ) {
                showingCreateAdventure = true
            }
            
            QuickActionCard(
                title: "Nearby Spots",
                subtitle: "Discover local gems",
                icon: "location.fill",
                color: LiquidGlassColors.primaryText
            ) {
                // Navigate to nearby spots
            }
        }
    }
    
    // MARK: - Active Adventures Section
    
    private var activeAdventuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Adventures")
                    .font(.headline)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all active adventures
                }
                .font(.caption)
                .foregroundColor(LiquidGlassColors.accentText)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(adventureKit.activeAdventures) { adventure in
                        AdventureCard(adventure: adventure) {
                            selectedAdventure = adventure
                            showingAdventureDetails = true
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Recent Adventures Section
    
    private var recentAdventuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Adventures")
                    .font(.headline)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all recent adventures
                }
                .font(.caption)
                .foregroundColor(LiquidGlassColors.accentText)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(adventureKit.recentAdventures.prefix(3)) { adventure in
                    AdventureRow(adventure: adventure) {
                        selectedAdventure = adventure
                        showingAdventureDetails = true
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundColor(LiquidGlassColors.secondaryText)
            
            Text("No Adventures Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            Text("Create your first adventure to start exploring")
                .font(.body)
                .foregroundColor(LiquidGlassColors.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Create Adventure") {
                showingCreateAdventure = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LiquidGlassColors.glassBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdventureCard: View {
    let adventure: AdventurePlan
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(adventure.title)
                        .font(.headline)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                
                Text(adventure.description ?? "No description")
                    .font(.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .lineLimit(2)
                
                HStack {
                    Label("\(adventure.totalDuration) min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Spacer()
                    
                    Label("\(adventure.totalDistance, specifier: "%.1f") km", systemImage: "location")
                        .font(.caption2)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
            }
            .padding()
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LiquidGlassColors.glassSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LiquidGlassColors.glassBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Placeholder Views

struct AdventureRow: View {
    let adventure: AdventurePlan
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(ShvilColors.accentPrimary)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(adventure.title)
                        .font(.subheadline)
                        .foregroundColor(ShvilColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(adventure.description)
                        .font(.caption)
                        .foregroundColor(ShvilColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(adventure.totalDuration) min")
                        .font(.caption2)
                        .foregroundColor(ShvilColors.textSecondary)
                    
                    Text("\(adventure.totalDistance, specifier: "%.1f") km")
                        .font(.caption2)
                        .foregroundColor(ShvilColors.textSecondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdventureDetailView: View {
    let adventure: AdventurePlan
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text(adventure.title)
                    .font(.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Text(adventure.description)
                    .font(.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Adventure Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AdventuresView()
}
