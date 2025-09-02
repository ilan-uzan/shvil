//
//  WelcomeView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 20) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Shvil")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Fast, Simple, Private Navigation")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Feature Highlights
                VStack(spacing: 16) {
                    WelcomeFeatureRow(icon: "magnifyingglass", title: "Instant Search", description: "Find places quickly")
                    WelcomeFeatureRow(icon: "location.fill", title: "Smart Directions", description: "Driving and walking modes")
                    WelcomeFeatureRow(icon: "person.2.fill", title: "Community Reports", description: "Lightweight traffic alerts")
                    WelcomeFeatureRow(icon: "lock.shield.fill", title: "Privacy First", description: "Your data stays local")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    NavigationLink(destination: OnboardingView()) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Get Started")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Skip to guest mode
                        showOnboarding = true
                    }) {
                        Text("Continue as Guest")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            GuestModeView()
        }
    }
}

struct WelcomeFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    WelcomeView()
}
