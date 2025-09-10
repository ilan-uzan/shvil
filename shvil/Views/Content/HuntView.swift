//
//  HuntView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct HuntView: View {
    @State private var selectedCategory = "All"
    @State private var showFilters = false
    @StateObject private var huntService = DependencyContainer.shared.huntService
    
    private let categories = ["All", "Landmarks", "Nature", "History", "Culture", "Food"]
    
    var body: some View {
        ZStack {
            // Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Hunt")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Text("Discover hidden gems and earn points")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Category Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryPill(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Stats Card
                    HStack(spacing: 16) {
                        StatCard(title: "Points", value: "1,250", icon: "star.fill")
                        StatCard(title: "Hunts", value: "12", icon: "flag.fill")
                        StatCard(title: "Streak", value: "7 days", icon: "flame.fill")
                    }
                    .padding(.horizontal, 20)
                    
                    // Hunts List
                    if huntService.isLoading {
                        VStack(spacing: 16) {
                            ForEach(0..<3) { _ in
                                HuntCardSkeleton()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    } else if huntService.hunts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "flag.circle")
                                .font(.system(size: 48))
                                .foregroundColor(DesignTokens.Text.tertiary)
                            
                            Text("No Hunts Available")
                                .font(DesignTokens.Typography.title3)
                                .foregroundColor(DesignTokens.Text.secondary)
                            
                            Text("Check back later for new scavenger hunts")
                                .font(DesignTokens.Typography.body)
                                .foregroundColor(DesignTokens.Text.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(huntService.hunts) { hunt in
                                HuntCard(hunt: hunt)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
}

struct HuntCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.tertiary)
                        .frame(width: 120, height: 18)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.quaternary)
                        .frame(width: 60, height: 12)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.tertiary)
                        .frame(width: 80, height: 16)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.Text.quaternary)
                        .frame(width: 60, height: 12)
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .appleShadow(DesignTokens.Shadow.light)
        )
        .redacted(reason: .placeholder)
    }
}

struct CategoryPill: View {
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(DesignTokens.Brand.primary)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignTokens.Text.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignTokens.Text.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .appleShadow(DesignTokens.Shadow.light)
        )
    }
}

struct HuntCard: View {
    let hunt: ScavengerHunt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hunt.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text(hunt.status.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                                .fill(DesignTokens.Brand.primary.opacity(0.1))
                        )
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(hunt.checkpointCount) checkpoints")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    Text("\(hunt.participantCount) participants")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignTokens.Text.tertiary)
                }
            }
            
            HStack {
                Label("\(hunt.checkpointCount) checkpoints", systemImage: "flag")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
                
                Spacer()
                
                Button("Start Hunt") {
                    // Start hunt action
                }
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                        .fill(DesignTokens.Brand.gradient)
                        .appleShadow(DesignTokens.Shadow.light)
                )
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

#Preview {
    HuntView()
}