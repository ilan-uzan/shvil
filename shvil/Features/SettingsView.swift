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
    @State private var showingPrivacySettings = false
    @State private var showingLocationSettings = false
    @State private var showingNotificationSettings = false
    @State private var showingAbout = false

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
            .background(LiquidGlassColors.background.ignoresSafeArea())
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
        VStack(spacing: 16) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(LiquidGlassGradients.primaryGradient)
                    .frame(width: 80, height: 80)
                    .glassEffect(elevation: .high)

                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text("Welcome to Shvil")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text("Your personal navigation assistant")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
                .glassEffect(elevation: .medium)
        )
    }

    // MARK: - App Settings Section

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Settings")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "globe",
                    title: "Language",
                    subtitle: "English"
                ) {
                    // TODO: Implement language selection
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "moon.fill",
                    title: "Appearance",
                    subtitle: "System"
                ) {
                    // TODO: Implement appearance selection
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "textformat.size",
                    title: "Text Size",
                    subtitle: "Default"
                ) {
                    // TODO: Implement text size selection
                    HapticFeedback.shared.impact(style: .light)
                }
            }
        }
    }

    // MARK: - Feature Settings Section

    private var featureSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            VStack(spacing: 12) {
                ToggleRow(
                    icon: "person.2.fill",
                    title: "Friends on Map",
                    subtitle: "Show friends' locations",
                    isOn: $appState.enableFriendsOnMap
                )

                ToggleRow(
                    icon: "shield.fill",
                    title: "Safety Layer",
                    subtitle: "Show safety information",
                    isOn: $appState.enableSafetyLayer
                )

                ToggleRow(
                    icon: "lightbulb.fill",
                    title: "Smart Stops",
                    subtitle: "Suggest stops along your route",
                    isOn: $appState.enableSmartStops
                )

                ToggleRow(
                    icon: "mic.fill",
                    title: "Voice Search",
                    subtitle: "Search using your voice",
                    isOn: $appState.enableVoiceSearch
                )
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy & Security")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "shield.checkered",
                    title: "Privacy Settings",
                    subtitle: "Control your data and privacy"
                ) {
                    showingPrivacySettings = true
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "location.fill",
                    title: "Location Services",
                    subtitle: locationPermissionText
                ) {
                    showingLocationSettings = true
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "key.fill",
                    title: "Biometric Lock",
                    subtitle: "Use Face ID or Touch ID"
                ) {
                    // TODO: Implement biometric lock
                    HapticFeedback.shared.impact(style: .light)
                }
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notification Settings",
                    subtitle: notificationPermissionText
                ) {
                    showingNotificationSettings = true
                    HapticFeedback.shared.impact(style: .light)
                }

                ToggleRow(
                    icon: "location.circle.fill",
                    title: "Location Alerts",
                    subtitle: "Get notified about nearby places",
                    isOn: .constant(true) // TODO: Connect to actual setting
                )

                ToggleRow(
                    icon: "person.2.circle.fill",
                    title: "Social Updates",
                    subtitle: "Updates from friends and groups",
                    isOn: .constant(true) // TODO: Connect to actual setting
                )
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support & Info")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get help and contact support"
                ) {
                    // TODO: Open help center
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "star.fill",
                    title: "Rate Shvil",
                    subtitle: "Rate us on the App Store"
                ) {
                    // TODO: Open App Store rating
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Share Shvil",
                    subtitle: "Tell your friends about Shvil"
                ) {
                    // TODO: Open share sheet
                    HapticFeedback.shared.impact(style: .light)
                }

                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About Shvil",
                    subtitle: "Version 1.0.0"
                ) {
                    showingAbout = true
                    HapticFeedback.shared.impact(style: .light)
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
                .font(.system(size: 20))
                .foregroundColor(LiquidGlassColors.primaryText)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text(subtitle)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: LiquidGlassColors.accentDeepAqua))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LiquidGlassColors.glassSurface1)
                .glassEffect(elevation: .light)
        )
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
                            .font(LiquidGlassTypography.titleXL)
                            .foregroundColor(LiquidGlassColors.primaryText)

                        Text("Shvil needs access to your location to provide navigation and location-based features.")
                            .font(LiquidGlassTypography.body)
                            .foregroundColor(LiquidGlassColors.secondaryText)

                        HStack {
                            Image(systemName: locationStatusIcon)
                                .font(.system(size: 20))
                                .foregroundColor(locationStatusColor)

                            Text(locationStatusText)
                                .font(LiquidGlassTypography.bodySemibold)
                                .foregroundColor(LiquidGlassColors.primaryText)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(locationStatusColor.opacity(0.1))
                                .glassEffect(elevation: .light)
                        )
                    }

                    // Location Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location Features")
                            .font(LiquidGlassTypography.title)
                            .foregroundColor(LiquidGlassColors.primaryText)

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
                                .font(LiquidGlassTypography.bodySemibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LiquidGlassGradients.primaryGradient)
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
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)
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
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text(description)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }

            Spacer()

            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? .green : .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LiquidGlassColors.glassSurface1)
                .glassEffect(elevation: .light)
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
                            .font(LiquidGlassTypography.titleXL)
                            .foregroundColor(LiquidGlassColors.primaryText)

                        Text("Stay updated with important information about your navigation and social features.")
                            .font(LiquidGlassTypography.body)
                            .foregroundColor(LiquidGlassColors.secondaryText)

                        HStack {
                            Image(systemName: notificationStatusIcon)
                                .font(.system(size: 20))
                                .foregroundColor(notificationStatusColor)

                            Text(notificationStatusText)
                                .font(LiquidGlassTypography.bodySemibold)
                                .foregroundColor(LiquidGlassColors.primaryText)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(notificationStatusColor.opacity(0.1))
                                .glassEffect(elevation: .light)
                        )
                    }

                    // Notification Types
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notification Types")
                            .font(LiquidGlassTypography.title)
                            .foregroundColor(LiquidGlassColors.primaryText)

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
                                .font(LiquidGlassTypography.bodySemibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LiquidGlassGradients.primaryGradient)
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
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)
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
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text(description)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }

            Spacer()

            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? .green : .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LiquidGlassColors.glassSurface1)
                .glassEffect(elevation: .light)
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
                                .fill(LiquidGlassGradients.primaryGradient)
                                .frame(width: 100, height: 100)
                                .glassEffect(elevation: .high)

                            Image(systemName: "map.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 8) {
                            Text("Shvil")
                                .font(LiquidGlassTypography.titleXL)
                                .foregroundColor(LiquidGlassColors.primaryText)

                            Text("Version 1.0.0")
                                .font(LiquidGlassTypography.caption)
                                .foregroundColor(LiquidGlassColors.secondaryText)
                        }
                    }

                    // App Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About Shvil")
                            .font(LiquidGlassTypography.title)
                            .foregroundColor(LiquidGlassColors.primaryText)

                        Text("Shvil is your personal navigation assistant that helps you discover new places, plan adventures, and stay connected with friends. Built with privacy and safety in mind.")
                            .font(LiquidGlassTypography.body)
                            .foregroundColor(LiquidGlassColors.secondaryText)
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(LiquidGlassTypography.title)
                            .foregroundColor(LiquidGlassColors.primaryText)

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
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)

                        Button("Terms of Service") {
                            // TODO: Open terms of service
                        }
                        .foregroundColor(LiquidGlassColors.accentDeepAqua)
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
                    .foregroundColor(LiquidGlassColors.accentDeepAqua)
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
                .foregroundColor(LiquidGlassColors.accentDeepAqua)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)

                Text(description)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
        }
    }
}

#Preview {
    SettingsView()
}
