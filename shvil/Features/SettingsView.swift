//
//  SettingsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var appState = DependencyContainer.shared.appState
    @StateObject private var privacyGuard = DependencyContainer.shared.privacyGuard
    @StateObject private var settingsService = DependencyContainer.shared.settingsService
    @StateObject private var authService = DependencyContainer.shared.authenticationService
    @State private var showingPrivacySettings = false
    @State private var showingLocationSettings = false
    @State private var showingNotificationSettings = false
    @State private var showingAbout = false
    @State private var showingSignIn = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader

                    // App Settings
                    appSettingsSection

                    // Feature Settings
                    featureSettingsSection

                    // Privacy & Security
                    privacySection

                    // Notifications
                    notificationsSection

                    // Support & Info
                    supportSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .background(AppleColors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showingLocationSettings) {
            LocationSettingsView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        AppleGlassCard(style: .elevated) {
            VStack(spacing: AppleSpacing.md) {
                // Profile Picture
                ZStack {
                    Circle()
                        .fill(AppleColors.brandGradient)
                        .frame(width: 80, height: 80)
                        .appleShadow(AppleShadows.medium)

                    Image(systemName: authService.isAuthenticated ? "person.fill" : "person.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                VStack(spacing: AppleSpacing.xs) {
                    Text(authService.isAuthenticated ? (authService.currentUser?.displayName ?? "User") : "Welcome to Shvil")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)

                    Text(authService.isAuthenticated ? authService.currentUser?.email ?? "" : "Your personal navigation assistant")
                        .font(AppleTypography.footnote)
                        .foregroundColor(AppleColors.textSecondary)
                }
                
                // Sign In/Out Button
                AppleButton(
                    authService.isAuthenticated ? "Sign Out" : "Sign In",
                    icon: authService.isAuthenticated ? "arrow.right.square" : "person.badge.plus",
                    style: authService.isAuthenticated ? .destructive : .primary,
                    size: .medium
                ) {
                    if authService.isAuthenticated {
                        Task {
                            await authService.signOut()
                        }
                    } else {
                        showingSignIn = true
                    }
                }
            }
        }
    }

    // MARK: - App Settings Section

    private var appSettingsSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("App Settings")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(spacing: AppleSpacing.sm) {
                    // Language Selection
                    AppleListRow {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(AppleColors.brandPrimary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Language")
                                    .font(AppleTypography.body)
                                    .foregroundColor(AppleColors.textPrimary)
                                
                                Text(settingsService.selectedLanguage.displayName)
                                    .font(AppleTypography.footnote)
                                    .foregroundColor(AppleColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Picker("Language", selection: $settingsService.selectedLanguage) {
                                ForEach(AppLanguage.allCases, id: \.self) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }

                    // Theme Selection
                    AppleListRow {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(AppleColors.brandPrimary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Appearance")
                                    .font(AppleTypography.body)
                                    .foregroundColor(AppleColors.textPrimary)
                                
                                Text(settingsService.selectedTheme.displayName)
                                    .font(AppleTypography.footnote)
                                    .foregroundColor(AppleColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Picker("Theme", selection: $settingsService.selectedTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.displayName).tag(theme)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Feature Settings Section

    private var featureSettingsSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Features")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(spacing: AppleSpacing.sm) {
                    ToggleRow(
                        icon: "person.2.fill",
                        title: "Friends on Map",
                        subtitle: "Show friends' locations",
                        isOn: $settingsService.enableFriendsOnMap
                    )

                    ToggleRow(
                        icon: "shield.fill",
                        title: "Safety Layer",
                        subtitle: "Show safety information",
                        isOn: $settingsService.enableSafetyAlerts
                    )

                    ToggleRow(
                        icon: "lightbulb.fill",
                        title: "Smart Stops",
                        subtitle: "Suggest stops along your route",
                        isOn: $settingsService.enableSmartStops
                    )

                    ToggleRow(
                        icon: "mic.fill",
                        title: "Voice Search",
                        subtitle: "Search using your voice",
                        isOn: $settingsService.enableVoiceSearch
                    )
                }
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Privacy & Security")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(spacing: AppleSpacing.sm) {
                    AppleGlassListRow(
                        icon: "shield.checkered",
                        title: "Privacy Settings",
                        subtitle: "Control your data and privacy",
                        action: {
                            showingPrivacySettings = true
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    AppleGlassListRow(
                        icon: "location.fill",
                        title: "Location Services",
                        subtitle: locationPermissionText,
                        action: {
                            showingLocationSettings = true
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    AppleGlassListRow(
                        icon: "key.fill",
                        title: "Biometric Lock",
                        subtitle: "Use Face ID or Touch ID",
                        action: {
                            // TODO: Implement biometric lock
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Notifications")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(spacing: AppleSpacing.sm) {
                    AppleGlassListRow(
                        icon: "bell.fill",
                        title: "Notification Settings",
                        subtitle: notificationPermissionText,
                        action: {
                            showingNotificationSettings = true
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    ToggleRow(
                        icon: "location.circle.fill",
                        title: "Location Alerts",
                        subtitle: "Get notified about nearby places",
                        isOn: .constant(true) // TODO: Connect to actual setting
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    ToggleRow(
                        icon: "person.2.circle.fill",
                        title: "Social Updates",
                        subtitle: "Updates from friends and groups",
                        isOn: .constant(true) // TODO: Connect to actual setting
                    )
                }
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Support & Info")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                VStack(spacing: AppleSpacing.sm) {
                    AppleGlassListRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        action: {
                            // TODO: Open help center
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    AppleGlassListRow(
                        icon: "star.fill",
                        title: "Rate Shvil",
                        subtitle: "Rate us on the App Store",
                        action: {
                            // TODO: Open App Store rating
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    AppleGlassListRow(
                        icon: "square.and.arrow.up",
                        title: "Share Shvil",
                        subtitle: "Tell your friends about Shvil",
                        action: {
                            // TODO: Open share sheet
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )

                    Divider()
                        .background(AppleColors.glassLight)

                    AppleGlassListRow(
                        icon: "info.circle.fill",
                        title: "About Shvil",
                        subtitle: "Version 1.0.0",
                        action: {
                            showingAbout = true
                            HapticFeedback.shared.impact(style: .light)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var locationPermissionText: String {
        switch appState.locationPermission {
        case .notDetermined:
            "Not determined"
        case .denied:
            "Denied"
        case .whenInUse:
            "When in use"
        case .always:
            "Always"
        }
    }

    private var notificationPermissionText: String {
        switch appState.notificationPermission {
        case .notDetermined:
            "Not determined"
        case .denied:
            "Denied"
        case .granted:
            "Enabled"
        }
    }
}

// MARK: - Supporting Views

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppleColors.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                Text(title)
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)

                Text(subtitle)
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppleColors.brandPrimary))
        }
        .padding(.vertical, AppleSpacing.sm)
        .padding(.horizontal, AppleSpacing.md)
        .accessibilityLabel("\(title): \(subtitle)")
        .accessibilityHint("Double tap to toggle \(isOn ? "off" : "on")")
        .accessibilityAddTraits(.isButton)
    }
}

struct LocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = DependencyContainer.shared.appState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Location Permission Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location Services")
                            .font(AppleTypography.largeTitle)
                            .foregroundColor(AppleColors.textPrimary)

                        Text("Shvil needs access to your location to provide navigation and location-based features.")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)

                        HStack {
                            Image(systemName: locationStatusIcon)
                                .font(.system(size: 20))
                                .foregroundColor(locationStatusColor)

                            Text(locationStatusText)
                                .font(AppleTypography.bodySemibold)
                                .foregroundColor(AppleColors.textPrimary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(locationStatusColor.opacity(0.1))
                                .glassmorphism(intensity: .light, cornerRadius: 12)
                        )
                    }

                    // Location Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location Features")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)

                        VStack(spacing: 12) {
                            LocationFeatureRow(
                                title: "Navigation",
                                description: "Turn-by-turn directions",
                                isEnabled: appState.locationPermission != .denied
                            )

                            LocationFeatureRow(
                                title: "Smart Stops",
                                description: "Suggest stops along your route",
                                isEnabled: appState.locationPermission != .denied
                            )

                            LocationFeatureRow(
                                title: "Friends on Map",
                                description: "See friends' locations",
                                isEnabled: appState.locationPermission == .always
                            )
                        }
                    }

                    // Settings Button
                    if appState.locationPermission == .denied {
                        Button(action: {
                            // TODO: Open system settings
                            HapticFeedback.shared.impact(style: .medium)
                        }) {
                            Text("Open Settings")
                                .font(AppleTypography.bodySemibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppleColors.brandGradient)
                                )
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Location Services")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppleColors.brandPrimary)
                }
            }
        }
    }

    private var locationStatusIcon: String {
        switch appState.locationPermission {
        case .notDetermined:
            "questionmark.circle"
        case .denied:
            "xmark.circle"
        case .whenInUse:
            "checkmark.circle"
        case .always:
            "checkmark.circle.fill"
        }
    }

    private var locationStatusColor: Color {
        switch appState.locationPermission {
        case .notDetermined:
            .orange
        case .denied:
            .red
        case .whenInUse, .always:
            .green
        }
    }

    private var locationStatusText: String {
        switch appState.locationPermission {
        case .notDetermined:
            "Permission not requested"
        case .denied:
            "Location access denied"
        case .whenInUse:
            "Location access granted (when in use)"
        case .always:
            "Location access granted (always)"
        }
    }
}

struct LocationFeatureRow: View {
    let title: String
    let description: String
    let isEnabled: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                Text(description)
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            Spacer()

            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? .green : .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppleColors.surfaceTertiary)
                .glassmorphism(intensity: .light, cornerRadius: 12)
        )
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = DependencyContainer.shared.appState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Notification Permission Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notifications")
                            .font(AppleTypography.largeTitle)
                            .foregroundColor(AppleColors.textPrimary)

                        Text("Stay updated with important information about your navigation and social features.")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)

                        HStack {
                            Image(systemName: notificationStatusIcon)
                                .font(.system(size: 20))
                                .foregroundColor(notificationStatusColor)

                            Text(notificationStatusText)
                                .font(AppleTypography.bodySemibold)
                                .foregroundColor(AppleColors.textPrimary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(notificationStatusColor.opacity(0.1))
                                .glassmorphism(intensity: .light, cornerRadius: 12)
                        )
                    }

                    // Notification Types
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notification Types")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)

                        VStack(spacing: 12) {
                            NotificationTypeRow(
                                title: "Navigation Alerts",
                                description: "Turn-by-turn directions and route updates",
                                isEnabled: appState.notificationPermission == .granted
                            )

                            NotificationTypeRow(
                                title: "Social Updates",
                                description: "Updates from friends and group plans",
                                isEnabled: appState.notificationPermission == .granted
                            )

                            NotificationTypeRow(
                                title: "Safety Alerts",
                                description: "Important safety information",
                                isEnabled: appState.notificationPermission == .granted
                            )
                        }
                    }

                    // Settings Button
                    if appState.notificationPermission == .denied {
                        Button(action: {
                            // TODO: Open system settings
                            HapticFeedback.shared.impact(style: .medium)
                        }) {
                            Text("Open Settings")
                                .font(AppleTypography.bodySemibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppleColors.brandGradient)
                                )
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppleColors.brandPrimary)
                }
            }
        }
    }

    private var notificationStatusIcon: String {
        switch appState.notificationPermission {
        case .notDetermined:
            "questionmark.circle"
        case .denied:
            "xmark.circle"
        case .granted:
            "checkmark.circle.fill"
        }
    }

    private var notificationStatusColor: Color {
        switch appState.notificationPermission {
        case .notDetermined:
            .orange
        case .denied:
            .red
        case .granted:
            .green
        }
    }

    private var notificationStatusText: String {
        switch appState.notificationPermission {
        case .notDetermined:
            "Permission not requested"
        case .denied:
            "Notifications disabled"
        case .granted:
            "Notifications enabled"
        }
    }
}

