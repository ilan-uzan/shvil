//
//  OnboardingView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var hasCompletedOnboarding = false
    
    private let totalSteps = 3
    
    var body: some View {
        ZStack {
            // Liquid Glass Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    DesignTokens.Brand.primary.opacity(0.1),
                    DesignTokens.Brand.primaryMid.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Step content with Liquid Glass cards
                Group {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        languageStep
                    case 2:
                        permissionsStep
                    default:
                        welcomeStep
                    }
                }
                .animation(DesignTokens.Animation.complex, value: currentStep)
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Circle()
                            .fill(index <= currentStep ? DesignTokens.Brand.primary : DesignTokens.Surface.tertiary)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentStep ? 1.2 : 1.0)
                            .animation(DesignTokens.Animation.standard, value: currentStep)
                    }
                }
                .padding(.bottom, 20)
                
                // Navigation buttons with Liquid Glass
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(DesignTokens.Animation.standard) {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(DesignTokens.Text.secondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .fill(DesignTokens.Surface.secondary)
                                .appleShadow(DesignTokens.Shadow.light)
                        )
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                        if currentStep == totalSteps - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation(DesignTokens.Animation.standard) {
                                currentStep += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(DesignTokens.Brand.gradient)
                            .appleShadow(DesignTokens.Shadow.medium)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 24) {
            // App icon placeholder with Liquid Glass effect
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(DesignTokens.Brand.gradient)
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "location.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                )
                .appleShadow(DesignTokens.Shadow.glass)
            
            VStack(spacing: 16) {
                Text("Welcome to Shvil")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("Your adventure starts here")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
    }
    
    private var languageStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Choose Language")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("Select your preferred language")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
            }
            
            VStack(spacing: 12) {
                LanguageOption(
                    title: "English",
                    flag: "🇺🇸",
                    isSelected: true
                )
                
                LanguageOption(
                    title: "עברית",
                    flag: "🇮🇱",
                    isSelected: false
                )
            }
        }
        .padding(.horizontal, 32)
    }
    
    private var permissionsStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "location.fill")
                    .font(.system(size: 48))
                    .foregroundColor(DesignTokens.Brand.primary)
                
                Text("Enable Location")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("We need your location to provide the best adventure experience")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation(DesignTokens.Animation.complex) {
            hasCompletedOnboarding = true
        }
    }
}

struct LanguageOption: View {
    let title: String
    let flag: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(flag)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignTokens.Text.primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignTokens.Brand.primary)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(isSelected ? DesignTokens.Surface.primary : DesignTokens.Surface.secondary)
                .appleShadow(DesignTokens.Shadow.light)
        )
    }
}

#Preview {
    OnboardingView()
}