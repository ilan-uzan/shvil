//
//  Plan.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

// MARK: - Plan Model

struct Plan: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let hostId: UUID
    let hostName: String
    let hostAvatar: String?
    let status: PlanStatus
    let createdAt: Date
    let votingEndsAt: Date?
    let participants: [PlanParticipant]
    let options: [PlanOption]
    let location: CLLocationCoordinate2D?
    let maxParticipants: Int?
    let isPublic: Bool
    let tags: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        hostId: UUID,
        hostName: String,
        hostAvatar: String? = nil,
        status: PlanStatus,
        createdAt: Date = Date(),
        votingEndsAt: Date? = nil,
        participants: [PlanParticipant] = [],
        options: [PlanOption] = [],
        location: CLLocationCoordinate2D? = nil,
        maxParticipants: Int? = nil,
        isPublic: Bool = true,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.hostId = hostId
        self.hostName = hostName
        self.hostAvatar = hostAvatar
        self.status = status
        self.createdAt = createdAt
        self.votingEndsAt = votingEndsAt
        self.participants = participants
        self.options = options
        self.location = location
        self.maxParticipants = maxParticipants
        self.isPublic = isPublic
        self.tags = tags
    }
}

// MARK: - Plan Status

enum PlanStatus: String, CaseIterable, Codable {
    case all = "all"
    case voting = "voting"
    case locked = "locked"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .all: return "All Plans"
        case .voting: return "Voting"
        case .locked: return "Locked In"
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .all: return "blue"
        case .voting: return "orange"
        case .locked: return "green"
        case .active: return "blue"
        case .completed: return "gray"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Plan Participant

struct PlanParticipant: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let avatar: String?
    let joinedAt: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        avatar: String? = nil,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.avatar = avatar
        self.joinedAt = joinedAt
    }
}

// MARK: - Plan Option

struct PlanOption: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let votes: Int
    let location: CLLocationCoordinate2D?
    let description: String?
    let imageUrl: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        votes: Int = 0,
        location: CLLocationCoordinate2D? = nil,
        description: String? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.votes = votes
        self.location = location
        self.description = description
        self.imageUrl = imageUrl
    }
}

