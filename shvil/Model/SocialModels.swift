//
//  SocialModels.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

// MARK: - ETA Share Model
public struct ETAShare: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let destination: String
    public let estimatedArrival: Date
    public let latitude: Double
    public let longitude: Double
    public let message: String?
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        destination: String,
        estimatedArrival: Date,
        latitude: Double,
        longitude: Double,
        message: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.destination = destination
        self.estimatedArrival = estimatedArrival
        self.latitude = latitude
        self.longitude = longitude
        self.message = message
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Social Group Model
public struct SocialGroup: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let inviteCode: String
    public let createdBy: UUID
    public let memberCount: Int
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        inviteCode: String,
        createdBy: UUID,
        memberCount: Int = 1,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.inviteCode = inviteCode
        self.createdBy = createdBy
        self.memberCount = memberCount
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Scavenger Hunt Model
public struct ScavengerHunt: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let description: String
    public let huntCode: String
    public let createdBy: UUID
    public let status: HuntStatus
    public let startTime: Date?
    public let endTime: Date?
    public let maxParticipants: Int
    public let currentParticipants: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        huntCode: String,
        createdBy: UUID,
        status: HuntStatus = .draft,
        startTime: Date? = nil,
        endTime: Date? = nil,
        maxParticipants: Int = 50,
        currentParticipants: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.huntCode = huntCode
        self.createdBy = createdBy
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Hunt Status Enum
public enum HuntStatus: String, CaseIterable, Codable {
    case draft = "draft"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}

// MARK: - Hunt Checkpoint Model
public struct HuntCheckpoint: Codable, Identifiable {
    public let id: UUID
    public let huntId: UUID
    public let name: String
    public let description: String
    public let latitude: Double
    public let longitude: Double
    public let order: Int
    public let points: Int
    public let isRequired: Bool
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        huntId: UUID,
        name: String,
        description: String,
        latitude: Double,
        longitude: Double,
        order: Int,
        points: Int = 10,
        isRequired: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.huntId = huntId
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.order = order
        self.points = points
        self.isRequired = isRequired
        self.createdAt = createdAt
    }
}

// MARK: - Checkpoint Submission Model
public struct CheckpointSubmission: Codable, Identifiable {
    public let id: UUID
    public let huntId: UUID
    public let checkpointId: UUID
    public let userId: UUID
    public let submittedAt: Date
    public let photoUrl: String?
    public let notes: String?
    public let isVerified: Bool
    
    public init(
        id: UUID = UUID(),
        huntId: UUID,
        checkpointId: UUID,
        userId: UUID,
        submittedAt: Date = Date(),
        photoUrl: String? = nil,
        notes: String? = nil,
        isVerified: Bool = false
    ) {
        self.id = id
        self.huntId = huntId
        self.checkpointId = checkpointId
        self.userId = userId
        self.submittedAt = submittedAt
        self.photoUrl = photoUrl
        self.notes = notes
        self.isVerified = isVerified
    }
}

// MARK: - Leaderboard Participant Model
public struct LeaderboardParticipant: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let displayName: String
    public let avatarUrl: String?
    public let totalPoints: Int
    public let checkpointsCompleted: Int
    public let rank: Int
    public let lastActivity: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        displayName: String,
        avatarUrl: String? = nil,
        totalPoints: Int = 0,
        checkpointsCompleted: Int = 0,
        rank: Int = 0,
        lastActivity: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.totalPoints = totalPoints
        self.checkpointsCompleted = checkpointsCompleted
        self.rank = rank
        self.lastActivity = lastActivity
    }
}

// MARK: - Event Model
public struct Event: Codable, Identifiable {
    public let id: UUID
    public let type: String
    public let data: [String: Any]
    public let userId: UUID?
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        type: String,
        data: [String: Any] = [:],
        userId: UUID? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.userId = userId
        self.timestamp = timestamp
    }
    
    // Custom coding keys for Any type
    enum CodingKeys: String, CodingKey {
        case id, type, userId, timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        userId = try container.decodeIfPresent(UUID.self, forKey: .userId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        data = [:] // Simplified for now
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: - Supabase Analytics Event Model
public struct SupabaseAnalyticsEvent: Codable {
    public let event: String
    public let properties: [String: Any]
    public let userId: UUID?
    public let timestamp: Date
    
    public init(
        event: String,
        properties: [String: Any] = [:],
        userId: UUID? = nil,
        timestamp: Date = Date()
    ) {
        self.event = event
        self.properties = properties
        self.userId = userId
        self.timestamp = timestamp
    }
    
    // Custom coding keys for Any type
    enum CodingKeys: String, CodingKey {
        case event, userId, timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        event = try container.decode(String.self, forKey: .event)
        userId = try container.decodeIfPresent(UUID.self, forKey: .userId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        properties = [:] // Simplified for now
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(event, forKey: .event)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
