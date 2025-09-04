//
//  SocialKit.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import Supabase

// MARK: - Data Models

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
}

/// Supabase integration for social features
class SocialKit: ObservableObject {
    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var friends: [Friend] = []
    @Published var activeETASessions: [ETASession] = []
    @Published var groupTrips: [GroupTrip] = []
    @Published var friendsOnMap: [FriendLocation] = []

    // MARK: - Private Properties

    let client: SupabaseClient
    private var cancellables = Set<AnyCancellable>()
    private var realtimeChannels: [String: RealtimeChannelV2] = [:]

    // MARK: - Initialization

    init() {
        // Initialize Supabase client with proper configuration
        guard let url = URL(string: Configuration.supabaseURL) else {
            fatalError("Invalid Supabase URL: \(Configuration.supabaseURL)")
        }

        client = SupabaseClient(supabaseURL: url, supabaseKey: Configuration.supabaseAnonKey)

        setupAuthListener()
    }

    // MARK: - Authentication

    func signIn(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
        currentUser = convertToUser(response.user)
        isAuthenticated = true
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        currentUser = convertToUser(response.user)
        isAuthenticated = true
    }

    private func convertToUser(_ authUser: Auth.User) -> User {
        User(
            id: authUser.id,
            email: authUser.email ?? "",
            displayName: (authUser.userMetadata["display_name"] as? String) ?? "",
            avatarURL: (authUser.userMetadata["avatar_url"] as? String),
            createdAt: authUser.createdAt,
            updatedAt: authUser.updatedAt
        )
    }

    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
        isAuthenticated = false
        clearAllData()
    }

    // MARK: - ETA Sharing

    func startETASession(route: RouteInfo, recipients: [String]) async throws -> ETASession {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        let session = ETASession(
            id: UUID(),
            ownerId: userId,
            route: route,
            recipients: recipients,
            startedAt: Date(),
            expiresAt: Date().addingTimeInterval(3600), // 1 hour
            isActive: true
        )

        try await client
            .from("eta_sessions")
            .insert(session)
            .execute()

        activeETASessions.append(session)

        // Subscribe to realtime updates
        await subscribeToETASession(session.id)

        return session
    }

    func stopETASession(_ sessionId: UUID) async throws {
        try await client
            .from("eta_sessions")
            .update(["is_active": false])
            .eq("id", value: sessionId)
            .execute()

        activeETASessions.removeAll { $0.id == sessionId }

        // Unsubscribe from realtime updates
        await unsubscribeFromETASession(sessionId)
    }

    func updateETAPosition(sessionId: UUID, position: CLLocationCoordinate2D, eta: TimeInterval) async throws {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }
        
        let update = ETAPositionUpdate(
            userId: userId.uuidString,
            position: Coordinate(position),
            timestamp: Date(),
            eta: eta
        )

        try await client
            .from("eta_positions")
            .insert(update)
            .execute()
    }

    // MARK: - Group Trips

    func createGroupTrip(name: String) async throws -> GroupTrip {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        let trip = GroupTrip(
            id: UUID(),
            hostId: userId,
            name: name,
            startedAt: Date(),
            endedAt: nil,
            isActive: true
        )

        try await client
            .from("group_trips")
            .insert(trip)
            .execute()

        // Add host as participant
        try await addParticipantToTrip(trip.id, userId: userId, role: .host)

        groupTrips.append(trip)

        // Subscribe to trip updates
        await subscribeToGroupTrip(trip.id)

        return trip
    }

    func joinGroupTrip(tripId: UUID) async throws {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        try await addParticipantToTrip(tripId, userId: userId, role: .participant)
    }

    func leaveGroupTrip(tripId: UUID) async throws {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        try await client
            .from("group_participants")
            .update(["left_at": Date()])
            .eq("trip_id", value: tripId)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - Friends on Map

    func enableFriendsOnMap() async throws {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        // Update user preference
        try await client
            .from("user_preferences")
            .upsert([
                "user_id": userId.uuidString,
                "friends_on_map_enabled": "true",
            ])
            .execute()

        // Start sharing location
        await startLocationSharing()

        // Subscribe to friends' locations
        await subscribeToFriendsLocations()
    }

    func disableFriendsOnMap() async throws {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        // Update user preference
        try await client
            .from("user_preferences")
            .upsert([
                "user_id": userId.uuidString,
                "friends_on_map_enabled": "false",
            ])
            .execute()

        // Stop sharing location
        await stopLocationSharing()

        // Unsubscribe from friends' locations
        await unsubscribeFromFriendsLocations()
    }

    func updateLocation(_ location: CLLocationCoordinate2D) async throws {
        guard let userId = currentUser?.id else {
            throw SocialError.notAuthenticated
        }

        _ = FriendLocation(
            userId: userId,
            coordinate: location,
            timestamp: Date(),
            accuracy: 10.0
        )

        try await client
            .from("friends_presence")
            .upsert([
                "user_id": userId.uuidString,
                "lat": String(location.latitude),
                "lon": String(location.longitude),
                "updated_at": ISO8601DateFormatter().string(from: Date()),
            ])
            .execute()
    }

    // MARK: - Private Methods

    private func setupAuthListener() {
        // Listen for auth state changes
        // Implementation depends on Supabase Swift client
    }

    private func subscribeToETASession(_ sessionId: UUID) async {
        let channelName = "eta:\(sessionId.uuidString)"
        let channel = client.realtimeV2.channel(channelName)

        _ = channel.onBroadcast(event: "position_update") { payload in
            // Handle position updates
            print("Received position update: \(payload)")
        }

        do {
            try await channel.subscribeWithError()
            realtimeChannels[channelName] = channel
        } catch {
            print("Failed to subscribe to ETA session: \(error)")
        }
    }

    private func unsubscribeFromETASession(_ sessionId: UUID) async {
        let channelName = "eta:\(sessionId.uuidString)"
        if let channel = realtimeChannels[channelName] {
            await channel.unsubscribe()
            realtimeChannels.removeValue(forKey: channelName)
        }
    }

    private func subscribeToGroupTrip(_ tripId: UUID) async {
        let channelName = "trip:\(tripId.uuidString)"
        let channel = client.realtimeV2.channel(channelName)

        _ = channel.onBroadcast(event: "presence_update") { payload in
            // Handle presence updates
            print("Received presence update: \(payload)")
        }

        do {
            try await channel.subscribeWithError()
            realtimeChannels[channelName] = channel
        } catch {
            print("Failed to subscribe to group trip: \(error)")
        }
    }

    private func subscribeToFriendsLocations() async {
        let channelName = "friends:locations"
        let channel = client.realtimeV2.channel(channelName)

        _ = channel.onBroadcast(event: "location_update") { payload in
            // Handle friend location updates
            print("Received friend location update: \(payload)")
        }

        do {
            try await channel.subscribeWithError()
            realtimeChannels[channelName] = channel
        } catch {
            print("Failed to subscribe to friends locations: \(error)")
        }
    }

    private func unsubscribeFromFriendsLocations() async {
        let channelName = "friends:locations"
        if let channel = realtimeChannels[channelName] {
            await channel.unsubscribe()
            realtimeChannels.removeValue(forKey: channelName)
        }
    }

    private func startLocationSharing() async {
        // Implementation for starting location sharing
    }

    private func stopLocationSharing() async {
        // Implementation for stopping location sharing
    }

    private func addParticipantToTrip(_ tripId: UUID, userId: UUID, role: ParticipantRole) async throws {
        let participant = GroupParticipant(
            tripId: tripId,
            userId: userId,
            role: role,
            joinedAt: Date(),
            leftAt: nil
        )

        try await client
            .from("group_participants")
            .insert(participant)
            .execute()
    }

    private func clearAllData() {
        friends.removeAll()
        activeETASessions.removeAll()
        groupTrips.removeAll()
        friendsOnMap.removeAll()

        // Unsubscribe from all channels
        for channel in realtimeChannels.values {
            Task {
                await channel.unsubscribe()
            }
        }
        realtimeChannels.removeAll()
    }
}

// MARK: - Supporting Types

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Friend: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let displayName: String
    let avatarUrl: String?
    let isOnline: Bool
}

struct ETASession: Identifiable, Codable {
    let id: UUID
    let ownerId: UUID
    let route: RouteInfo
    let recipients: [String]
    let startedAt: Date
    let expiresAt: Date
    let isActive: Bool
}

struct GroupTrip: Identifiable, Codable {
    let id: UUID
    let hostId: UUID
    let name: String
    let startedAt: Date
    let endedAt: Date?
    let isActive: Bool
}

struct GroupParticipant: Codable {
    let tripId: UUID
    let userId: UUID
    let role: ParticipantRole
    let joinedAt: Date
    let leftAt: Date?
}

enum ParticipantRole: String, Codable {
    case host
    case participant
}

struct FriendLocation: Identifiable {
    let id = UUID()
    let userId: UUID
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let accuracy: Double
}

struct ETAPositionUpdate: Codable {
    let userId: String
    let position: Coordinate
    let timestamp: Date
    let eta: TimeInterval
}

enum SocialError: Error {
    case notAuthenticated
    case networkError
    case invalidData
}
