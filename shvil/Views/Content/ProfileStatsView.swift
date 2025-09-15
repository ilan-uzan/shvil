//
//  ProfileStatsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Profile stats view showing user contributions and achievements
/// Similar to Waze's profile system with road reports, hunts, adventures, and business contributions
struct ProfileStatsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userStats = ProfileUserStats.mockData()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with profile info
                    profileHeader
                    
                    // Stats sections
                    VStack(spacing: 20) {
                        roadContributionStats
                        adventureStats
                        businessContributionStats
                        achievementBadges
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
            }
            .background(DesignTokens.Surface.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Brand.primary)
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile avatar with Shvil logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Brand.primary,
                                DesignTokens.Brand.primaryMid
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                ShvilLogo(size: 40, showGlow: false)
            }
            .shadow(
                color: DesignTokens.Brand.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            
            // User info
            VStack(spacing: 4) {
                Text("Shvil Explorer")
                    .font(DesignTokens.Typography.title2)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("Level \(userStats.level) • \(userStats.totalPoints) points")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
        }
    }
    
    private var roadContributionStats: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(DesignTokens.Semantic.warning)
                        .font(.title2)
                    
                    Text("Road Contributions")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatItem(
                        title: "Stopped Vehicles",
                        value: "\(userStats.stoppedVehicles)",
                        icon: "car.circle.fill",
                        color: DesignTokens.Semantic.warning
                    )
                    
                    StatItem(
                        title: "Police Signals",
                        value: "\(userStats.policeSignals)",
                        icon: "exclamationmark.triangle.fill",
                        color: DesignTokens.Semantic.error
                    )
                    
                    StatItem(
                        title: "Hazards",
                        value: "\(userStats.hazards)",
                        icon: "exclamationmark.octagon.fill",
                        color: DesignTokens.Semantic.error
                    )
                    
                    StatItem(
                        title: "Traffic Jams",
                        value: "\(userStats.trafficJams)",
                        icon: "car.2.fill",
                        color: DesignTokens.Semantic.warning
                    )
                }
            }
            .padding(20)
        }
    }
    
    private var adventureStats: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(DesignTokens.Brand.primary)
                        .font(.title2)
                    
                    Text("Adventures & Hunts")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatItem(
                        title: "Hunts Completed",
                        value: "\(userStats.huntsCompleted)",
                        icon: "flag.circle.fill",
                        color: DesignTokens.Brand.primary
                    )
                    
                    StatItem(
                        title: "Adventures",
                        value: "\(userStats.adventuresCompleted)",
                        icon: "sparkles",
                        color: DesignTokens.Brand.primaryMid
                    )
                    
                    StatItem(
                        title: "Places Visited",
                        value: "\(userStats.placesVisited)",
                        icon: "location.fill",
                        color: DesignTokens.Semantic.success
                    )
                    
                    StatItem(
                        title: "Checkpoints",
                        value: "\(userStats.checkpointsFound)",
                        icon: "checkmark.circle.fill",
                        color: DesignTokens.Semantic.success
                    )
                }
            }
            .padding(20)
        }
    }
    
    private var businessContributionStats: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(DesignTokens.Semantic.success)
                        .font(.title2)
                    
                    Text("Local Business Support")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatItem(
                        title: "Reviews Written",
                        value: "\(userStats.businessReviews)",
                        icon: "star.fill",
                        color: DesignTokens.Semantic.warning
                    )
                    
                    StatItem(
                        title: "Photos Shared",
                        value: "\(userStats.businessPhotos)",
                        icon: "camera.fill",
                        color: DesignTokens.Brand.primary
                    )
                    
                    StatItem(
                        title: "Tips Added",
                        value: "\(userStats.businessTips)",
                        icon: "lightbulb.fill",
                        color: DesignTokens.Semantic.info
                    )
                    
                    StatItem(
                        title: "Businesses Helped",
                        value: "\(userStats.businessesHelped)",
                        icon: "hand.raised.fill",
                        color: DesignTokens.Semantic.success
                    )
                }
            }
            .padding(20)
        }
    }
    
    private var achievementBadges: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "medal.fill")
                        .foregroundColor(DesignTokens.Semantic.warning)
                        .font(.title2)
                    
                    Text("Achievements")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(userStats.achievements, id: \.id) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
            .padding(20)
        }
    }
}

/// Individual stat item component
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(DesignTokens.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignTokens.Text.primary)
            
            Text(title)
                .font(DesignTokens.Typography.caption1)
                .foregroundColor(DesignTokens.Text.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

/// Achievement badge component
struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                achievement.color,
                                achievement.color.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Text(achievement.title)
                .font(DesignTokens.Typography.caption2)
                .foregroundColor(DesignTokens.Text.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

// MARK: - Data Models

struct ProfileUserStats {
    let level: Int
    let totalPoints: Int
    let stoppedVehicles: Int
    let policeSignals: Int
    let hazards: Int
    let trafficJams: Int
    let huntsCompleted: Int
    let adventuresCompleted: Int
    let placesVisited: Int
    let checkpointsFound: Int
    let businessReviews: Int
    let businessPhotos: Int
    let businessTips: Int
    let businessesHelped: Int
    let achievements: [Achievement]
    
    static func mockData() -> ProfileUserStats {
        ProfileUserStats(
            level: 12,
            totalPoints: 2847,
            stoppedVehicles: 23,
            policeSignals: 8,
            hazards: 15,
            trafficJams: 31,
            huntsCompleted: 7,
            adventuresCompleted: 12,
            placesVisited: 45,
            checkpointsFound: 89,
            businessReviews: 18,
            businessPhotos: 34,
            businessTips: 12,
            businessesHelped: 6,
            achievements: [
                Achievement(id: 1, title: "Road Warrior", icon: "car.fill", color: DesignTokens.Semantic.warning),
                Achievement(id: 2, title: "Explorer", icon: "flag.fill", color: DesignTokens.Brand.primary),
                Achievement(id: 3, title: "Local Hero", icon: "building.2.fill", color: DesignTokens.Semantic.success),
                Achievement(id: 4, title: "Photo Pro", icon: "camera.fill", color: DesignTokens.Brand.primaryMid),
                Achievement(id: 5, title: "Community Helper", icon: "hand.raised.fill", color: DesignTokens.Semantic.info),
                Achievement(id: 6, title: "Adventure Seeker", icon: "sparkles", color: DesignTokens.Brand.primary)
            ]
        )
    }
}

struct Achievement: Identifiable {
    let id: Int
    let title: String
    let icon: String
    let color: Color
}

// MARK: - #Preview

#Preview {
    ProfileStatsView()
}
