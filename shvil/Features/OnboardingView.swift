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
            LiquidGlassColors.background
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
            .animation(.easeInOut, value: currentStep)
            
            // Navigation buttons
            navigationButtons
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? LiquidGlassColors.accentText : LiquidGlassColors.glassSurface3)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon and title
            VStack(spacing: 24) {
                // App icon placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(LiquidGlassGradients.primaryGradient)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "map.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .shadow(color: LiquidGlassColors.accentTurquoise.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 16) {
                    Text("welcome".localized)
                        .font(LiquidGlassTypography.largeTitle)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("welcome_subtitle".localized)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var languageStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("onboarding_step_1_title".localized)
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_1_description".localized)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Language selection
                VStack(spacing: 16) {
                    ForEach(Language.allCases, id: \.self) { language in
                        languageOption(language)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var themeStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("onboarding_step_2_title".localized)
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_2_description".localized)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Theme selection
                VStack(spacing: 16) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        themeOption(theme)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var permissionsStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("onboarding_step_3_title".localized)
                        .font(LiquidGlassTypography.title)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("onboarding_step_3_description".localized)
                        .font(LiquidGlassTypography.body)
                        .foregroundColor(LiquidGlassColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Permission cards
                VStack(spacing: 16) {
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
        .padding(.horizontal, 32)
    }
    
    private func languageOption(_ language: Language) -> some View {
        Button(action: {
            selectedLanguage = language
            localizationManager.setLanguage(language)
            HapticFeedback.shared.impact(style: .light)
        }) {
            HStack(spacing: 16) {
                Text(language.displayName)
                    .font(LiquidGlassTypography.bodyMedium)
                    .foregroundColor(selectedLanguage == language ? .white : LiquidGlassColors.primaryText)
                
                Spacer()
                
                if selectedLanguage == language {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedLanguage == language ? 
                          AnyShapeStyle(LiquidGlassGradients.primaryGradient) : 
                          AnyShapeStyle(LiquidGlassColors.glassSurface1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func themeOption(_ theme: Theme) -> some View {
        Button(action: {
            selectedTheme = theme
            HapticFeedback.shared.impact(style: .light)
        }) {
            HStack(spacing: 16) {
                Image(systemName: theme.icon)
                    .font(.title2)
                    .foregroundColor(selectedTheme == theme ? .white : LiquidGlassColors.accentText)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(LiquidGlassTypography.bodyMedium)
                        .foregroundColor(selectedTheme == theme ? .white : LiquidGlassColors.primaryText)
                    
                    Text(theme.description)
                        .font(LiquidGlassTypography.caption)
                        .foregroundColor(selectedTheme == theme ? .white.opacity(0.8) : LiquidGlassColors.secondaryText)
                }
                
                Spacer()
                
                if selectedTheme == theme {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTheme == theme ? 
                          AnyShapeStyle(LiquidGlassGradients.primaryGradient) : 
                          AnyShapeStyle(LiquidGlassColors.glassSurface1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func permissionCard(icon: String, title: String, description: String, isRequired: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(LiquidGlassColors.accentText)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(LiquidGlassTypography.bodyMedium)
                        .foregroundColor(LiquidGlassColors.primaryText)
                    
                    if isRequired {
                        Text("Required")
                            .font(LiquidGlassTypography.caption)
                            .foregroundColor(LiquidGlassColors.accident)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(LiquidGlassColors.accident.opacity(0.2))
                            )
                    }
                }
                
                Text(description)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                    HapticFeedback.shared.impact(style: .light)
                }) {
                    Text("back".localized)
                        .font(LiquidGlassTypography.bodySemibold)
                        .foregroundColor(LiquidGlassColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LiquidGlassColors.glassSurface1)
                        )
                }
            }
            
            Button(action: {
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
                HapticFeedback.shared.impact(style: .light)
            }) {
                Text(currentStep < totalSteps - 1 ? "next".localized : "get_started".localized)
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LiquidGlassGradients.primaryGradient)
                    )
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
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
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
    
    private func requestPermissions() {
        // Request location permission
        locationService.requestLocationPermission()
        
        // Request other permissions as needed
        // This would typically be done through the respective services
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
