//
//  OnboardingView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showAuthOptions = false
    @Environment(\.dismiss) private var dismiss
    
    private let pages = [
        OnboardingPage(
            icon: "location.fill",
            title: "Location Access",
            description: "Shvil needs your location to provide accurate navigation and show your position on the map.",
            color: .green
        ),
        OnboardingPage(
            icon: "person.2.fill",
            title: "Community Features",
            description: "Share and see traffic reports, hazards, and roadwork to help everyone navigate better.",
            color: .orange
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Privacy First",
            description: "Your location data stays on your device. We only collect what's necessary for navigation.",
            color: .blue
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
            
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Navigation Buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    Button("Get Started") {
                        showAuthOptions = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showAuthOptions) {
            AuthOptionsView()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
                .shadow(color: page.color.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
