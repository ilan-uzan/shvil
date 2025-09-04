//
//  SupabaseService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Supabase
import CoreLocation

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        // Replace with your actual Supabase URL and anon key
        let url = URL(string: "YOUR_SUPABASE_URL")!
        let key = "YOUR_SUPABASE_ANON_KEY"
        
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
    
    // MARK: - User Authentication
    func signIn(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        print("User signed in: \(response.user.id)")
    }
    
    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        print("User signed up: \(response.user.id)")
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        print("User signed out")
    }
    
    // MARK: - Saved Places
    func savePlace(_ place: SavedPlace) async throws {
        let response = try await client
            .from("saved_places")
            .insert(place)
            .execute()
        
        print("Place saved: \(response)")
    }
    
    func getSavedPlaces() async throws -> [SavedPlace] {
        let response: [SavedPlace] = try await client
            .from("saved_places")
            .select()
            .execute()
            .value
        
        return response
    }
    
    func deletePlace(id: UUID) async throws {
        try await client
            .from("saved_places")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Social Features
    func shareETA(route: RouteInfo, recipients: [String]) async throws {
        let shareData = ETAShare(
            id: UUID(),
            route: route,
            recipients: recipients,
            isActive: true,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600) // 1 hour
        )
        
        try await client
            .from("eta_shares")
            .insert(shareData)
            .execute()
    }
    
    func getActiveShares() async throws -> [ETAShare] {
        let response: [ETAShare] = try await client
            .from("eta_shares")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value
        
        return response
    }
}

// MARK: - Data Models
enum PlaceType: String, Codable, CaseIterable {
    case home = "home"
    case work = "work"
    case favorite = "favorite"
    case custom = "custom"
}

struct SavedPlace: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let type: PlaceType
    let createdAt: Date
    let userId: UUID
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct ETAShare: Codable, Identifiable {
    let id: UUID
    let route: RouteInfo
    let recipients: [String]
    let isActive: Bool
    let createdAt: Date
    let expiresAt: Date
}

struct RouteInfo: Codable {
    let duration: String
    let distance: String
    let type: String
    let isFastest: Bool
    let isSafest: Bool
}
