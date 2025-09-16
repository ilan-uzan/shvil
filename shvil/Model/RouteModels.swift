//
//  RouteModels.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

// MARK: - Location Data Model
public struct LocationData: Codable {
    public let latitude: Double
    public let longitude: Double
    public let address: String?
    public let name: String?
    
    public init(
        latitude: Double,
        longitude: Double,
        address: String? = nil,
        name: String? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.name = name
    }
    
    // Computed property for CoreLocation compatibility
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Route Data Model
public struct RouteData: Codable {
    public let origin: LocationData
    public let destination: LocationData
    public let distance: Double // in kilometers
    public let duration: Int // in minutes
    public let polyline: String? // encoded polyline
    public let steps: [RouteStep]
    public let transportType: String
    
    public init(
        origin: LocationData,
        destination: LocationData,
        distance: Double,
        duration: Int,
        polyline: String? = nil,
        steps: [RouteStep] = [],
        transportType: String = "driving"
    ) {
        self.origin = origin
        self.destination = destination
        self.distance = distance
        self.duration = duration
        self.polyline = polyline
        self.steps = steps
        self.transportType = transportType
    }
}

// RouteStep is already defined in Core/Models/Route.swift
