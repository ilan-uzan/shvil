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
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Step content
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
                .animation(.easeInOut, value: currentStep)
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                        if currentStep == totalSteps - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Text("Welcome to Shvil")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your adventure starts here")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
    
    private var languageStep: some View {
        VStack(spacing: 20) {
            Text("Choose Language")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Button("English") {
                    // Language selection
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("עברית") {
                    // Language selection
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
    }
    
    private var permissionsStep: some View {
        VStack(spacing: 20) {
            Text("Enable Location")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("We need your location to provide the best experience")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
}