//
//  Place.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

// MARK: - Place Model
struct Place: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String?
    let coordinate: Coordinate
    let category: PlaceCategory?
    let phoneNumber: String?
    let website: String?
    let rating: Double?
    let priceLevel: Int?
    let isOpen: Bool?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case coordinate
        case category
        case phoneNumber = "phone_number"
        case website
        case rating
        case priceLevel = "price_level"
        case isOpen = "is_open"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Coordinate
struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from clLocation: CLLocationCoordinate2D) {
        self.latitude = clLocation.latitude
        self.longitude = clLocation.longitude
    }
}

// MARK: - Place Category
enum PlaceCategory: String, Codable, CaseIterable {
    case restaurant = "restaurant"
    case gasStation = "gas_station"
    case parking = "parking"
    case hotel = "hotel"
    case attraction = "attraction"
    case shopping = "shopping"
    case healthcare = "healthcare"
    case education = "education"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .gasStation: return "Gas Station"
        case .parking: return "Parking"
        case .hotel: return "Hotel"
        case .attraction: return "Attraction"
        case .shopping: return "Shopping"
        case .healthcare: return "Healthcare"
        case .education: return "Education"
        case .other: return "Other"
        }
    }
    
    var emoji: String {
        switch self {
        case .restaurant: return "🍽️"
        case .gasStation: return "⛽"
        case .parking: return "🅿️"
        case .hotel: return "🏨"
        case .attraction: return "🎯"
        case .shopping: return "🛍️"
        case .healthcare: return "🏥"
        case .education: return "🎓"
        case .other: return "📍"
        }
    }
}

// MARK: - Saved Place
struct SavedPlace: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    let place: Place
    let customName: String?
    let emoji: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case place
        case customName = "custom_name"
        case emoji
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var displayName: String {
        return customName ?? place.name
    }
    
    var displayEmoji: String {
        return emoji ?? place.category?.emoji ?? "📍"
    }
}
