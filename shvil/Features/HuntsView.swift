//
//  HuntsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation

struct HuntsView: View {
    @ObservedObject private var socialKit = DependencyContainer.shared.socialKit
    @ObservedObject private var locationService = DependencyContainer.shared.locationService
    @State private var showingCreateHunt = false
    @State private var selectedHunt: ScavengerHunt?
    @State private var showingHuntDetails = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LiquidGlassBackground()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Header
                        headerView
                        
                        // Search Bar
                        searchBarView
                        
                        // Quick Actions
                        quickActionsView
                        
                        // Active Hunts
                        if !socialKit.activeHunts.isEmpty {
                            activeHuntsSection
                        }
                        
                        // Available Hunts
                        if !socialKit.availableHunts.isEmpty {
                            availableHuntsSection
                        }
                        
                        // My Hunts
                        if !socialKit.myHunts.isEmpty {
                            myHuntsSection
                        }
                        
                        // Empty State
                        if socialKit.activeHunts.isEmpty && socialKit.availableHunts.isEmpty && socialKit.myHunts.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Hunts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateHunt = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(LiquidGlassColors.accentText)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateHunt) {
            CreateHuntView()
        }
        .sheet(isPresented: $showingHuntDetails) {
            if let hunt = selectedHunt {
                HuntDetailView(hunt: hunt)
            }
        }
        .onAppear {
            Task {
                await socialKit.loadHunts()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scavenger Hunts")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            Text("Join community hunts or create your own")
                .font(.subheadline)
                .foregroundColor(LiquidGlassColors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Search Bar
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LiquidGlassColors.secondaryText)
            
            TextField("Search hunts...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(LiquidGlassColors.primaryText)
        }
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
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            QuickActionCard(
                title: "Create Hunt",
                subtitle: "Start a new hunt",
                icon: "target",
                color: LiquidGlassColors.accentText
            ) {
                showingCreateHunt = true
            }
            
            QuickActionCard(
                title: "Join Hunt",
                subtitle: "Enter hunt code",
                icon: "qrcode",
                color: LiquidGlassColors.primaryText
            ) {
                // Show QR code scanner
            }
        }
    }
    
    // MARK: - Active Hunts Section
    
    private var activeHuntsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Hunts")
                    .font(.headline)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all active hunts
                }
                .font(.caption)
                .foregroundColor(LiquidGlassColors.accentText)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(socialKit.activeHunts) { hunt in
                        HuntCard(hunt: hunt) {
                            selectedHunt = hunt
                            showingHuntDetails = true
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Available Hunts Section
    
    private var availableHuntsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Hunts")
                    .font(.headline)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all available hunts
                }
                .font(.caption)
                .foregroundColor(LiquidGlassColors.accentText)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(socialKit.availableHunts.prefix(3)) { hunt in
                    HuntRow(hunt: hunt) {
                        selectedHunt = hunt
                        showingHuntDetails = true
                    }
                }
            }
        }
    }
    
    // MARK: - My Hunts Section
    
    private var myHuntsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Hunts")
                    .font(.headline)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all my hunts
                }
                .font(.caption)
                .foregroundColor(LiquidGlassColors.accentText)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(socialKit.myHunts.prefix(3)) { hunt in
                    HuntRow(hunt: hunt) {
                        selectedHunt = hunt
                        showingHuntDetails = true
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(LiquidGlassColors.secondaryText)
            
            Text("No Hunts Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            Text("Create your first hunt or join an existing one")
                .font(.body)
                .foregroundColor(LiquidGlassColors.secondaryText)
                .multilineTextAlignment(.center)
            
                Button("Create Hunt") {
                    showingCreateHunt = true
                }
                .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Supporting Views

struct HuntCard: View {
    let hunt: ScavengerHunt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(hunt.name)
                        .font(.headline)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                }
                
                Text(hunt.description)
                    .font(.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .lineLimit(2)
                
                HStack {
                    Label("\(hunt.currentParticipants)/\(hunt.maxParticipants)", systemImage: "person.2")
                        .font(.caption2)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                    
                    Spacer()
                    
                    Text(hunt.status.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundColor(LiquidGlassColors.accentText)
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

struct CreateHuntView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create Hunt View")
                    .font(.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Text("This view will allow users to create new scavenger hunts")
                    .font(.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Create Hunt")
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
}

struct HuntRow: View {
    let hunt: ScavengerHunt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .foregroundColor(ShvilColors.accentSecondary)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(hunt.name)
                        .font(.subheadline)
                        .foregroundColor(ShvilColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(hunt.description)
                        .font(.caption)
                        .foregroundColor(ShvilColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(hunt.currentParticipants)/\(hunt.maxParticipants)")
                        .font(.caption2)
                        .foregroundColor(ShvilColors.textSecondary)
                    
                    Text(hunt.status.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundColor(ShvilColors.accentSecondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HuntDetailView: View {
    let hunt: ScavengerHunt
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text(hunt.name)
                    .font(.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Text(hunt.description)
                    .font(.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Hunt Details")
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
    HuntsView()
}
