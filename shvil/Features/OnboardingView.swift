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
    @StateObject private var locationManager = LocationManager()
    @State private var currentStep = 0
    @State private var selectedLanguage: Language = .english
    @State private var selectedTheme: Theme = .system
    @State private var hasCompletedOnboarding = false
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Background
            DesignTokens.Surface.background
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
        .environment(\.layoutDirection, localizationManager.isRTL ? .rightToLeft : .leftToRight)
    }
    
    private var onboardingContent: some View {
        ZStack {
            // Background with wavy path motif
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            // Subtle wavy path decoration
            VStack {
                Spacer()
                // Simple wave illustration
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .fill(DesignTokens.Brand.primary.opacity(0.1))
                    .frame(width: 120, height: 80)
                    .overlay(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 40))
                            path.addQuadCurve(to: CGPoint(x: 120, y: 40), control: CGPoint(x: 60, y: 20))
                        }
                        .stroke(DesignTokens.Brand.primary.opacity(0.3), lineWidth: 2)
                    )
                    .frame(height: 100)
                    .offset(y: 50)
            }
            .ignoresSafeArea()
            
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
    }
    
    private var progressIndicator: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? DesignTokens.Brand.primary : DesignTokens.Stroke.light)
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(DesignTokens.Animation.spring, value: currentStep)
            }
        }
        .padding(.top, DesignTokens.Spacing.lg)
        .padding(.bottom, DesignTokens.Spacing.xl)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            // App icon and title
            VStack(spacing: DesignTokens.Spacing.lg) {
                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(DesignTokens.Brand.primary)
                        .frame(width: 120, height: 120)
                        .appleShadow(DesignTokens.Shadow.heavy)
                    
                    Image(systemName: "map.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("welcome".localized)
                        .font(AppleTypography.largeTitle)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("welcome_subtitle".localized)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
    
    private var languageStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("onboarding_step_1_title".localized)
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_1_description".localized)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                }
                
                // Language selection
                VStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(Language.allCases, id: \.self) { language in
                        languageOption(language)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
    
    private var themeStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("onboarding_step_2_title".localized)
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_2_description".localized)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                }
                
                // Theme selection
                VStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        themeOption(theme)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
    
    private var permissionsStep: some View {
        VStack(spacing: AppleSpacing.xxl) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("onboarding_step_3_title".localized)
                        .font(DesignTokens.Typography.title2)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_3_description".localized)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                }
                
                // Permission cards
                VStack(spacing: DesignTokens.Spacing.md) {
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
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
    
    private func languageOption(_ language: Language) -> some View {
        AppleGlassCard(style: .elevated) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Text(language.displayName)
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(selectedLanguage == language ? .white : DesignTokens.Text.primary)
                
                Spacer()
                
                if selectedLanguage == language {
                    AppleGlassStatusIndicator(status: .success)
                }
            }
        }
        .onTapGesture {
            selectedLanguage = language
            localizationManager.setLanguage(language)
            HapticFeedback.shared.impact(style: .light)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .stroke(selectedLanguage == language ? DesignTokens.Brand.primary : Color.clear, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(selectedLanguage == language ? DesignTokens.Brand.primary : Color.clear)
        )
        .accessibilityLabel("Language: \(language.displayName)")
        .accessibilityHint(selectedLanguage == language ? "Currently selected" : "Double tap to select this language")
        .accessibilityAddTraits(selectedLanguage == language ? .isSelected : [])
    }
    
    private func themeOption(_ theme: Theme) -> some View {
        AppleGlassCard(style: .elevated) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: theme.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(selectedTheme == theme ? .white : DesignTokens.Brand.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(theme.displayName)
                        .font(DesignTokens.Typography.bodyEmphasized)
                        .foregroundColor(selectedTheme == theme ? .white : DesignTokens.Text.primary)
                    
                    Text(theme.description)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(selectedTheme == theme ? .white.opacity(0.8) : DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                if selectedTheme == theme {
                    AppleGlassStatusIndicator(status: .success)
                }
            }
        }
        .onTapGesture {
            selectedTheme = theme
            HapticFeedback.shared.impact(style: .light)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .stroke(selectedTheme == theme ? DesignTokens.Brand.primary : Color.clear, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(selectedTheme == theme ? DesignTokens.Brand.primary : Color.clear)
        )
        .accessibilityLabel("Theme: \(theme.displayName)")
        .accessibilityHint(selectedTheme == theme ? "Currently selected" : "Double tap to select this theme")
        .accessibilityAddTraits(selectedTheme == theme ? .isSelected : [])
    }
    
    private func permissionCard(icon: String, title: String, description: String, isRequired: Bool) -> some View {
        AppleGlassCard(style: .elevated) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignTokens.Brand.primary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack {
                        Text(title)
                            .font(DesignTokens.Typography.bodyEmphasized)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        if isRequired {
                            Text("Required")
                                .font(AppleTypography.caption2)
                                .foregroundColor(DesignTokens.Semantic.error)
                                .padding(.horizontal, DesignTokens.Spacing.sm)
                                .padding(.vertical, DesignTokens.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(DesignTokens.Semantic.error.opacity(0.2))
                                )
                        }
                    }
                    
                    Text(description)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
            }
        }
        .accessibilityLabel("\(title). \(isRequired ? "Required permission" : "Optional permission"). \(description)")
        .accessibilityHint("This permission is \(isRequired ? "required" : "optional") for app functionality")
    }
    
    private var navigationButtons: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            if currentStep > 0 {
                AppleButton(
                    "back".localized,
                    style: .secondary,
                    size: .medium
                ) {
                    withAnimation(DesignTokens.Animation.standard) {
                        currentStep -= 1
                    }
                    HapticFeedback.shared.impact(style: .light)
                }
            }
            
            AppleButton(
                currentStep < totalSteps - 1 ? "next".localized : "get_started".localized,
                style: .primary,
                size: .medium
            ) {
                if currentStep < totalSteps - 1 {
                    withAnimation(DesignTokens.Animation.standard) {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
                HapticFeedback.shared.impact(style: .light)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
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
        locationManager.requestLocationPermission()
        
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
