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

public struct User: Codable, Identifiable {
    public let id: UUID
    public let email: String
    public let displayName: String?
    public let avatarUrl: String?
    public let createdAt: Date
    public let updatedAt: Date
    
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

public struct UserPreferences: Codable {
    public let language: String
    public let theme: String
    public let notifications: NotificationSettings
    public let privacy: PrivacySettings
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

public struct AdventureStop: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let location: LocationData
    public let category: StopCategory
    public let order: Int
    public let estimatedDuration: TimeInterval
    public let isCompleted: Bool
    public let completedAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        location: LocationData,
        category: StopCategory,
        order: Int = 0,
        estimatedDuration: TimeInterval = 3600,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.location = location
        self.category = category
        self.order = order
        self.estimatedDuration = estimatedDuration
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, location, category, order
        case estimatedDuration = "estimated_duration"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
    }
}

public enum AdventureStatus: String, Codable, CaseIterable {
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

public enum StopCategory: String, Codable, CaseIterable {
    case restaurant = "restaurant"
    case attraction = "attraction"
    case shopping = "shopping"
    case nature = "nature"
    case culture = "culture"
    case entertainment = "entertainment"
    case food = "food"
    case museum = "museum"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .attraction: return "Attraction"
        case .shopping: return "Shopping"
        case .nature: return "Nature"
        case .culture: return "Culture"
        case .entertainment: return "Entertainment"
        case .food: return "Food"
        case .museum: return "Museum"
        case .other: return "Other"
        }
    }
}

enum PriceLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .low: return "Budget-Friendly"
        case .medium: return "Moderate"
        case .high: return "Expensive"
        case .premium: return "Premium"
        }
    }
}

public enum AdventureMood: String, Codable, CaseIterable {
    case fun = "fun"
    case relaxing = "relaxing"
    case cultural = "cultural"
    case adventurous = "adventurous"
    
    var displayName: String {
        switch self {
        case .fun: return "Fun & Playful"
        case .relaxing: return "Relaxing & Peaceful"
        case .cultural: return "Cultural & Educational"
        case .adventurous: return "Adventurous & Bold"
        }
    }
}

public struct LocationData: Codable, Hashable {
    public let latitude: Double
    public let longitude: Double
    public let address: String?
    
    init(latitude: Double, longitude: Double, address: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Safety Report Models

public struct SafetyReport: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let latitude: Double
    public let longitude: Double
    public let reportType: String
    public let description: String?
    public let severity: Int
    public let isResolved: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
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

public struct SearchResult: Codable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let category: String?
    public let rating: Double?
    public let distance: Double?
    public let isOpen: Bool?
    
    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        category: String? = nil,
        rating: Double? = nil,
        distance: Double? = nil,
        isOpen: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.rating = rating
        self.distance = distance
        self.isOpen = isOpen
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, category, rating, distance
        case isOpen = "is_open"
    }
}

struct SearchSuggestion: Codable, Identifiable, Hashable {
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

// MARK: - Traffic and Toll Models

public struct TrafficCondition: Codable, Identifiable {
    public let id: UUID
    public let routeId: String
    public let severity: TrafficSeverity
    public let description: String
    public let location: CLLocationCoordinate2D
    public let startTime: Date
    public let endTime: Date?
    public let delay: Int // in minutes
    public let distance: Double // in meters
    
    init(
        id: UUID = UUID(),
        routeId: String,
        severity: TrafficSeverity,
        description: String,
        location: CLLocationCoordinate2D,
        startTime: Date,
        endTime: Date? = nil,
        delay: Int,
        distance: Double
    ) {
        self.id = id
        self.routeId = routeId
        self.severity = severity
        self.description = description
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.delay = delay
        self.distance = distance
    }
}

public enum TrafficSeverity: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case severe = "severe"
    
    var displayName: String {
        switch self {
        case .low: "Light Traffic"
        case .medium: "Moderate Traffic"
        case .high: "Heavy Traffic"
        case .severe: "Severe Traffic"
        }
    }
}

