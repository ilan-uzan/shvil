//
//  AuthenticationManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var isGuest = false
    @Published var currentUser: User?
    @Published var hasCompletedOnboarding = false
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "hasCompletedOnboarding"
    private let guestModeKey = "isGuestMode"
    
    private init() {
        loadAuthenticationState()
    }
    
    // MARK: - Authentication State Management
    
    func signIn(user: User) {
        currentUser = user
        isAuthenticated = true
        isGuest = false
        saveAuthenticationState()
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        isGuest = false
        saveAuthenticationState()
    }
    
    func enterGuestMode() {
        currentUser = nil
        isAuthenticated = false
        isGuest = true
        saveAuthenticationState()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        userDefaults.removeObject(forKey: onboardingKey)
    }
    
    // MARK: - Private Methods
    
    private func loadAuthenticationState() {
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
        isGuest = userDefaults.bool(forKey: guestModeKey)
        
        // In a real app, you would load the user from secure storage
        // For now, we'll simulate the state
        if isGuest {
            isAuthenticated = false
        }
    }
    
    private func saveAuthenticationState() {
        userDefaults.set(isGuest, forKey: guestModeKey)
        
        if !isGuest {
            userDefaults.removeObject(forKey: guestModeKey)
        }
    }
    
    // MARK: - Computed Properties
    
    var shouldShowOnboarding: Bool {
        !hasCompletedOnboarding
    }
    
    var shouldShowWelcome: Bool {
        !hasCompletedOnboarding && !isAuthenticated && !isGuest
    }
    
    var isLoggedIn: Bool {
        isAuthenticated && !isGuest
    }
    
    var userDisplayName: String {
        if let user = currentUser {
            return user.displayName ?? user.email
        } else if isGuest {
            return "Guest"
        } else {
            return "User"
        }
    }
    
    // MARK: - Guest Mode Features
    
    func canAccessFeature(_ feature: GuestFeature) -> Bool {
        switch feature {
        case .basicNavigation:
            return true // Always available
        case .savedPlaces:
            return true // Local storage
        case .recentSearches:
            return true // Local storage
        case .communityReports:
            return true // Read-only for guests
        case .cloudSync:
            return isAuthenticated // Requires account
        case .advancedSettings:
            return isAuthenticated // Requires account
        }
    }
    
    func getFeatureLimitationMessage(for feature: GuestFeature) -> String? {
        guard !canAccessFeature(feature) else { return nil }
        
        switch feature {
        case .cloudSync:
            return "Sign in to sync your data across devices"
        case .advancedSettings:
            return "Sign in to access advanced settings"
        default:
            return "This feature requires an account"
        }
    }
}

// MARK: - Guest Features

enum GuestFeature {
    case basicNavigation
    case savedPlaces
    case recentSearches
    case communityReports
    case cloudSync
    case advancedSettings
}

// MARK: - Authentication State

enum AuthenticationState {
    case welcome
    case onboarding
    case guest
    case authenticated
    case unauthenticated
}
