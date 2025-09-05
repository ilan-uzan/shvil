//
//  ContentView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    @State private var showAdventureSetup = false
    @State private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                mainContent
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .environment(\.layoutDirection, localizationManager.isRTL ? .rightToLeft : .leftToRight)
    }
    
    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(0)

            // Search Tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)

            // Adventures Tab
            AdventuresView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Adventures")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .appleTabBar()
        .accentColor(AppleColors.brandPrimary)
        .overlay(
            // Floating Adventure Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AppleGlassFAB(
                        icon: "plus",
                        size: .large,
                        style: .primary
                    ) {
                        showAdventureSetup = true
                    }
                    .padding(.trailing, AppleSpacing.md)
                    .padding(.bottom, 100) // Above tab bar
                }
            }
        )
        .sheet(isPresented: $showAdventureSetup) {
            AdventureSetupView()
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")
    }
}

// MARK: - Adventures View

struct AdventuresView: View {
    @StateObject private var adventureKit = DependencyContainer.shared.adventureKit
    @State private var showAdventureSetup = false
    @State private var selectedAdventure: AdventurePlan?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppleColors.background
                    .ignoresSafeArea()
                
                if adventureKit.adventureHistory.isEmpty {
                    emptyState
                } else {
                    adventuresList
                }
            }
            .appleNavigationBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AppleGlassFAB(
                        icon: "plus",
                        size: .small,
                        style: .secondary
                    ) {
                        showAdventureSetup = true
                    }
                }
            }
        }
        .sheet(isPresented: $showAdventureSetup) {
            AdventureSetupView()
        }
        .sheet(item: $selectedAdventure) { adventure in
            AdventureSheetView(adventure: adventure)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppleSpacing.xl) {
            Spacer()
            
            // Empty state illustration
            ZStack {
                // Background wave
                RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                    .fill(AppleColors.brandPrimary.opacity(0.1))
                    .frame(width: 120, height: 80)
                    .overlay(
                        // Wave pattern
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 40))
                            path.addQuadCurve(to: CGPoint(x: 120, y: 40), control: CGPoint(x: 60, y: 20))
                        }
                        .stroke(AppleColors.brandPrimary.opacity(0.3), lineWidth: 2)
                    )
                
                // Adventure icon
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(AppleColors.brandPrimary)
            }
            
            VStack(spacing: AppleSpacing.md) {
                Text("No Adventures Yet")
                    .font(AppleTypography.title2)
                    .foregroundColor(AppleColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Create your first adventure to start exploring amazing places and experiences.")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppleSpacing.lg)
            }
            
            // Create Adventure Button
            AppleButton(
                "Create Adventure",
                icon: "plus",
                style: .primary,
                size: .large
            ) {
                showAdventureSetup = true
            }
            .padding(.horizontal, AppleSpacing.xl)
            
            Spacer()
        }
        .padding(.horizontal, AppleSpacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No Adventures Yet. Create your first adventure to start exploring amazing places and experiences.")
    }
    
    private var adventuresList: some View {
        ScrollView {
            LazyVStack(spacing: AppleSpacing.md) {
                ForEach(adventureKit.adventureHistory) { adventure in
                    adventureCard(for: adventure)
                }
            }
            .padding(.horizontal, AppleSpacing.md)
            .padding(.top, AppleSpacing.sm)
        }
    }
    
    private func adventureCard(for adventure: AdventurePlan) -> some View {
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    Text(adventure.theme.displayName)
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)
                    
                    Text(adventure.description)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                AppleGlassStatusIndicator(
                    status: adventure.status == .completed ? .success : .info
                )
            }
            
            // Stats
            HStack(spacing: AppleSpacing.lg) {
                HStack(spacing: AppleSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.accent)
                    
                    Text("\(adventure.totalDuration)h")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
                
                HStack(spacing: AppleSpacing.xs) {
                    Image(systemName: "location")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppleColors.accent)
                    
                    Text("\(adventure.stops.count) stops")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
                
                Spacer()
            }
            
            // Action buttons
            HStack(spacing: AppleSpacing.sm) {
                AppleButton(
                    "View",
                    style: .secondary,
                    size: .small
                ) {
                    selectedAdventure = adventure
                }
                
                if adventure.status == .draft {
                    AppleButton(
                        "Start",
                        style: .primary,
                        size: .small
                    ) {
                        // Start adventure logic
                        startAdventure(adventure)
                    }
                } else if adventure.status == .completed {
                    AppleButton(
                        "Share",
                        style: .secondary,
                        size: .small
                    ) {
                        // Share adventure logic
                        shareAdventure(adventure)
                    }
                }
            }
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.vertical, AppleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(AppleShadows.medium)
        .onTapGesture {
            selectedAdventure = adventure
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(adventure.theme.displayName) adventure, \(adventure.totalDuration) hours, \(adventure.stops.count) stops")
    }
    
    private func startAdventure(_ adventure: AdventurePlan) {
        // TODO: Implement adventure start logic
        HapticFeedback.shared.impact(style: .medium)
    }
    
    private func shareAdventure(_ adventure: AdventurePlan) {
        // TODO: Implement adventure sharing logic
        HapticFeedback.shared.impact(style: .light)
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var authService = DependencyContainer.shared.authenticationService
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showLogin = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppleColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppleSpacing.xl) {
                        // Profile Header
                        profileHeader
                        
                        // Settings Sections
                        VStack(spacing: AppleSpacing.md) {
                            if authService.currentUser == nil {
                                loginSection
                            }
                            settingsSection
                            preferencesSection
                            aboutSection
                        }
                    }
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.top, AppleSpacing.sm)
                }
            }
            .appleNavigationBar()
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showSettings) {
        SettingsView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: AppleSpacing.lg) {
            // Profile Picture with enhanced glassmorphism
            ZStack {
                // Outer glow
                Circle()
                    .fill(AppleColors.brandGradient)
                    .frame(width: 100, height: 100)
                    .blur(radius: 8)
                    .opacity(0.3)
                
                // Main avatar
                Circle()
                    .fill(AppleColors.brandGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(AppleColors.glassInnerHighlight, lineWidth: 2)
                            .blendMode(.overlay)
                    )
                    .appleShadow(AppleShadows.glass)
                
                if let user = authService.currentUser {
                    // Show user initials if available
                    Text(user.displayName.prefix(2).uppercased())
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: AppleSpacing.sm) {
                if let user = authService.currentUser {
                    Text("Welcome back, \(user.displayName)")
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(user.email)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Welcome to Shvil")
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your adventure companion")
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.vertical, AppleSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xxl)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(AppleShadows.glass)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(authService.currentUser != nil ? "Welcome back, \(authService.currentUser?.displayName ?? "")" : "Welcome to Shvil, Your adventure companion")
    }
    
    private var loginSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(spacing: AppleSpacing.lg) {
                VStack(spacing: AppleSpacing.sm) {
                    Text("Sign in to sync your adventures")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Access your saved adventures across all devices")
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                AppleButton(
                    "Sign In",
                    icon: "person.circle",
                    style: .primary,
                    size: .large
                ) {
                    showLogin = true
                }
            }
        }
    }
    
    private var settingsSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Settings")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
                
                VStack(spacing: 0) {
                    AppleGlassListRow(
                        icon: "gear",
                        title: "General Settings",
                        action: {
                            showSettings = true
                        }
                    )
                    
                    Divider()
                        .background(AppleColors.glassLight)
                    
                    AppleGlassListRow(
                        icon: "bell",
                        title: "Notifications",
                        action: {
                            // Notification settings
                        }
                    )
                    
                    if authService.currentUser != nil {
                        Divider()
                            .background(AppleColors.glassLight)
                        
                        AppleGlassListRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Sign Out",
                            action: {
                                Task {
                                    await authService.signOut()
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var preferencesSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("Preferences")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
                
                VStack(spacing: 0) {
                    AppleGlassListRow(
                        icon: "globe",
                        title: "Language",
                        trailing: AnyView(
                            Text(localizationManager.currentLanguage.displayName)
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                        ),
                        action: {
                            // Language settings
                        }
                    )
                    
                    Divider()
                        .background(AppleColors.glassLight)
                    
                    AppleGlassListRow(
                        icon: "paintbrush",
                        title: "Appearance",
                        action: {
                            // Theme settings
                        }
                    )
                }
            }
        }
    }
    
    private var aboutSection: some View {
        AppleGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.md) {
                Text("About")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
                
                VStack(spacing: 0) {
                    AppleGlassListRow(
                        icon: "info.circle",
                        title: "About Shvil",
                        action: {
                            showAbout = true
                        }
                    )
                    
                    Divider()
                        .background(AppleColors.glassLight)
                    
                    AppleGlassListRow(
                        icon: "hand.raised",
                        title: "Privacy Policy",
                        action: {
                            // Privacy policy
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Settings and About Views
// Note: SettingsView and AboutView are implemented in Features/SettingsView.swift

#Preview {
    ContentView()
}