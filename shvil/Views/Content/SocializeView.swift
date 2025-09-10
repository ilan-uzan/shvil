//
//  SocializeView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SocializeView: View {
    @State private var selectedFilter = "All"
    @State private var showCreateGroup = false
    
    private let filters = ["All", "Nearby", "Adventure", "Hiking", "City"]
    private let sampleGroups = [
        SocialGroup(name: "Jerusalem Explorers", members: 24, activity: "City Walk", distance: "2.3 km"),
        SocialGroup(name: "Tel Aviv Adventures", members: 18, activity: "Beach Run", distance: "5.1 km"),
        SocialGroup(name: "Mountain Hikers", members: 32, activity: "Hiking", distance: "12.4 km")
    ]
    
    var body: some View {
        ZStack {
            // Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Socialize")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Text("Connect with fellow adventurers")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                FilterPill(
                                    title: filter,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Groups List
                    LazyVStack(spacing: 16) {
                        ForEach(sampleGroups) { group in
                            SocialGroupCard(group: group)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Create Group Button
                    Button(action: {
                        showCreateGroup = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Create New Group")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .fill(DesignTokens.Brand.gradient)
                                .shadow(DesignTokens.Shadow.medium)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct SocialGroup: Identifiable {
    let id = UUID()
    let name: String
    let members: Int
    let activity: String
    let distance: String
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : DesignTokens.Text.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(isSelected ? DesignTokens.Brand.primary : DesignTokens.Surface.secondary)
                        .shadow(DesignTokens.Shadow.light)
                )
        }
    }
}

struct SocialGroupCard: View {
    let group: SocialGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text("\(group.members) members")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(group.activity)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    Text(group.distance)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignTokens.Text.tertiary)
                }
            }
            
            HStack {
                Button("Join") {
                    // Join group action
                }
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .fill(DesignTokens.Brand.primary)
                )
                
                Spacer()
                
                Button("View Details") {
                    // View details action
                }
                .foregroundColor(DesignTokens.Brand.primary)
                .font(.system(size: 14, weight: .medium))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .shadow(DesignTokens.Shadow.light)
        )
    }
}

#Preview {
    SocializeView()
}