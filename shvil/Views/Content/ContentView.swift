//
//  ContentView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

// MARK: - Import Dependencies
import Foundation

struct ContentView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var appState = DependencyContainer.shared.appState
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
        ZStack {
            // Main Content - Full Screen
            Group {
                switch selectedTab {
                case 0:
                    MapView()
                case 1:
                    SocializeView()
                case 2:
                    HuntView()
                case 3:
                    AdventureSetupView()
                case 4:
                    SettingsView()
                default:
                    MapView()
                }
            }
            .animation(DesignTokens.Animation.standard, value: selectedTab)
            .ignoresSafeArea(.all, edges: .bottom) // Allow content to go behind navigation
            .performanceOptimizedView()
            
            // Floating Liquid Glass Navigation - No Background Container
            VStack {
                Spacer()
                
                if FeatureFlags.shared.isEnabled(.liquidGlassNavV1) {
                    GlassTabBar(
                        tabs: [
                            GlassTabItem(icon: "map", selectedIcon: "map.fill", title: "Map", route: "map"),
                            GlassTabItem(icon: "person.3", selectedIcon: "person.3.fill", title: "Socialize", route: "socialize"),
                            GlassTabItem(icon: "flag", selectedIcon: "flag.fill", title: "Hunt", route: "hunt"),
                            GlassTabItem(icon: "sparkles", selectedIcon: "sparkles", title: "Adventure", route: "adventure"),
                            GlassTabItem(icon: "gearshape", selectedIcon: "gearshape.fill", title: "Settings", route: "settings")
                        ],
                        selectedTab: $selectedTab,
                        onSelect: { index in
                            selectedTab = index
                        }
                    )
                } else {
                    // Fallback to floating pill navigation
                    FloatingNavigationPill(
                        selectedTab: $selectedTab,
                        tabs: [
                            TabItem(icon: "map.fill", title: "Map"),
                            TabItem(icon: "person.3.fill", title: "Socialize"),
                            TabItem(icon: "flag.fill", title: "Hunt"),
                            TabItem(icon: "sparkles", title: "Adventure"),
                            TabItem(icon: "gearshape.fill", title: "Settings")
                        ]
                    )
                }
            }
        }
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
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                
                if adventureKit.adventureHistory.isEmpty {
                    emptyState
                } else {
                    adventuresList
                }
            }
            .overlay(
                // Floating Adventure Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAdventureSetup = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(DesignTokens.Brand.gradient)
                                        .shadow(
                                            color: DesignTokens.Shadow.heavy.color,
                                            radius: DesignTokens.Shadow.heavy.radius,
                                            x: DesignTokens.Shadow.heavy.x,
                                            y: DesignTokens.Shadow.heavy.y
                                        )
                                )
                        }
                        .padding(.trailing, DesignTokens.Spacing.md)
                        .padding(.bottom, 100) // Above tab bar
                    }
                }
            )
        }
        .sheet(isPresented: $showAdventureSetup) {
            AdventureSetupView()
        }
        .sheet(item: $selectedAdventure) { adventure in
            AdventureSheetView(adventure: adventure)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Spacer()
            
            // Empty state illustration
            ZStack {
                // Background wave
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .fill(DesignTokens.Brand.primary.opacity(0.1))
                    .frame(width: 120, height: 80)
                    .overlay(
                        // Wave pattern
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 40))
                            path.addQuadCurve(to: CGPoint(x: 120, y: 40), control: CGPoint(x: 60, y: 20))
                        }
                        .stroke(DesignTokens.Brand.primary.opacity(0.3), lineWidth: 2)
                    )
                
                // Adventure icon
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
            }
            
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("No Adventures Yet")
                    .font(DesignTokens.Typography.title2)
                    .foregroundColor(DesignTokens.Text.primary)
                    .multilineTextAlignment(.center)
                
                Text("Create your first adventure to start exploring amazing places and experiences.")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }
            
            // Create Adventure Button
            Button(action: {
                showAdventureSetup = true
            }) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Create Adventure")
                        .font(DesignTokens.Typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Brand.gradient)
                )
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
            
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No Adventures Yet. Create your first adventure to start exploring amazing places and experiences.")
    }
    
    private var adventuresList: some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(adventureKit.adventureHistory) { adventure in
                    adventureCard(for: adventure)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.sm)
        }
    }
    
    private func adventureCard(for adventure: AdventurePlan) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(adventure.theme.displayName)
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text(adventure.description)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Circle()
                    .fill(adventure.status == .completed ? DesignTokens.Semantic.success : DesignTokens.Semantic.info)
                    .frame(width: 12, height: 12)
            }
            
            // Stats
            HStack(spacing: DesignTokens.Spacing.lg) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    Text("\(adventure.totalDuration)h")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "location")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    Text("\(adventure.stops.count) stops")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
            }
            
            // Action buttons
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button("View") {
                    selectedAdventure = adventure
                }
                .font(DesignTokens.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(DesignTokens.Text.secondary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                        .fill(DesignTokens.Surface.secondary)
                )
                .accessibleButton(
                    label: "View adventure details",
                    hint: "Double tap to view \(adventure.theme.displayName) adventure details",
                    action: {
                        selectedAdventure = adventure
                    }
                )
                
                if adventure.status == .draft {
                    Button("Start") {
                        startAdventure(adventure)
                    }
                    .font(DesignTokens.Typography.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .fill(DesignTokens.Brand.primary)
                    )
                    .accessibleButton(
                        label: "Start adventure",
                        hint: "Double tap to start \(adventure.theme.displayName) adventure",
                        action: {
                            startAdventure(adventure)
                        }
                    )
                } else if adventure.status == .completed {
                    Button("Share") {
                        shareAdventure(adventure)
                    }
                    .font(DesignTokens.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .fill(DesignTokens.Surface.secondary)
                    )
                    .accessibleButton(
                        label: "Share adventure",
                        hint: "Double tap to share \(adventure.theme.displayName) adventure",
                        action: {
                            shareAdventure(adventure)
                        }
                    )
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .shadow(
    color: DesignTokens.Shadow.medium.color,
    radius: DesignTokens.Shadow.medium.radius,
    x: DesignTokens.Shadow.medium.x,
    y: DesignTokens.Shadow.medium.y
)
        .onTapGesture {
            selectedAdventure = adventure
        }
        .accessibleButton(
            label: "\(adventure.theme.displayName) adventure",
            hint: "\(adventure.totalDuration) hours, \(adventure.stops.count) stops. Double tap to view details.",
            action: {
                selectedAdventure = adventure
            }
        )
        .accessibleHitTarget()
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
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        // Profile Header
                        profileHeader
                        
                        // Settings Sections
                        VStack(spacing: DesignTokens.Spacing.md) {
                            if authService.currentUser == nil {
                                loginSection
                            }
                            settingsSection
                            preferencesSection
                            aboutSection
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.sm)
                }
            }
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
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Profile Picture with enhanced glassmorphism
            ZStack {
                // Outer glow
                Circle()
                    .fill(DesignTokens.Brand.gradient)
                    .frame(width: 100, height: 100)
                    .blur(radius: 8)
                    .opacity(0.3)
                
                // Main avatar
                Circle()
                    .fill(DesignTokens.Brand.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 2)
                            .blendMode(.overlay)
                    )
                    .shadow(
    color: DesignTokens.Shadow.glass.color,
    radius: DesignTokens.Shadow.glass.radius,
    x: DesignTokens.Shadow.glass.x,
    y: DesignTokens.Shadow.glass.y
)
                
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
            
            VStack(spacing: DesignTokens.Spacing.sm) {
                if let user = authService.currentUser {
                    Text("Welcome back, \(user.displayName)")
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(user.email)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Welcome to Shvil")
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your adventure companion")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xxl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xxl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xxl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .shadow(
    color: DesignTokens.Shadow.glass.color,
    radius: DesignTokens.Shadow.glass.radius,
    x: DesignTokens.Shadow.glass.x,
    y: DesignTokens.Shadow.glass.y
)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(authService.currentUser != nil ? "Welcome back, \(authService.currentUser?.displayName ?? "User")" : "Welcome to Shvil, Your adventure companion")
    }
    
    private var loginSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Sign in to sync your adventures")
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Access your saved adventures across all devices")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    showLogin = true
                }) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Sign In")
                            .font(DesignTokens.Typography.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(DesignTokens.Brand.gradient)
                    )
                }
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                        )
                )
        )
        .shadow(
            color: DesignTokens.Shadow.glass.color,
            radius: DesignTokens.Shadow.glass.radius,
            x: DesignTokens.Shadow.glass.x,
            y: DesignTokens.Shadow.glass.y
        )
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Settings")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)
            
            VStack(spacing: 0) {
                Button(action: {
                    showSettings = true
                }) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("General Settings")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(DesignTokens.Glass.light)
                
                Button(action: {
                    // Notification settings
                }) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("Notifications")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
                
                if authService.currentUser != nil {
                    Divider()
                        .background(DesignTokens.Glass.light)
                    
                    Button(action: {
                        Task {
                            await authService.signOut()
                        }
                    }) {
                        HStack(spacing: DesignTokens.Spacing.md) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DesignTokens.Semantic.error)
                                .frame(width: 24, height: 24)
                            
                            Text("Sign Out")
                                .font(DesignTokens.Typography.body)
                                .foregroundColor(DesignTokens.Semantic.error)
                            
                            Spacer()
                        }
                        .padding(.vertical, DesignTokens.Spacing.sm)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                        )
                )
        )
        .shadow(
            color: DesignTokens.Shadow.glass.color,
            radius: DesignTokens.Shadow.glass.radius,
            x: DesignTokens.Shadow.glass.x,
            y: DesignTokens.Shadow.glass.y
        )
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Preferences")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)
            
            VStack(spacing: 0) {
                Button(action: {
                    // Language settings
                }) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "globe")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("Language")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Spacer()
                        
                        Text(localizationManager.currentLanguage.displayName)
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(DesignTokens.Glass.light)
                
                Button(action: {
                    // Theme settings
                }) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "paintbrush")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("Appearance")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                        )
                )
        )
        .shadow(
            color: DesignTokens.Shadow.glass.color,
            radius: DesignTokens.Shadow.glass.radius,
            x: DesignTokens.Shadow.glass.x,
            y: DesignTokens.Shadow.glass.y
        )
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("About")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)
            
            VStack(spacing: 0) {
                Button(action: {
                    showAbout = true
                }) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("About Shvil")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(DesignTokens.Glass.light)
                
                Button(action: {
                    // Privacy policy
                }) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "hand.raised")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 24, height: 24)
                        
                        Text("Privacy Policy")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignTokens.Text.tertiary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                        )
                )
        )
        .shadow(
            color: DesignTokens.Shadow.glass.color,
            radius: DesignTokens.Shadow.glass.radius,
            x: DesignTokens.Shadow.glass.x,
            y: DesignTokens.Shadow.glass.y
        )
    }
}

// MARK: - Settings and About Views
// Note: SettingsView and AboutView are implemented in Features/SettingsView.swift

#Preview {
    ContentView()
}