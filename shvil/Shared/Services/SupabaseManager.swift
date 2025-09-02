//
//  SupabaseManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine
import Supabase

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
    private let supabaseClient: SupabaseClient
    
    // MARK: - Initialization
    private init() {
        // Initialize Supabase client
        supabaseClient = SupabaseClient(
            supabaseURL: URL(string: Config.projectURL)!,
            supabaseKey: Config.anonKey
        )
        
        connectionStatus = .disconnected
        loadLocalData()
    }
    
    // MARK: - Connection Methods
    
    /// Test connection to Supabase
    func testConnection() async {
        connectionStatus = .connecting
        
        do {
            // Test the connection by making a simple query
            _ = try await supabaseClient.from("profiles").select("id").limit(1).execute()
            
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
    
    // MARK: - Supabase Sync Methods
    
    private func syncUserProfile(_ profile: UserProfile) async {
        do {
            _ = try await supabaseClient
                .from("profiles")
                .upsert(profile)
                .execute()
            print("Successfully synced user profile: \(profile.displayName)")
        } catch {
            print("Failed to sync user profile: \(error)")
        }
    }
    
    private func fetchUserProfile() async -> UserProfile? {
        do {
            let response = try await supabaseClient
                .from("profiles")
                .select("*")
                .single()
                .execute()
            
            let profile = try JSONDecoder().decode(UserProfile.self, from: response.data)
            print("Successfully fetched user profile: \(profile.displayName)")
            return profile
        } catch {
            print("Failed to fetch user profile: \(error)")
            return nil
        }
    }
    
    private func syncSavedPlace(_ place: SavedPlace) async {
        do {
            _ = try await supabaseClient
                .from("saved_places")
                .upsert(place)
                .execute()
            print("Successfully synced saved place: \(place.name)")
        } catch {
            print("Failed to sync saved place: \(error)")
        }
    }
    
    private func deleteSavedPlace(_ place: SavedPlace) async {
        do {
            _ = try await supabaseClient
                .from("saved_places")
                .delete()
                .eq("id", value: place.id.uuidString)
                .execute()
            print("Successfully deleted saved place: \(place.name)")
        } catch {
            print("Failed to delete saved place: \(error)")
        }
    }
    
    private func fetchSavedPlaces() async -> [SavedPlace] {
        do {
            let response = try await supabaseClient
                .from("saved_places")
                .select("*")
                .execute()
            
            let places = try JSONDecoder().decode([SavedPlace].self, from: response.data)
            print("Successfully fetched \(places.count) saved places")
            return places
        } catch {
            print("Failed to fetch saved places: \(error)")
            return []
        }
    }
    
    private func syncRecentSearch(_ search: SearchResult) async {
        do {
            _ = try await supabaseClient
                .from("recent_searches")
                .upsert(search)
                .execute()
            print("Successfully synced recent search: \(search.title)")
        } catch {
            print("Failed to sync recent search: \(error)")
        }
    }
    
    private func clearRecentSearchesFromServer() async {
        do {
            _ = try await supabaseClient
                .from("recent_searches")
                .delete()
                .execute()
            print("Successfully cleared recent searches from Supabase")
        } catch {
            print("Failed to clear recent searches: \(error)")
        }
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