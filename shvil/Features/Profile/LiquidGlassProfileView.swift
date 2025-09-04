//
//  LiquidGlassProfileView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct LiquidGlassProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @State private var showSettings = false
    @State private var showAbout = false
    
    var body: some View {
        ZStack {
            // Background
            LiquidGlassDesign.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LiquidGlassDesign.Spacing.xl) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Cards
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Settings Section
                    settingsSection
                    
                    // About Section
                    aboutSection
                }
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                .padding(.top, LiquidGlassDesign.Spacing.lg)
            }
        }
        .sheet(isPresented: $showSettings) {
            LiquidGlassSettingsView()
        }
        .sheet(isPresented: $showAbout) {
            LiquidGlassAboutView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: LiquidGlassDesign.Spacing.lg) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [LiquidGlassDesign.Colors.liquidBlue, LiquidGlassDesign.Colors.liquidBlueLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Text(authManager.currentUser?.displayName?.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .liquidGlassGlow(color: LiquidGlassDesign.Colors.liquidBlue, radius: 24)
            
            // User Info
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Text(authManager.currentUser?.displayName ?? "Guest User")
                    .font(LiquidGlassDesign.Typography.title1)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Text(authManager.currentUser?.email ?? "guest@shvil.app")
                    .font(LiquidGlassDesign.Typography.callout)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                
                // Status Badge
                HStack(spacing: LiquidGlassDesign.Spacing.xs) {
                    Circle()
                        .fill(authManager.isAuthenticated ? LiquidGlassDesign.Colors.accentGreen : LiquidGlassDesign.Colors.accentOrange)
                        .frame(width: 8, height: 8)
                        .liquidGlassGlow(
                            color: authManager.isAuthenticated ? LiquidGlassDesign.Colors.accentGreen : LiquidGlassDesign.Colors.accentOrange,
                            radius: 4
                        )
                    
                    Text(authManager.isAuthenticated ? "Authenticated" : "Guest Mode")
                        .font(LiquidGlassDesign.Typography.caption)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
                .padding(.horizontal, LiquidGlassDesign.Spacing.md)
                .padding(.vertical, LiquidGlassDesign.Spacing.xs)
                .background(
                    Capsule()
                        .fill(LiquidGlassDesign.Colors.glassWhite)
                        .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
                )
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: LiquidGlassDesign.Spacing.md) {
            StatCard(
                title: "Saved Places",
                value: "\(supabaseManager.savedPlaces.count)",
                icon: "bookmark.fill",
                color: LiquidGlassDesign.Colors.liquidBlue
            )
            
            StatCard(
                title: "Routes Taken",
                value: "42",
                icon: "location.fill",
                color: LiquidGlassDesign.Colors.accentGreen
            )
            
            StatCard(
                title: "Distance Traveled",
                value: "1,234 km",
                icon: "road.lanes",
                color: LiquidGlassDesign.Colors.accentOrange
            )
            
            StatCard(
                title: "Time Saved",
                value: "2.5 hrs",
                icon: "clock.fill",
                color: LiquidGlassDesign.Colors.accentPurple
            )
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
            Text("Quick Actions")
                .font(LiquidGlassDesign.Typography.title2)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: LiquidGlassDesign.Spacing.sm) {
                QuickActionButton(
                    title: "Sync Data",
                    subtitle: "Backup to cloud",
                    icon: "icloud.and.arrow.up",
                    color: LiquidGlassDesign.Colors.liquidBlue
                ) {
                    Task {
                        await supabaseManager.syncAllData()
                    }
                }
                
                QuickActionButton(
                    title: "Clear Cache",
                    subtitle: "Free up space",
                    icon: "trash",
                    color: LiquidGlassDesign.Colors.accentRed
                ) {
                    supabaseManager.clearLocalData()
                }
                
                QuickActionButton(
                    title: "Export Data",
                    subtitle: "Download backup",
                    icon: "square.and.arrow.down",
                    color: LiquidGlassDesign.Colors.accentGreen
                ) {
                    // Handle export
                }
                
                QuickActionButton(
                    title: "Share App",
                    subtitle: "Tell friends",
                    icon: "square.and.arrow.up",
                    color: LiquidGlassDesign.Colors.accentPurple
                ) {
                    // Handle share
                }
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
            Text("Settings")
                .font(LiquidGlassDesign.Typography.title2)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                SettingsRow(
                    icon: "gear",
                    title: "General Settings",
                    subtitle: "Preferences and options",
                    color: LiquidGlassDesign.Colors.liquidBlue
                ) {
                    showSettings.toggle()
                }
                
                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Alerts and reminders",
                    color: LiquidGlassDesign.Colors.accentOrange
                ) {
                    // Handle notifications
                }
                
                SettingsRow(
                    icon: "lock.shield",
                    title: "Privacy & Security",
                    subtitle: "Data and permissions",
                    color: LiquidGlassDesign.Colors.accentGreen
                ) {
                    // Handle privacy
                }
                
                SettingsRow(
                    icon: "paintbrush",
                    title: "Appearance",
                    subtitle: "Theme and display",
                    color: LiquidGlassDesign.Colors.accentPurple
                ) {
                    // Handle appearance
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
            Text("About")
                .font(LiquidGlassDesign.Typography.title2)
                .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
            
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                SettingsRow(
                    icon: "info.circle",
                    title: "About Shvil",
                    subtitle: "Version 1.0.0",
                    color: LiquidGlassDesign.Colors.liquidBlue
                ) {
                    showAbout.toggle()
                }
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    subtitle: "Get assistance",
                    color: LiquidGlassDesign.Colors.accentGreen
                ) {
                    // Handle help
                }
                
                SettingsRow(
                    icon: "star",
                    title: "Rate App",
                    subtitle: "Share your feedback",
                    color: LiquidGlassDesign.Colors.accentOrange
                ) {
                    // Handle rating
                }
                
                if authManager.isAuthenticated {
                    SettingsRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Sign Out",
                        subtitle: "End current session",
                        color: LiquidGlassDesign.Colors.accentRed
                    ) {
                        authManager.signOut()
                    }
                } else {
                    SettingsRow(
                        icon: "person.badge.plus",
                        title: "Sign In",
                        subtitle: "Sync across devices",
                        color: LiquidGlassDesign.Colors.liquidBlue
                    ) {
                        // TODO: Implement sign in flow
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: LiquidGlassDesign.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            
            VStack(spacing: 2) {
                Text(value)
                    .font(LiquidGlassDesign.Typography.title3)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Text(title)
                    .font(LiquidGlassDesign.Typography.caption)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(LiquidGlassDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.lg)
                .fill(LiquidGlassDesign.Colors.glassWhite)
                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                    )
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(LiquidGlassDesign.Typography.caption)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiquidGlassDesign.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(LiquidGlassDesign.Typography.caption)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                    .fill(LiquidGlassDesign.Colors.glassWhite)
                    .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings View
struct LiquidGlassSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("notifications") private var notifications = true
    @AppStorage("locationTracking") private var locationTracking = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: LiquidGlassDesign.Spacing.lg) {
                // Appearance Settings
                VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
                    Text("Appearance")
                        .font(LiquidGlassDesign.Typography.title2)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        SettingsToggleRow(
                            icon: "moon.fill",
                            title: "Dark Mode",
                            subtitle: "Use dark theme",
                            isOn: $darkMode,
                            color: LiquidGlassDesign.Colors.accentPurple
                        )
                    }
                }
                
                // Privacy Settings
                VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
                    Text("Privacy")
                        .font(LiquidGlassDesign.Typography.title2)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        SettingsToggleRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            subtitle: "Receive alerts and updates",
                            isOn: $notifications,
                            color: LiquidGlassDesign.Colors.accentOrange
                        )
                        
                        SettingsToggleRow(
                            icon: "location.fill",
                            title: "Location Tracking",
                            subtitle: "Allow location services",
                            isOn: $locationTracking,
                            color: LiquidGlassDesign.Colors.accentGreen
                        )
                    }
                }
                
                Spacer()
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: LiquidGlassDesign.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LiquidGlassDesign.Typography.callout)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Text(subtitle)
                    .font(LiquidGlassDesign.Typography.caption)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: LiquidGlassDesign.Colors.liquidBlue))
        }
        .padding(LiquidGlassDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.md)
                .fill(LiquidGlassDesign.Colors.glassWhite)
                .shadow(color: LiquidGlassDesign.Shadows.light, radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - About View
struct LiquidGlassAboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: LiquidGlassDesign.Spacing.xl) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LiquidGlassDesign.Colors.liquidBlue, LiquidGlassDesign.Colors.liquidBlueLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: LiquidGlassDesign.Colors.liquidBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Text("S")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .liquidGlassGlow(color: LiquidGlassDesign.Colors.liquidBlue, radius: 24)
                
                // App Info
                VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                    Text("Shvil")
                        .font(LiquidGlassDesign.Typography.largeTitle)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    Text("Version 1.0.0")
                        .font(LiquidGlassDesign.Typography.callout)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                    
                    Text("The best navigation app with beautiful liquid glass design")
                        .font(LiquidGlassDesign.Typography.body)
                        .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Features
                VStack(alignment: .leading, spacing: LiquidGlassDesign.Spacing.md) {
                    Text("Features")
                        .font(LiquidGlassDesign.Typography.title2)
                        .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                    
                    VStack(spacing: LiquidGlassDesign.Spacing.sm) {
                        FeatureRow(icon: "map.fill", title: "Beautiful Maps", description: "Liquid glass design with smooth animations")
                        FeatureRow(icon: "location.fill", title: "Smart Navigation", description: "Turn-by-turn directions with real-time updates")
                        FeatureRow(icon: "magnifyingglass", title: "Instant Search", description: "Find places quickly with intelligent suggestions")
                        FeatureRow(icon: "bookmark.fill", title: "Saved Places", description: "Keep your favorite locations organized")
                    }
                }
                
                Spacer()
                
                // Credits
                Text("Made with ❤️ using SwiftUI")
                    .font(LiquidGlassDesign.Typography.caption)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            .padding(LiquidGlassDesign.Spacing.md)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: LiquidGlassDesign.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(LiquidGlassDesign.Colors.liquidBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LiquidGlassDesign.Typography.callout)
                    .foregroundColor(LiquidGlassDesign.Colors.textPrimary)
                
                Text(description)
                    .font(LiquidGlassDesign.Typography.caption)
                    .foregroundColor(LiquidGlassDesign.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(LiquidGlassDesign.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlassDesign.CornerRadius.sm)
                .fill(LiquidGlassDesign.Colors.glassWhite)
        )
    }
}



// MARK: - Preview
#Preview {
    LiquidGlassProfileView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(SupabaseManager.shared)
}
