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
        VStack {
            // Simple tab content
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Simple bottom navigation
            HStack {
                ForEach(0..<5) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Text(tabTitle(for: index))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                    }
                }
            }
            .padding()
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Map"
        case 1: return "Social"
        case 2: return "Hunt"
        case 3: return "Adventure"
        case 4: return "Settings"
        default: return "Map"
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    ContentView()
}
