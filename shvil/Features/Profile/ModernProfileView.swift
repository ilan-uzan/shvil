//
//  ModernProfileView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct ModernProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var supabaseManager: SupabaseManager
    
    @State private var showingSignOutAlert = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ShvilDesign.Spacing.lg) {
                    // Profile Header
                    profileHeader
                    
                    // Quick Stats
                    quickStats
                    
                    // Settings Sections
                    settingsSections
                    
                    // App Info
                    appInfo
                }
                .padding(ShvilDesign.Spacing.md)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .sheet(isPresented: $showingAbout) {
                AboutSheet()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacySheet()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: ShvilDesign.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(ShvilDesign.Colors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                if authManager.isGuest {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(ShvilDesign.Colors.primary)
                } else {
                    Text(authManager.currentUser?.displayName?.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(ShvilDesign.Colors.primary)
                }
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(authManager.isGuest ? "Guest User" : (authManager.currentUser?.displayName ?? "User"))
                    .font(ShvilDesign.Typography.title2)
                    .foregroundColor(ShvilDesign.Colors.primaryText)
                
                Text(authManager.isGuest ? "Limited features available" : (authManager.currentUser?.email ?? ""))
                    .font(ShvilDesign.Typography.caption)
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
            }
            
            // Sign In/Out Button
            if authManager.isGuest {
                Button(action: {
                    // Show sign in options
                }) {
                    Text("Sign In for Full Features")
                        .font(ShvilDesign.Typography.bodyEmphasized)
                        .foregroundColor(.white)
                        .padding(.horizontal, ShvilDesign.Spacing.lg)
                        .padding(.vertical, ShvilDesign.Spacing.sm)
                        .background(ShvilDesign.Colors.primary)
                        .cornerRadius(ShvilDesign.CornerRadius.medium)
                }
            } else {
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    Text("Sign Out")
                        .font(ShvilDesign.Typography.bodyEmphasized)
                        .foregroundColor(ShvilDesign.Colors.error)
                        .padding(.horizontal, ShvilDesign.Spacing.lg)
                        .padding(.vertical, ShvilDesign.Spacing.sm)
                        .background(ShvilDesign.Colors.error.opacity(0.1))
                        .cornerRadius(ShvilDesign.CornerRadius.medium)
                }
            }
        }
        .padding(ShvilDesign.Spacing.lg)
        .background(ShvilDesign.Colors.secondaryBackground)
        .cornerRadius(ShvilDesign.CornerRadius.large)
    }
    
    // MARK: - Quick Stats
    private var quickStats: some View {
        HStack(spacing: ShvilDesign.Spacing.md) {
            StatCard(
                title: "Saved Places",
                value: "12",
                icon: "star.fill",
                color: ShvilDesign.Colors.warning
            )
            
            StatCard(
                title: "Routes Taken",
                value: "48",
                icon: "location.fill",
                color: ShvilDesign.Colors.primary
            )
            
            StatCard(
                title: "Distance",
                value: "1.2k mi",
                icon: "road.lanes",
                color: ShvilDesign.Colors.success
            )
        }
    }
    
    // MARK: - Settings Sections
    private var settingsSections: some View {
        VStack(spacing: ShvilDesign.Spacing.md) {
            // Navigation Settings
            SettingsSection(title: "Navigation") {
                SettingsRow(
                    icon: "location.fill",
                    title: "Location Services",
                    subtitle: locationService.isLocationEnabled ? "Enabled" : "Disabled",
                    color: locationService.isLocationEnabled ? ShvilDesign.Colors.success : ShvilDesign.Colors.error
                ) {
                    // Handle location settings
                }
                
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Voice Guidance",
                    subtitle: "Enabled",
                    color: ShvilDesign.Colors.primary
                ) {
                    // Handle voice settings
                }
                
                SettingsRow(
                    icon: "map.fill",
                    title: "Map Style",
                    subtitle: "Standard",
                    color: ShvilDesign.Colors.primary
                ) {
                    // Handle map style
                }
            }
            
            // Privacy & Security
            SettingsSection(title: "Privacy & Security") {
                SettingsRow(
                    icon: "lock.fill",
                    title: "Privacy Policy",
                    subtitle: "View our privacy policy",
                    color: ShvilDesign.Colors.primary
                ) {
                    showingPrivacy = true
                }
                
                SettingsRow(
                    icon: "trash.fill",
                    title: "Clear Data",
                    subtitle: "Remove all saved data",
                    color: ShvilDesign.Colors.error
                ) {
                    // Handle clear data
                }
            }
            
            // Support
            SettingsSection(title: "Support") {
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get help using Shvil",
                    color: ShvilDesign.Colors.primary
                ) {
                    // Handle help
                }
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Rate us on the App Store",
                    color: ShvilDesign.Colors.warning
                ) {
                    // Handle rating
                }
                
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About",
                    subtitle: "App version and info",
                    color: ShvilDesign.Colors.primary
                ) {
                    showingAbout = true
                }
            }
        }
    }
    
    // MARK: - App Info
    private var appInfo: some View {
        VStack(spacing: ShvilDesign.Spacing.sm) {
            Text("Shvil")
                .font(ShvilDesign.Typography.title3)
                .foregroundColor(ShvilDesign.Colors.primaryText)
            
            Text("Version 1.0.0")
                .font(ShvilDesign.Typography.caption)
                .foregroundColor(ShvilDesign.Colors.secondaryText)
            
            Text("Made with ❤️ for navigation")
                .font(ShvilDesign.Typography.caption)
                .foregroundColor(ShvilDesign.Colors.secondaryText)
        }
        .padding(ShvilDesign.Spacing.lg)
        .background(ShvilDesign.Colors.secondaryBackground)
        .cornerRadius(ShvilDesign.CornerRadius.medium)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: ShvilDesign.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(ShvilDesign.Typography.title3)
                .foregroundColor(ShvilDesign.Colors.primaryText)
            
            Text(title)
                .font(ShvilDesign.Typography.caption)
                .foregroundColor(ShvilDesign.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(ShvilDesign.Spacing.md)
        .background(ShvilDesign.Colors.secondaryBackground)
        .cornerRadius(ShvilDesign.CornerRadius.medium)
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ShvilDesign.Spacing.sm) {
            Text(title)
                .font(ShvilDesign.Typography.headline)
                .foregroundColor(ShvilDesign.Colors.primaryText)
                .padding(.horizontal, ShvilDesign.Spacing.sm)
            
            VStack(spacing: 0) {
                content
            }
            .background(ShvilDesign.Colors.secondaryBackground)
            .cornerRadius(ShvilDesign.CornerRadius.medium)
        }
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
            HStack(spacing: ShvilDesign.Spacing.md) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(ShvilDesign.Typography.body)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                    
                    Text(subtitle)
                        .font(ShvilDesign.Typography.caption)
                        .foregroundColor(ShvilDesign.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ShvilDesign.Colors.secondaryText)
                    .font(.caption)
            }
            .padding(ShvilDesign.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ShvilDesign.Spacing.lg) {
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(ShvilDesign.Colors.primary.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(ShvilDesign.Colors.primary)
                    }
                    
                    VStack(spacing: ShvilDesign.Spacing.sm) {
                        Text("Shvil")
                            .font(ShvilDesign.Typography.largeTitle)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        Text("Version 1.0.0")
                            .font(ShvilDesign.Typography.body)
                            .foregroundColor(ShvilDesign.Colors.secondaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
                        Text("About Shvil")
                            .font(ShvilDesign.Typography.title3)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        Text("Shvil is a modern navigation app that combines the clean polish of Apple Maps with community feedback features. Built with SwiftUI and designed with Apple's Human Interface Guidelines in mind.")
                            .font(ShvilDesign.Typography.body)
                            .foregroundColor(ShvilDesign.Colors.secondaryText)
                        
                        Text("Features")
                            .font(ShvilDesign.Typography.title3)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        VStack(alignment: .leading, spacing: ShvilDesign.Spacing.sm) {
                            FeatureRow(icon: "location.fill", text: "Turn-by-turn navigation")
                            FeatureRow(icon: "magnifyingglass", text: "Smart place search")
                            FeatureRow(icon: "star.fill", text: "Save favorite places")
                            FeatureRow(icon: "person.2.fill", text: "Community features")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(ShvilDesign.Spacing.lg)
            }
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
    let text: String
    
    var body: some View {
        HStack(spacing: ShvilDesign.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(ShvilDesign.Colors.primary)
                .frame(width: 20)
            
            Text(text)
                .font(ShvilDesign.Typography.body)
                .foregroundColor(ShvilDesign.Colors.primaryText)
        }
    }
}

// MARK: - Privacy Sheet
struct PrivacySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: ShvilDesign.Spacing.lg) {
                    Text("Privacy Policy")
                        .font(ShvilDesign.Typography.title1)
                        .foregroundColor(ShvilDesign.Colors.primaryText)
                    
                    VStack(alignment: .leading, spacing: ShvilDesign.Spacing.md) {
                        Text("Data Collection")
                            .font(ShvilDesign.Typography.title3)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        Text("Shvil collects minimal data necessary for navigation functionality. We do not track your location when the app is not in use.")
                            .font(ShvilDesign.Typography.body)
                            .foregroundColor(ShvilDesign.Colors.secondaryText)
                        
                        Text("Location Data")
                            .font(ShvilDesign.Typography.title3)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        Text("Location data is used only for navigation purposes and is not shared with third parties. You can disable location services at any time.")
                            .font(ShvilDesign.Typography.body)
                            .foregroundColor(ShvilDesign.Colors.secondaryText)
                        
                        Text("Data Storage")
                            .font(ShvilDesign.Typography.title3)
                            .foregroundColor(ShvilDesign.Colors.primaryText)
                        
                        Text("Your saved places and preferences are stored locally on your device. We use Supabase for optional cloud sync when you sign in.")
                            .font(ShvilDesign.Typography.body)
                            .foregroundColor(ShvilDesign.Colors.secondaryText)
                    }
                }
                .padding(ShvilDesign.Spacing.lg)
            }
            .navigationTitle("Privacy")
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

#Preview {
    ModernProfileView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(LocationService.shared)
        .environmentObject(SupabaseManager.shared)
}
