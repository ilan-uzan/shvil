//
//  SupabaseService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import Foundation
import Supabase

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    let client: SupabaseClient
    @Published var isConnected = false
    @Published var lastError: Error?

    private init() {
        // Use configuration system for proper setup
        guard let url = URL(string: Configuration.supabaseURL) else {
            fatalError("Invalid Supabase URL: \(Configuration.supabaseURL)")
        }

        client = SupabaseClient(supabaseURL: url, supabaseKey: Configuration.supabaseAnonKey)

        // Test connection
        Task {
            await testConnection()
        }
    }

    // MARK: - Connection Management

    private func testConnection() async {
        do {
            // Simple test query to verify connection
            let _: [String] = try await client
                .from("saved_places")
                .select("id")
                .limit(1)
                .execute()
                .value

            await MainActor.run {
                self.isConnected = true
                self.lastError = nil
            }
        } catch {
            await MainActor.run {
                self.isConnected = false
                self.lastError = error
            }
            print("Supabase connection test failed: \(error)")
        }
    }

    func retryConnection() async {
        await testConnection()
    }

    // MARK: - User Authentication

    func signIn(email: String, password: String) async throws {
        guard isConnected else {
            throw SupabaseError.notConnected
        }

        do {
            let response = try await client.auth.signIn(email: email, password: password)
            print("User signed in: \(response.user.id)")
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }

    func signUp(email: String, password: String) async throws {
        guard isConnected else {
            throw SupabaseError.notConnected
        }

        do {
            let response = try await client.auth.signUp(email: email, password: password)
            print("User signed up: \(response.user.id)")
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }

    func signOut() async throws {
        do {
            try await client.auth.signOut()
            print("User signed out")
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }

    // MARK: - Saved Places

    func savePlace(_ place: SavedPlace) async throws {
        guard isConnected else {
            throw SupabaseError.notConnected
        }

        do {
            let response = try await client
                .from("saved_places")
                .insert(place)
                .execute()

            print("Place saved: \(response)")
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }

    func getSavedPlaces() async throws -> [SavedPlace] {
        guard isConnected else {
            throw SupabaseError.notConnected
        }

        do {
            let response: [SavedPlace] = try await client
                .from("saved_places")
                .select()
                .execute()
                .value

            return response
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }

    func deletePlace(id: UUID) async throws {
        guard isConnected else {
            throw SupabaseError.notConnected
        }

        do {
            try await client
                .from("saved_places")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
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
    
    // MARK: - Health Check
    
    func healthCheck() async throws -> HealthCheckResponse {
        let response: HealthCheckResponse = try await client
            .rpc("health_check")
            .execute()
            .value
        
        return response
    }
    
    func detailedHealthCheck() async throws -> DetailedHealthCheckResponse {
        let response: DetailedHealthCheckResponse = try await client
            .rpc("health_check_detailed")
            .execute()
            .value
        
        return response
    }
    
    func getSystemMetrics() async throws -> SystemMetrics {
        let response: SystemMetrics = try await client
            .rpc("get_system_metrics")
            .execute()
            .value
        
        return response
    }
}

// MARK: - Data Models

enum PlaceType: String, Codable, CaseIterable {
    case home
    case work
    case favorite
    case custom
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

    // Custom initializer for dictionary data
    static func from(dictionary: [String: Any]) -> SavedPlace? {
        guard let idString = dictionary["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let latitude = dictionary["latitude"] as? Double,
              let longitude = dictionary["longitude"] as? Double,
              let typeString = dictionary["type"] as? String,
              let type = PlaceType(rawValue: typeString),
              let createdAtTimestamp = dictionary["createdAt"] as? TimeInterval,
              let userIdString = dictionary["userId"] as? String,
              let userId = UUID(uuidString: userIdString)
        else {
            return nil
        }

        return SavedPlace(
            id: id,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            type: type,
            createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
            userId: userId
        )
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

// MARK: - Health Check Models
// Note: Health check models are defined in HealthCheckService.swift

// MARK: - Supabase Errors

enum SupabaseError: LocalizedError {
    case notConnected
    case authenticationFailed
    case networkError
    case invalidData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notConnected:
            "Not connected to Supabase. Please check your internet connection."
        case .authenticationFailed:
            "Authentication failed. Please check your credentials."
        case .networkError:
            "Network error occurred. Please try again."
        case .invalidData:
            "Invalid data received from server."
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}
