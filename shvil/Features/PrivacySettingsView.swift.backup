//
//  PrivacySettingsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct PrivacySettingsView: View {
    @StateObject private var privacyGuard = DependencyContainer.shared.privacyGuard
    @State private var showingPrivacySheet = false
    @State private var selectedFeature: PrivacyFeature?
    @State private var showingPanicSwitchAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Privacy Overview Card
                    privacyOverviewCard

                    // Privacy Controls
                    privacyControlsSection

                    // Data Management
                    dataManagementSection

                    // Emergency Controls
                    emergencyControlsSection

                    // Legal & Compliance
                    legalSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.large)
            .background(AppleColors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingPrivacySheet) {
            if let feature = selectedFeature {
                PrivacyDetailSheet(feature: feature, privacyGuard: privacyGuard)
            }
        }
        .alert("Panic Switch", isPresented: $showingPanicSwitchAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Enable Panic Switch", role: .destructive) {
                privacyGuard.enablePanicSwitch()
                HapticFeedback.shared.impact(style: .heavy)
            }
        } message: {
            Text("This will immediately stop all data sharing and disable all privacy features. You can disable it later in settings.")
        }
    }

    // MARK: - Privacy Overview Card

    private var privacyOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 24))
                    .foregroundColor(AppleColors.brandPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Privacy Status")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)

                    Text(privacyGuard.isPanicSwitchEnabled ? "All sharing disabled" : "Privacy controls active")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }

                Spacer()

                Circle()
                    .fill(privacyGuard.isPanicSwitchEnabled ? Color.red : AppleColors.brandPrimary)
                    .frame(width: 12, height: 12)
            }

            if !privacyGuard.isPanicSwitchEnabled {
                HStack(spacing: 16) {
                    PrivacyStatusItem(
                        title: "Location",
                        isEnabled: privacyGuard.hasAcceptedLocationSharing,
                        icon: "location.fill"
                    )

                    PrivacyStatusItem(
                        title: "Friends",
                        isEnabled: privacyGuard.hasAcceptedFriendsOnMap,
                        icon: "person.2.fill"
                    )

                    PrivacyStatusItem(
                        title: "ETA",
                        isEnabled: privacyGuard.hasAcceptedETASharing,
                        icon: "clock.fill"
                    )

                    PrivacyStatusItem(
                        title: "Analytics",
                        isEnabled: privacyGuard.hasAcceptedAnalytics,
                        icon: "chart.bar.fill"
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppleColors.surfaceTertiary)
                .glassmorphism(intensity: .medium, cornerRadius: 16)
        )
    }

    // MARK: - Privacy Controls Section

    private var privacyControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Controls")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(spacing: 12) {
                PrivacyControlRow(
                    feature: .locationSharing,
                    isEnabled: privacyGuard.hasAcceptedLocationSharing,
                    privacyGuard: privacyGuard
                ) {
                    selectedFeature = .locationSharing
                    showingPrivacySheet = true
                }

                PrivacyControlRow(
                    feature: .friendsOnMap,
                    isEnabled: privacyGuard.hasAcceptedFriendsOnMap,
                    privacyGuard: privacyGuard
                ) {
                    selectedFeature = .friendsOnMap
                    showingPrivacySheet = true
                }

                PrivacyControlRow(
                    feature: .etaSharing,
                    isEnabled: privacyGuard.hasAcceptedETASharing,
                    privacyGuard: privacyGuard
                ) {
                    selectedFeature = .etaSharing
                    showingPrivacySheet = true
                }

                PrivacyControlRow(
                    feature: .analytics,
                    isEnabled: privacyGuard.hasAcceptedAnalytics,
                    privacyGuard: privacyGuard
                ) {
                    selectedFeature = .analytics
                    showingPrivacySheet = true
                }
            }
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(spacing: 12) {
                AppleGlassListRow(
                    icon: "trash.fill",
                    title: "Clear All Data",
                    subtitle: "Remove all stored location and social data",
                    action: {
                        // TODO: Implement clear all data
                        HapticFeedback.shared.impact(style: .medium)
                    }
                )

                AppleGlassListRow(
                    icon: "square.and.arrow.down",
                    title: "Export My Data",
                    subtitle: "Download a copy of your data",
                    action: {
                        // TODO: Implement data export
                        HapticFeedback.shared.impact(style: .light)
                    }
                )

                AppleGlassListRow(
                    icon: "arrow.clockwise",
                    title: "Reset Privacy Settings",
                    subtitle: "Reset all privacy preferences to default",
                    action: {
                        // TODO: Implement reset privacy settings
                        HapticFeedback.shared.impact(style: .medium)
                    }
                )
            }
        }
    }

    // MARK: - Emergency Controls Section

    private var emergencyControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Emergency Controls")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(spacing: 12) {
                Button(action: {
                    if privacyGuard.isPanicSwitchEnabled {
                        privacyGuard.disablePanicSwitch()
                        HapticFeedback.shared.impact(style: .light)
                    } else {
                        showingPanicSwitchAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: privacyGuard.isPanicSwitchEnabled ? "shield.fill" : "shield.slash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(privacyGuard.isPanicSwitchEnabled ? .red : AppleColors.textPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(privacyGuard.isPanicSwitchEnabled ? "Disable Panic Switch" : "Enable Panic Switch")
                                .font(AppleTypography.body)
                                .foregroundColor(AppleColors.textPrimary)

                            Text(privacyGuard.isPanicSwitchEnabled ? "Re-enable all privacy features" : "Immediately stop all data sharing")
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppleColors.textSecondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(privacyGuard.isPanicSwitchEnabled ? Color.red.opacity(0.1) : AppleColors.surfaceTertiary)
                            .glassmorphism(intensity: .light, cornerRadius: 12)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Legal & Compliance")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(spacing: 12) {
                AppleGlassListRow(
                    icon: "doc.text.fill",
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    action: {
                        // TODO: Open privacy policy
                        HapticFeedback.shared.impact(style: .light)
                    }
                )

                AppleGlassListRow(
                    icon: "hand.raised.fill",
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    action: {
                        // TODO: Open terms of service
                        HapticFeedback.shared.impact(style: .light)
                    }
                )

                AppleGlassListRow(
                    icon: "envelope.fill",
                    title: "Contact Privacy Team",
                    subtitle: "privacy@shvil.app",
                    action: {
                        // TODO: Open email composer
                        HapticFeedback.shared.impact(style: .light)
                    }
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct PrivacyStatusItem: View {
    let title: String
    let isEnabled: Bool
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? AppleColors.brandPrimary : AppleColors.textSecondary)

            Text(title)
                .font(AppleTypography.caption1)
                .foregroundColor(AppleColors.textSecondary)
        }
    }
}

struct PrivacyControlRow: View {
    let feature: PrivacyFeature
    let isEnabled: Bool
    let privacyGuard: PrivacyGuard
    let action: () -> Void

    private var featureInfo: (title: String, subtitle: String, icon: String) {
        switch feature {
        case .locationSharing:
            ("Location Sharing", "Share your location with friends", "location.fill")
        case .friendsOnMap:
            ("Friends on Map", "See friends' locations on map", "person.2.fill")
        case .etaSharing:
            ("ETA Sharing", "Share arrival times with friends", "clock.fill")
        case .analytics:
            ("Analytics", "Help improve the app with usage data", "chart.bar.fill")
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: featureInfo.icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppleColors.textPrimary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(featureInfo.title)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textPrimary)

                    Text(featureInfo.subtitle)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { _ in action() }
                ))
                .toggleStyle(SwitchToggleStyle(tint: AppleColors.brandPrimary))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppleColors.surfaceTertiary)
                    .glassmorphism(intensity: .light, cornerRadius: 12)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrivacyDetailSheet: View {
    let feature: PrivacyFeature
    let privacyGuard: PrivacyGuard
    @Environment(\.dismiss) private var dismiss

    private var sheetData: PrivacySheetData {
        privacyGuard.showPrivacySheet(for: feature)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(sheetData.title)
                            .font(AppleTypography.title1)
                            .foregroundColor(AppleColors.textPrimary)

                        Text(sheetData.description)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)
                    }

                    // Data Collected
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data We Collect")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(sheetData.dataCollected, id: \.self) { item in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(AppleColors.brandPrimary)
                                        .padding(.top, 8)

                                    Text(item)
                                        .font(AppleTypography.body)
                                        .foregroundColor(AppleColors.textSecondary)
                                }
                            }
                        }
                    }

                    // How to Stop
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Stop")
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)

                        Text(sheetData.howToStop)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)
                    }

                    Spacer(minLength: 32)
                }
                .padding(20)
            }
            .navigationTitle("Privacy Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppleColors.brandPrimary)
                }
            }
        }
    }
}

#Preview {
    PrivacySettingsView()
}
