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
        ShvilEmptyState(
            title: "No Adventures Yet",
            description: "Create your first adventure to start exploring amazing places and experiences.",
            actionTitle: "Create Adventure",
            action: {
                showAdventureSetup = true
            }
        )
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
        ShvilGlassCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
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
                        status: adventure.status == .completed ? .success : .info,
                        size: 20
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
                    AppleGlassButton(
                        title: "View",
                        style: .secondary,
                        size: .small
                    ) {
                        selectedAdventure = adventure
                    }
                    
                    if adventure.status == .draft {
                        AppleGlassButton(
                            title: "Start",
                            style: .primary,
                            size: .small
                        ) {
                            // Start adventure logic
                        }
                    }
                }
            }
        }
        .onTapGesture {
            selectedAdventure = adventure
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showSettings = false
    @State private var showAbout = false
    
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
    }
    
    private var profileHeader: some View {
        AppleGlassCard(style: .glassmorphism) {
            VStack(spacing: AppleSpacing.md) {
                // Profile Picture
                ZStack {
                    Circle()
                        .fill(AppleColors.brandPrimary)
                        .frame(width: 80, height: 80)
                        .appleShadow(AppleShadows.medium)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: AppleSpacing.xs) {
                    Text("Welcome to Shvil")
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                    
                    Text("Your adventure companion")
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            Text("Settings")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)
                .padding(.horizontal, AppleSpacing.sm)
            
            VStack(spacing: 0) {
                AppleGlassListRow(action: {
                    showSettings = true
                }) {
                    HStack(spacing: AppleSpacing.md) {
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppleColors.accent)
                            .frame(width: 24)
                        
                        Text("General Settings")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                    }
                }
                
                Divider()
                    .background(AppleColors.glassLight)
                
                AppleGlassListRow(action: {
                    // Notification settings
                }) {
                    HStack(spacing: AppleSpacing.md) {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppleColors.accent)
                            .frame(width: 24)
                        
                        Text("Notifications")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                    }
                }
            }
            .glassmorphism(intensity: .medium, cornerRadius: AppleCornerRadius.lg)
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            Text("Preferences")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)
                .padding(.horizontal, AppleSpacing.sm)
            
            VStack(spacing: 0) {
                AppleGlassListRow(action: {
                    // Language settings
                }) {
                    HStack(spacing: AppleSpacing.md) {
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppleColors.accent)
                            .frame(width: 24)
                        
                        Text("Language")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                        
                        Spacer()
                        
                        Text(localizationManager.currentLanguage.displayName)
                            .font(AppleTypography.caption1)
                            .foregroundColor(AppleColors.textSecondary)
                    }
                }
                
                Divider()
                    .background(AppleColors.glassLight)
                
                AppleGlassListRow(action: {
                    // Theme settings
                }) {
                    HStack(spacing: AppleSpacing.md) {
                        Image(systemName: "paintbrush")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppleColors.accent)
                            .frame(width: 24)
                        
                        Text("Appearance")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                    }
                }
            }
            .glassmorphism(intensity: .medium, cornerRadius: AppleCornerRadius.lg)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            Text("About")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)
                .padding(.horizontal, AppleSpacing.sm)
            
            VStack(spacing: 0) {
                AppleGlassListRow(action: {
                    showAbout = true
                }) {
                    HStack(spacing: AppleSpacing.md) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppleColors.accent)
                            .frame(width: 24)
                        
                        Text("About Shvil")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                    }
                }
                
                Divider()
                    .background(AppleColors.glassLight)
                
                AppleGlassListRow(action: {
                    // Privacy policy
                }) {
                    HStack(spacing: AppleSpacing.md) {
                        Image(systemName: "hand.raised")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppleColors.accent)
                            .frame(width: 24)
                        
                        Text("Privacy Policy")
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)
                    }
                }
            }
            .glassmorphism(intensity: .medium, cornerRadius: AppleCornerRadius.lg)
        }
    }
}

// MARK: - Settings and About Views
// Note: SettingsView and AboutView are implemented in Features/SettingsView.swift

#Preview {
    ContentView()
}