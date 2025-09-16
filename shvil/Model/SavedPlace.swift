//
//  SavedPlace.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

// MARK: - Place Type Enum
public enum PlaceType: String, CaseIterable, Codable {
    case home = "home"
    case work = "work"
    case favorite = "favorite"
    case custom = "custom"
}

// MARK: - Saved Place Model
public struct SavedPlace: Codable, Identifiable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let type: PlaceType
    public let createdAt: Date
    public let updatedAt: Date
    
    // Computed property for CoreLocation compatibility
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        type: PlaceType = .custom,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}
