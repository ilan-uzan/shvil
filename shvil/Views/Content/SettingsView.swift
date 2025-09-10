//
//  SettingsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsService = DependencyContainer.shared.settingsService
    @StateObject private var locationManager = DependencyContainer.shared.locationManager
    @StateObject private var localizationManager = LocalizationManager.shared
    
    private let languages = ["English", "עברית"]

    var body: some View {
        ZStack {
            // Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(DesignTokens.Text.primary)

                        Text("Customize your Shvil experience")
                            .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Profile Section
                    VStack(spacing: 20) {
                        ProfileCard()
                        
                        // Settings Sections
                        SettingsSection(title: "Preferences") {
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Get updates about your adventures"
                            ) {
                                Toggle("", isOn: $settingsService.enablePushNotifications)
                                    .tint(DesignTokens.Brand.primary)
                            }
                            
                            SettingsRow(
                                icon: "location.fill",
                                title: "Location Services",
                                subtitle: "Required for adventure features"
                            ) {
                                Toggle("", isOn: Binding(
                                    get: { locationManager.isLocationEnabled },
                                    set: { _ in
                                        if !locationManager.isLocationEnabled {
                                            locationManager.requestLocationPermission()
                                        }
                                    }
                                ))
                                .tint(DesignTokens.Brand.primary)
                            }
                            
                            SettingsRow(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                subtitle: "Switch between light and dark themes"
                            ) {
                                Toggle("", isOn: Binding(
                                    get: { settingsService.selectedTheme == .dark },
                                    set: { isDark in
                                        settingsService.selectedTheme = isDark ? .dark : .light
                                    }
                                ))
                                .tint(DesignTokens.Brand.primary)
                            }
                        }
                        
                        SettingsSection(title: "Language & Region") {
                            SettingsRow(
                                icon: "globe",
                                title: "Language",
                                subtitle: "Choose your preferred language"
                            ) {
                                Menu {
                                    ForEach(languages, id: \.self) { language in
                                        Button(language) {
                                            let appLanguage: AppLanguage = language == "עברית" ? .hebrew : .english
                                            settingsService.selectedLanguage = appLanguage
                                            localizationManager.setLanguage(appLanguage)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(settingsService.selectedLanguage == .hebrew ? "עברית" : "English")
                                            .foregroundColor(DesignTokens.Text.primary)
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(DesignTokens.Text.tertiary)
                                            .font(.system(size: 12))
                                    }
                                }
                            }
                        }
                        
                        SettingsSection(title: "About") {
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: "App Version",
                                subtitle: "1.0.0"
                            ) {
                                EmptyView()
                            }
                            
                            SettingsRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                                subtitle: "Get help with using Shvil"
                            ) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(DesignTokens.Text.tertiary)
                                    .font(.system(size: 12))
                            }
                            
                            SettingsRow(
                                icon: "doc.text.fill",
                                title: "Privacy Policy",
                                subtitle: "How we protect your data"
                            ) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(DesignTokens.Text.tertiary)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct ProfileCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            Circle()
                .fill(DesignTokens.Brand.gradient)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                )
                .appleShadow(DesignTokens.Shadow.light)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Adventure Explorer")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignTokens.Text.primary)

                Text("Member since 2024")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
            }

            Spacer()

            Button("Edit") {
                // Edit profile action
            }
            .foregroundColor(DesignTokens.Brand.primary)
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(DesignTokens.Brand.primary.opacity(0.1))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .appleShadow(DesignTokens.Shadow.light)
        )
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DesignTokens.Text.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(DesignTokens.Surface.primary)
                    .appleShadow(DesignTokens.Shadow.light)
            )
        }
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(DesignTokens.Brand.primary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.primary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
            }

            Spacer()

            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    SettingsView()
}
