//
//  SupabaseManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

// MARK: - Connection Status
enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case error(String)
}

// MARK: - Supabase Manager
@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastError: String?
    @Published var userProfile: UserProfile?
    @Published var savedPlaces: [SavedPlace] = []
    @Published var recentSearches: [SearchResult] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        connectionStatus = .disconnected
        loadLocalData()
    }
    
    // MARK: - Connection Methods
    
    /// Test connection to Supabase
    func testConnection() async {
        connectionStatus = .connecting
        
        do {
            // Simulate connection test
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // For now, we'll simulate a successful connection
            // In a real implementation, this would test the actual Supabase connection
            connectionStatus = .connected
            isConnected = true
            lastError = nil
            
        } catch {
            connectionStatus = .error(error.localizedDescription)
            isConnected = false
            lastError = error.localizedDescription
        }
    }
    
    /// Get health status
    func getHealthStatus() async -> String {
        // Simulate health check
        return "Supabase connection is healthy"
    }
    
    /// Validate configuration
    func validateConfiguration() -> Bool {
        return !Config.projectURL.isEmpty && !Config.anonKey.isEmpty
    }
    
    // MARK: - User Profile Methods
    
    /// Save user profile
    func saveUserProfile(_ profile: UserProfile) async {
        userProfile = profile
        saveLocalData()
        
        if isConnected {
            // Sync to Supabase
            await syncUserProfile(profile)
        }
    }
    
    /// Load user profile
    func loadUserProfile() async -> UserProfile? {
        if isConnected {
            // Load from Supabase
            return await fetchUserProfile()
        } else {
            // Load from local storage
            return userProfile
        }
    }
    
    // MARK: - Saved Places Methods
    
    /// Save a place
    func savePlace(_ place: SavedPlace) async {
        savedPlaces.append(place)
        saveLocalData()
        
        if isConnected {
            await syncSavedPlace(place)
        }
    }
    
    /// Delete a place
    func deletePlace(_ place: SavedPlace) async {
        savedPlaces.removeAll { $0.id == place.id }
        saveLocalData()
        
        if isConnected {
            await deleteSavedPlace(place)
        }
    }
    
    /// Load saved places
    func loadSavedPlaces() async -> [SavedPlace] {
        if isConnected {
            return await fetchSavedPlaces()
        } else {
            return savedPlaces
        }
    }
    
    // MARK: - Recent Searches Methods
    
    /// Save recent search
    func saveRecentSearch(_ search: SearchResult) async {
        // Remove if already exists
        recentSearches.removeAll { $0.id == search.id }
        
        // Add to beginning
        recentSearches.insert(search, at: 0)
        
        // Keep only last 20
        if recentSearches.count > 20 {
            recentSearches = Array(recentSearches.prefix(20))
        }
        
        saveLocalData()
        
        if isConnected {
            await syncRecentSearch(search)
        }
    }
    
    /// Clear recent searches
    func clearRecentSearches() async {
        recentSearches.removeAll()
        saveLocalData()
        
        if isConnected {
            await clearRecentSearchesFromServer()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadLocalData() {
        // Load from UserDefaults
        if let profileData = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            userProfile = profile
        }
        
        if let placesData = UserDefaults.standard.data(forKey: "savedPlaces"),
           let places = try? JSONDecoder().decode([SavedPlace].self, from: placesData) {
            savedPlaces = places
        }
        
        if let searchesData = UserDefaults.standard.data(forKey: "recentSearches"),
           let searches = try? JSONDecoder().decode([SearchResult].self, from: searchesData) {
            recentSearches = searches
        }
    }
    
    private func saveLocalData() {
        // Save to UserDefaults
        if let profile = userProfile,
           let profileData = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(profileData, forKey: "userProfile")
        }
        
        if let placesData = try? JSONEncoder().encode(savedPlaces) {
            UserDefaults.standard.set(placesData, forKey: "savedPlaces")
        }
        
        if let searchesData = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(searchesData, forKey: "recentSearches")
        }
    }
    
    // MARK: - Supabase Sync Methods (Placeholders)
    
    private func syncUserProfile(_ profile: UserProfile) async {
        // TODO: Implement Supabase sync
    }
    
    private func fetchUserProfile() async -> UserProfile? {
        // TODO: Implement Supabase fetch
        return nil
    }
    
    private func syncSavedPlace(_ place: SavedPlace) async {
        // TODO: Implement Supabase sync
    }
    
    private func deleteSavedPlace(_ place: SavedPlace) async {
        // TODO: Implement Supabase delete
    }
    
    private func fetchSavedPlaces() async -> [SavedPlace] {
        // TODO: Implement Supabase fetch
        return []
    }
    
    private func syncRecentSearch(_ search: SearchResult) async {
        // TODO: Implement Supabase sync
    }
    
    private func clearRecentSearchesFromServer() async {
        // TODO: Implement Supabase clear
    }
}

// MARK: - User Profile Model
struct UserProfile: Codable {
    let id: UUID
    let email: String
    let displayName: String
    let avatarURL: String?
    let preferences: UserPreferences
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    let defaultTransportMode: TransportMode
    let voiceGuidanceEnabled: Bool
    let avoidTolls: Bool
    let avoidHighways: Bool
    let darkModeEnabled: Bool
    let notificationsEnabled: Bool
}