struct NotificationTypeRow: View {
    let title: String
    let description: String
    let isEnabled: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                Text(description)
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            Spacer()

            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? .green : .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppleColors.surfaceTertiary)
                .glassmorphism(intensity: .light, cornerRadius: 12)
        )
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // App Icon and Info
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppleColors.brandGradient)
                                .frame(width: 100, height: 100)
                                .glassmorphism(intensity: .heavy, cornerRadius: 12)

                            Image(systemName: "map.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 8) {
                            Text("Shvil")
                                .font(AppleTypography.largeTitle)
                                .foregroundColor(AppleColors.textPrimary)

                            Text("Version 1.0.0")
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                        }
                    }

                    // App Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About Shvil")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)

                        Text("Shvil is your personal navigation assistant that helps you discover new places, plan adventures, and stay connected with friends. Built with privacy and safety in mind.")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureItem(title: "Smart Navigation", description: "AI-powered route planning")
                            FeatureItem(title: "Social Features", description: "Share ETAs and plans with friends")
                            FeatureItem(title: "Adventure Mode", description: "Discover new places and experiences")
                            FeatureItem(title: "Privacy First", description: "Your data stays private and secure")
                        }
                    }

                    // Legal Links
                    VStack(spacing: 12) {
                        Button("Privacy Policy") {
                            // TODO: Open privacy policy
                        }
                        .foregroundColor(AppleColors.brandPrimary)

                        Button("Terms of Service") {
                            // TODO: Open terms of service
                        }
                        .foregroundColor(AppleColors.brandPrimary)
                    }
                }
                .padding(20)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppleColors.brandPrimary)
                }
            }
        }
    }
}

struct FeatureItem: View {
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppleColors.brandPrimary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                Text(description)
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
