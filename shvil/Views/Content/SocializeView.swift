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
    @StateObject private var socialService = DependencyContainer.shared.socialService
    
    private let filters = ["All", "Nearby", "Adventure", "Hiking", "City"]
    
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
                    if socialService.isLoading {
                        VStack(spacing: 16) {
                            ForEach(0..<3) { _ in
                                SocialGroupCardSkeleton()
                            }
                        }
                        .padding(.horizontal, 20)
                    } else if socialService.groups.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3")
                                .font(.system(size: 48))
                                .foregroundColor(DesignTokens.Text.tertiary)
                            
                            Text("No Groups Available")
                                .font(DesignTokens.Typography.title3)
                                .foregroundColor(DesignTokens.Text.secondary)
                            
                            Text("Create a group or join an existing one to get started")
                                .font(DesignTokens.Typography.body)
                                .foregroundColor(DesignTokens.Text.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(socialService.groups) { group in
                                SocialGroupCard(group: group)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
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
                                .appleShadow(DesignTokens.Shadow.medium)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
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
                        .appleShadow(DesignTokens.Shadow.light)
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
                    
                    Text("\(group.memberCount) members")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(group.description ?? "Adventure")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    Text("Active")
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
                .appleShadow(DesignTokens.Shadow.light)
        )
    }
}

struct SocialGroupCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.tertiary)
                        .frame(width: 140, height: 18)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.quaternary)
                        .frame(width: 80, height: 14)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.tertiary)
                        .frame(width: 60, height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.quaternary)
                        .frame(width: 40, height: 12)
                }
            }
            
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.Text.quaternary)
                    .frame(width: 100, height: 14)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.Brand.primary.opacity(0.3))
                    .frame(width: 80, height: 32)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .appleShadow(DesignTokens.Shadow.light)
        )
        .redacted(reason: .placeholder)
    }
}

#Preview {
    SocializeView()
}
