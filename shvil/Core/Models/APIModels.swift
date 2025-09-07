//
//  APIModels.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let data: T?
    let error: APIError?
    let success: Bool
    let message: String?
}

struct APIError: Codable {
    let code: String
    let message: String
    let details: [String: String]?
}

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String?
    let avatarUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserProfile: Codable {
    let user: User
    let preferences: UserPreferences
    let stats: UserStats
}

struct UserPreferences: Codable {
    let language: String
    let theme: String
    let notifications: NotificationSettings
    let privacy: PrivacySettings
}

struct UserStats: Codable {
    let totalAdventures: Int
    let totalDistance: Double
    let favoritePlaces: Int
    let joinedAt: Date
}

// MARK: - Saved Places Models

struct SavedPlace: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let placeType: PlaceType
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name, address, latitude, longitude
        case placeType = "place_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum PlaceType: String, Codable, CaseIterable {
    case home = "home"
    case work = "work"
    case favorite = "favorite"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .favorite: return "Favorite"
        case .other: return "Other"
        }
    }
}

// MARK: - Friends Models

struct Friend: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let friendId: UUID
    let status: FriendStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum FriendStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case blocked = "blocked"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .blocked: return "Blocked"
        }
    }
}

// MARK: - ETA Share Models

struct ETAShare: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let routeData: RouteData
    let recipients: [UUID]
    let isActive: Bool
    let expiresAt: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case routeData = "route_data"
        case recipients
        case isActive = "is_active"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct RouteData: Codable {
    let origin: LocationData
    let destination: LocationData
    let waypoints: [LocationData]
    let distance: Double
    let duration: TimeInterval
    let transportMode: String
    let estimatedArrival: Date
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let address: String?
    let name: String?
}

// MARK: - Adventure Models

struct Adventure: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String?
    let routeData: RouteData
    let stops: [AdventureStop]
    let status: AdventureStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title, description
        case routeData = "route_data"
        case stops, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AdventureStop: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let location: LocationData
    let category: StopCategory
    let order: Int
    let estimatedDuration: TimeInterval
    let isCompleted: Bool
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, location, category, order
        case estimatedDuration = "estimated_duration"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
    }
}

enum AdventureStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

enum StopCategory: String, Codable, CaseIterable {
    case restaurant = "restaurant"
    case attraction = "attraction"
    case shopping = "shopping"
    case nature = "nature"
    case culture = "culture"
    case entertainment = "entertainment"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .attraction: return "Attraction"
        case .shopping: return "Shopping"
        case .nature: return "Nature"
        case .culture: return "Culture"
        case .entertainment: return "Entertainment"
        case .other: return "Other"
        }
    }
}

// MARK: - Safety Report Models

struct SafetyReport: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let latitude: Double
    let longitude: Double
    let reportType: String
    let description: String?
    let severity: Int
    let isResolved: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case latitude, longitude
        case reportType = "report_type"
        case description, severity
        case isResolved = "is_resolved"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Search Models

struct SearchResult: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String?
    let rating: Double?
    let distance: Double?
    let isOpen: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, category, rating, distance
        case isOpen = "is_open"
    }
}

struct SearchSuggestion: Codable, Identifiable {
    let id: UUID
    let text: String
    let category: String?
    let popularity: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, text, category, popularity
    }
}

// MARK: - Request Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case email, password
        case displayName = "display_name"
    }
}

struct CreateAdventureRequest: Codable {
    let title: String
    let description: String?
    let routeData: RouteData
    let stops: [AdventureStop]
    let theme: String?
    let mood: String?
}

struct UpdateAdventureRequest: Codable {
    let title: String?
    let description: String?
    let status: AdventureStatus?
    let stops: [AdventureStop]?
}

struct CreateSafetyReportRequest: Codable {
    let latitude: Double
    let longitude: Double
    let reportType: String
    let description: String?
    let severity: Int
}

struct CreateETAShareRequest: Codable {
    let routeData: RouteData
    let recipients: [UUID]
    let expiresAt: Date
}

// MARK: - Pagination Models

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: PaginationInfo
}

struct PaginationInfo: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrevious: Bool
    
    enum CodingKeys: String, CodingKey {
        case page, limit, total
        case totalPages = "total_pages"
        case hasNext = "has_next"
        case hasPrevious = "has_previous"
    }
}

// MARK: - Error Models

enum APIErrorType: String, Codable {
    case validation = "validation"
    case authentication = "authentication"
    case authorization = "authorization"
    case notFound = "not_found"
    case conflict = "conflict"
    case rateLimit = "rate_limit"
    case serverError = "server_error"
    case networkError = "network_error"
}

// MARK: - Extensions

extension Array where Element: Codable {
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

extension Array where Element: Codable & Hashable {
    func removingDuplicates() -> [Element] {
        return Array(Set(self))
    }
}
