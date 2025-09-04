//
//  OnboardingView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation

/// Onboarding flow for first-time users
struct OnboardingView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var locationService = LocationService()
    @State private var currentStep = 0
    @State private var selectedLanguage: Language = .english
    @State private var selectedTheme: Theme = .system
    @State private var hasCompletedOnboarding = false
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Background
            AppleColors.background
                .ignoresSafeArea()
            
            if hasCompletedOnboarding {
                ContentView()
            } else {
                onboardingContent
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private var onboardingContent: some View {
        VStack(spacing: 0) {
            // Progress indicator
            progressIndicator
            
            // Content
            TabView(selection: $currentStep) {
                welcomeStep
                    .tag(0)
                
                languageStep
                    .tag(1)
                
                themeStep
                    .tag(2)
                
                permissionsStep
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(AppleAnimations.pageTransition, value: currentStep)
            
            // Navigation buttons
            navigationButtons
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: AppleSpacing.sm) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? AppleColors.accent : AppleColors.surfaceTertiary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(AppleAnimations.spring, value: currentStep)
            }
        }
        .padding(.top, AppleSpacing.lg)
        .padding(.bottom, AppleSpacing.xl)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            // App icon and title
            VStack(spacing: AppleSpacing.lg) {
                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .fill(AppleColors.primary)
                        .frame(width: 120, height: 120)
                        .appleShadow(AppleShadows.heavy)
                    
                    Image(systemName: "map.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: AppleSpacing.md) {
                    Text("welcome".localized)
                        .font(AppleTypography.largeTitle)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("welcome_subtitle".localized)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppleSpacing.xl)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, AppleSpacing.xl)
    }
    
    private var languageStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            VStack(spacing: AppleSpacing.xl) {
                VStack(spacing: AppleSpacing.md) {
                    Text("onboarding_step_1_title".localized)
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_1_description".localized)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppleSpacing.xl)
                }
                
                // Language selection
                VStack(spacing: AppleSpacing.md) {
                    ForEach(Language.allCases, id: \.self) { language in
                        languageOption(language)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, AppleSpacing.xl)
    }
    
    private var themeStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            VStack(spacing: AppleSpacing.xl) {
                VStack(spacing: AppleSpacing.md) {
                    Text("onboarding_step_2_title".localized)
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_2_description".localized)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppleSpacing.xl)
                }
                
                // Theme selection
                VStack(spacing: AppleSpacing.md) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        themeOption(theme)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, AppleSpacing.xl)
    }
    
    private var permissionsStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            VStack(spacing: AppleSpacing.xl) {
                VStack(spacing: AppleSpacing.md) {
                    Text("onboarding_step_3_title".localized)
                        .font(AppleTypography.title2)
                        .foregroundColor(AppleColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_3_description".localized)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppleSpacing.xl)
                }
                
                // Permission cards
                VStack(spacing: AppleSpacing.md) {
                    permissionCard(
                        icon: "location.fill",
                        title: "location_permission".localized,
                        description: "location_permission_description".localized,
                        isRequired: true
                    )
                    
                    permissionCard(
                        icon: "mic.fill",
                        title: "microphone_permission".localized,
                        description: "microphone_permission_description".localized,
                        isRequired: false
                    )
                    
                    permissionCard(
                        icon: "bell.fill",
                        title: "notification_permission".localized,
                        description: "notification_permission_description".localized,
                        isRequired: false
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, AppleSpacing.xl)
    }
    
    private func languageOption(_ language: Language) -> some View {
        AppleGlassCard(style: .glassmorphism) {
            HStack(spacing: AppleSpacing.md) {
                Text(language.displayName)
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(selectedLanguage == language ? .white : AppleColors.textPrimary)
                
                Spacer()
                
                if selectedLanguage == language {
                    AppleGlassStatusIndicator(status: .success, size: 20)
                }
            }
        }
        .onTapGesture {
            selectedLanguage = language
            localizationManager.setLanguage(language)
            HapticFeedback.shared.impact(style: .light)
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .stroke(selectedLanguage == language ? AppleColors.primary : Color.clear, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(selectedLanguage == language ? AppleColors.primary : Color.clear)
        )
    }
    
    private func themeOption(_ theme: Theme) -> some View {
        AppleGlassCard(style: .glassmorphism) {
            HStack(spacing: AppleSpacing.md) {
                Image(systemName: theme.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(selectedTheme == theme ? .white : AppleColors.accent)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    Text(theme.displayName)
                        .font(AppleTypography.bodyEmphasized)
                        .foregroundColor(selectedTheme == theme ? .white : AppleColors.textPrimary)
                    
                    Text(theme.description)
                        .font(AppleTypography.caption1)
                        .foregroundColor(selectedTheme == theme ? .white.opacity(0.8) : AppleColors.textSecondary)
                }
                
                Spacer()
                
                if selectedTheme == theme {
                    AppleGlassStatusIndicator(status: .success, size: 20)
                }
            }
        }
        .onTapGesture {
            selectedTheme = theme
            HapticFeedback.shared.impact(style: .light)
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .stroke(selectedTheme == theme ? AppleColors.primary : Color.clear, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(selectedTheme == theme ? AppleColors.primary : Color.clear)
        )
    }
    
    private func permissionCard(icon: String, title: String, description: String, isRequired: Bool) -> some View {
        AppleGlassCard(style: .glassmorphism) {
            HStack(spacing: AppleSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppleColors.accent)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                    HStack {
                        Text(title)
                            .font(AppleTypography.bodyEmphasized)
                            .foregroundColor(AppleColors.textPrimary)
                        
                        if isRequired {
                            Text("Required")
                                .font(AppleTypography.caption2)
                                .foregroundColor(AppleColors.error)
                                .padding(.horizontal, AppleSpacing.sm)
                                .padding(.vertical, AppleSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(AppleColors.error.opacity(0.2))
                                )
                        }
                    }
                    
                    Text(description)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: AppleSpacing.md) {
            if currentStep > 0 {
                AppleGlassButton(
                    title: "back".localized,
                    style: .secondary,
                    size: .medium
                ) {
                    withAnimation(AppleAnimations.standard) {
                        currentStep -= 1
                    }
                    HapticFeedback.shared.impact(style: .light)
                }
            }
            
            AppleGlassButton(
                title: currentStep < totalSteps - 1 ? "next".localized : "get_started".localized,
                style: .primary,
                size: .medium
            ) {
                if currentStep < totalSteps - 1 {
                    withAnimation(AppleAnimations.standard) {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
                HapticFeedback.shared.impact(style: .light)
            }
        }
        .padding(.horizontal, AppleSpacing.xl)
        .padding(.bottom, AppleSpacing.xxl)
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")
    }
    
    private func completeOnboarding() {
        // Save preferences
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selected_language")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selected_theme")
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        
        // Request permissions
        requestPermissions()
        
        // Complete onboarding
        withAnimation(AppleAnimations.complex) {
            hasCompletedOnboarding = true
        }
    }
    
    private func requestPermissions() {
        // Request location permission
        locationService.requestLocationPermission()
        
        // Request other permissions as needed
    }
}

// MARK: - Theme Enum

enum Theme: String, CaseIterable {
    case light
    case dark
    case system
    
    var displayName: String {
        switch self {
        case .light: "light_theme".localized
        case .dark: "dark_theme".localized
        case .system: "system_theme".localized
        }
    }
    
    var description: String {
        switch self {
        case .light: "Always use light appearance"
        case .dark: "Always use dark appearance"
        case .system: "Follow system appearance"
        }
    }
    
    var icon: String {
        switch self {
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        case .system: "gear"
        }
    }
}

#Preview {
    OnboardingView()
}