public struct TollCost: Codable, Identifiable {
    public let id: UUID
    public let routeId: String
    public let tollName: String
    public let cost: Double
    public let currency: String
    public let location: CLLocationCoordinate2D
    public let paymentMethod: TollPaymentMethod
    
    init(
        id: UUID = UUID(),
        routeId: String,
        tollName: String,
        cost: Double,
        currency: String = "USD",
        location: CLLocationCoordinate2D,
        paymentMethod: TollPaymentMethod
    ) {
        self.id = id
        self.routeId = routeId
        self.tollName = tollName
        self.cost = cost
        self.currency = currency
        self.location = location
        self.paymentMethod = paymentMethod
    }
}

public enum TollPaymentMethod: String, Codable, CaseIterable {
    case cash = "cash"
    case electronic = "electronic"
    case both = "both"
    
    var displayName: String {
        switch self {
        case .cash: "Cash Only"
        case .electronic: "Electronic Only"
        case .both: "Cash or Electronic"
        }
    }
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

// MARK: - Social Models

public struct SocialGroup: Codable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let createdBy: UUID
    public let inviteCode: String
    public let qrCode: String
    public let memberCount: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: UUID = UUID(), name: String, description: String? = nil, createdBy: UUID, inviteCode: String, qrCode: String, memberCount: Int = 1, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.createdBy = createdBy
        self.inviteCode = inviteCode
        self.qrCode = qrCode
        self.memberCount = memberCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Hunt Models

public struct ScavengerHunt: Codable, Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let createdBy: UUID
    public let groupId: UUID?
    public let status: HuntStatus
    public let startTime: Date?
    public let endTime: Date?
    public let participantCount: Int
    public let checkpointCount: Int
    public let progress: Double
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: UUID = UUID(), title: String, description: String? = nil, createdBy: UUID, groupId: UUID? = nil, status: HuntStatus = .draft, startTime: Date? = nil, endTime: Date? = nil, participantCount: Int = 0, checkpointCount: Int = 0, progress: Double = 0.0, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.createdBy = createdBy
        self.groupId = groupId
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.participantCount = participantCount
        self.checkpointCount = checkpointCount
        self.progress = progress
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum HuntStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
    
    public var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

public struct HuntCheckpoint: Codable, Identifiable, Hashable {
    public let id: UUID
    public let huntId: UUID
    public let title: String
    public let description: String?
    public let location: LocationData
    public let photoRequired: Bool
    public let points: Int
    public let orderIndex: Int
    public let createdAt: Date
    
    public init(id: UUID = UUID(), huntId: UUID, title: String, description: String? = nil, location: LocationData, photoRequired: Bool = false, points: Int = 10, orderIndex: Int, createdAt: Date = Date()) {
        self.id = id
        self.huntId = huntId
        self.title = title
        self.description = description
        self.location = location
        self.photoRequired = photoRequired
        self.points = points
        self.orderIndex = orderIndex
        self.createdAt = createdAt
    }
}

public struct CheckpointSubmission: Codable, Identifiable, Hashable {
    public let id: UUID
    public let checkpointId: UUID
    public let userId: UUID
    public let photoUrl: String?
    public let submittedAt: Date
    public let verified: Bool
    
    public init(id: UUID = UUID(), checkpointId: UUID, userId: UUID, photoUrl: String? = nil, submittedAt: Date = Date(), verified: Bool = false) {
        self.id = id
        self.checkpointId = checkpointId
        self.userId = userId
        self.photoUrl = photoUrl
        self.submittedAt = submittedAt
        self.verified = verified
    }
}

public struct LeaderboardParticipant: Codable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let score: Int
    public let completedCheckpoints: Int
    public let totalCheckpoints: Int
    
    public init(id: UUID = UUID(), name: String, score: Int, completedCheckpoints: Int, totalCheckpoints: Int) {
        self.id = id
        self.name = name
        self.score = score
        self.completedCheckpoints = completedCheckpoints
        self.totalCheckpoints = totalCheckpoints
    }
}
