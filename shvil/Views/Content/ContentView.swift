//
//  ContentView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
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
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Floating Liquid Glass Navigation
            VStack {
                Spacer()
                
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
            }
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    ContentView()
}