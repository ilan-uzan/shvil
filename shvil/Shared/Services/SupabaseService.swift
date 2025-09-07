//
//  SupabaseService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import Foundation
import Supabase

public class SupabaseService: ObservableObject {
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

        // Test connection only if properly configured
        if Configuration.isSupabaseConfigured {
            Task {
                await testConnection()
            }
        } else {
            print("⚠️ WARNING: Supabase not configured. Using placeholder values.")
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
            userId: UUID(), // Default user ID
            routeData: RouteData(
                origin: LocationData(latitude: 0, longitude: 0), // Default origin
                destination: LocationData(latitude: 0, longitude: 0), // Default destination
                waypoints: [], // Empty waypoints
                distance: Double(route.distance) ?? 0.0, // Convert string to double
                duration: TimeInterval(route.duration) ?? 0.0, // Convert string to TimeInterval
                transportMode: route.type,
                estimatedArrival: Date().addingTimeInterval(TimeInterval(route.duration) ?? 0.0)
            ),
            recipients: recipients.compactMap { UUID(uuidString: $0) },
            isActive: true,
            expiresAt: Date().addingTimeInterval(3600), // 1 hour
            createdAt: Date(),
            updatedAt: Date()
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

// MARK: - Social Features

extension SupabaseService {
    // MARK: - Group Management
    
    func createGroup(_ group: SocialGroup) async throws -> SocialGroup {
        let response: SocialGroup = try await client
            .from("social_groups")
            .insert(group)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func joinGroup(inviteCode: String) async throws -> SocialGroup {
        let response: SocialGroup = try await client
            .from("social_groups")
            .select()
            .eq("invite_code", value: inviteCode)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func leaveGroup(groupId: UUID) async throws {
        try await client
            .from("group_members")
            .delete()
            .eq("group_id", value: groupId)
            .execute()
    }
    
    func updateGroup(_ group: SocialGroup) async throws -> SocialGroup {
        let response: SocialGroup = try await client
            .from("social_groups")
            .update(group)
            .eq("id", value: group.id)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getUserGroups() async throws -> [SocialGroup] {
        let response: [SocialGroup] = try await client
            .from("social_groups")
            .select()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Friend Management
    
    func addFriend(userId: UUID) async throws {
        // TODO: Implement friend addition
    }
    
    func removeFriend(userId: UUID) async throws {
        // TODO: Implement friend removal
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let response: [User] = try await client
            .from("users")
            .select()
            .ilike("display_name", value: "%\(query)%")
            .execute()
            .value
        
        return response
    }
}

// MARK: - Hunt Features

extension SupabaseService {
    // MARK: - Hunt Management
    
    func createHunt(_ hunt: ScavengerHunt) async throws -> ScavengerHunt {
        let response: ScavengerHunt = try await client
            .from("scavenger_hunts")
            .insert(hunt)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func joinHunt(huntCode: String) async throws -> ScavengerHunt {
        let response: ScavengerHunt = try await client
            .from("scavenger_hunts")
            .select()
            .eq("invite_code", value: huntCode)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func startHunt(huntId: UUID) async throws -> ScavengerHunt {
        let response: ScavengerHunt = try await client
            .from("scavenger_hunts")
            .update(["status": "active", "start_time": Date().ISO8601Format()])
            .eq("id", value: huntId)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func completeHunt(huntId: UUID) async throws -> ScavengerHunt {
        let response: ScavengerHunt = try await client
            .from("scavenger_hunts")
            .update(["status": "completed", "end_time": Date().ISO8601Format()])
            .eq("id", value: huntId)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func cancelHunt(huntId: UUID) async throws -> ScavengerHunt {
        let response: ScavengerHunt = try await client
            .from("scavenger_hunts")
            .update(["status": "cancelled"])
            .eq("id", value: huntId)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getHunt(huntId: UUID) async throws -> ScavengerHunt {
        let response: ScavengerHunt = try await client
            .from("scavenger_hunts")
            .select()
            .eq("id", value: huntId)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getUserHunts() async throws -> [ScavengerHunt] {
        let response: [ScavengerHunt] = try await client
            .from("scavenger_hunts")
            .select()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Checkpoint Management
    
    func getHuntCheckpoints(huntId: UUID) async throws -> [HuntCheckpoint] {
        let response: [HuntCheckpoint] = try await client
            .from("hunt_checkpoints")
            .select()
            .eq("hunt_id", value: huntId)
            .order("order_index")
            .execute()
            .value
        
        return response
    }
    
    func submitCheckpoint(_ submission: CheckpointSubmission) async throws {
        try await client
            .from("checkpoint_submissions")
            .insert(submission)
            .execute()
    }
    
    // MARK: - Leaderboard
    
    func getHuntLeaderboard(huntId: UUID) async throws -> [LeaderboardParticipant] {
        let response: [LeaderboardParticipant] = try await client
            .from("hunt_leaderboard")
            .select()
            .eq("hunt_id", value: huntId)
            .order("score", ascending: false)
            .execute()
            .value
        
        return response
    }
}
