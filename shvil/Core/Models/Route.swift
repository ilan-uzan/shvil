//
//  Route.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import Foundation
import MapKit

// MARK: - Route Models

/// Represents a calculated route with multiple options
public struct Route: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let distance: Double // in meters
    public let expectedTravelTime: TimeInterval // in seconds
    public let polyline: [CLLocationCoordinate2D]
    public let steps: [RouteStep]
    public let options: RouteOptions
    public var isFastest: Bool
    public var isSafest: Bool
    public let tollCost: Double?
    public let fuelCost: Double?
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        distance: Double,
        expectedTravelTime: TimeInterval,
        polyline: [CLLocationCoordinate2D],
        steps: [RouteStep],
        options: RouteOptions,
        isFastest: Bool = false,
        isSafest: Bool = false,
        tollCost: Double? = nil,
        fuelCost: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.polyline = polyline
        self.steps = steps
        self.options = options
        self.isFastest = isFastest
        self.isSafest = isSafest
        self.tollCost = tollCost
        self.fuelCost = fuelCost
        self.createdAt = createdAt
    }
}

/// Individual step in a route
public struct RouteStep: Identifiable, Codable {
    public let id: UUID
    public let instruction: String
    public let distance: Double // in meters
    public let expectedTravelTime: TimeInterval // in seconds
    public let polyline: [CLLocationCoordinate2D]
    public let maneuverType: ManeuverType
    public let laneGuidance: LaneGuidance?
    public let exitNumber: String?
    public let roadName: String?
    public let isToll: Bool
    public let isHighway: Bool
    
    public init(
        id: UUID = UUID(),
        instruction: String,
        distance: Double,
        expectedTravelTime: TimeInterval,
        polyline: [CLLocationCoordinate2D],
        maneuverType: ManeuverType,
        laneGuidance: LaneGuidance? = nil,
        exitNumber: String? = nil,
        roadName: String? = nil,
        isToll: Bool = false,
        isHighway: Bool = false
    ) {
        self.id = id
        self.instruction = instruction
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.polyline = polyline
        self.maneuverType = maneuverType
        self.laneGuidance = laneGuidance
        self.exitNumber = exitNumber
        self.roadName = roadName
        self.isToll = isToll
        self.isHighway = isHighway
    }
}

/// Route calculation options
public struct RouteOptions: Codable {
    public let transportationMode: TransportationMode
    public var avoidTolls: Bool
    public var avoidHighways: Bool
    public var avoidFerries: Bool
    public var preferScenic: Bool
    public var avoidTunnels: Bool
    public let avoidBridges: Bool
    public let avoidDirtRoads: Bool
    public var optimizeFor: RouteOptimization
    
    public init(
        transportationMode: TransportationMode = .driving,
        avoidTolls: Bool = false,
        avoidHighways: Bool = false,
        avoidFerries: Bool = false,
        preferScenic: Bool = false,
        avoidTunnels: Bool = false,
        avoidBridges: Bool = false,
        avoidDirtRoads: Bool = false,
        optimizeFor: RouteOptimization = .fastest
    ) {
        self.transportationMode = transportationMode
        self.avoidTolls = avoidTolls
        self.avoidHighways = avoidHighways
        self.avoidFerries = avoidFerries
        self.preferScenic = preferScenic
        self.avoidTunnels = avoidTunnels
        self.avoidBridges = avoidBridges
        self.avoidDirtRoads = avoidDirtRoads
        self.optimizeFor = optimizeFor
    }
}

/// Transportation modes
public enum TransportationMode: String, CaseIterable, Codable {
    case driving
    case walking
    case cycling
    case publicTransport = "public_transport"
    case mixed = "mixed"
    
    public var displayName: String {
        switch self {
        case .driving: "Driving"
        case .walking: "Walking"
        case .cycling: "Cycling"
        case .publicTransport: "Public Transport"
        case .mixed: "Mixed"
        }
    }
    
    public var icon: String {
        switch self {
        case .driving: "car.fill"
        case .walking: "figure.walk"
        case .cycling: "bicycle"
        case .publicTransport: "bus.fill"
        case .mixed: "arrow.triangle.2.circlepath"
        }
    }
}

/// Route optimization strategies
public enum RouteOptimization: String, CaseIterable, Codable {
    case fastest
    case shortest
    case safest
    case mostScenic = "most_scenic"
    case mostEfficient = "most_efficient"
    
    public var displayName: String {
        switch self {
        case .fastest: "Fastest"
        case .shortest: "Shortest"
        case .safest: "Safest"
        case .mostScenic: "Most Scenic"
        case .mostEfficient: "Most Efficient"
        }
    }
}

/// Maneuver types for navigation
public enum ManeuverType: String, CaseIterable, Codable {
    case start
    case end
    case turnLeft = "turn_left"
    case turnRight = "turn_right"
    case turnSharpLeft = "turn_sharp_left"
    case turnSharpRight = "turn_sharp_right"
    case turnSlightLeft = "turn_slight_left"
    case turnSlightRight = "turn_slight_right"
    case straight
    case uTurn = "u_turn"
    case merge
    case exit
    case fork
    case roundabout
    case ramp
    case ferry
    case tunnel
    case bridge
    case toll
    case stop
    case yield
    case trafficLight = "traffic_light"
    case keepLeft = "keep_left"
    case keepRight = "keep_right"
    
    public var displayName: String {
        switch self {
        case .start: "Start"
        case .end: "End"
        case .turnLeft: "Turn Left"
        case .turnRight: "Turn Right"
        case .turnSharpLeft: "Sharp Left"
        case .turnSharpRight: "Sharp Right"
        case .turnSlightLeft: "Slight Left"
        case .turnSlightRight: "Slight Right"
        case .straight: "Continue Straight"
        case .uTurn: "U-Turn"
        case .merge: "Merge"
        case .exit: "Exit"
        case .fork: "Fork"
        case .roundabout: "Roundabout"
        case .ramp: "Ramp"
        case .ferry: "Ferry"
        case .tunnel: "Tunnel"
        case .bridge: "Bridge"
        case .toll: "Toll"
        case .stop: "Stop"
        case .yield: "Yield"
        case .trafficLight: "Traffic Light"
        case .keepLeft: "Keep Left"
        case .keepRight: "Keep Right"
        }
    }
    
    public var icon: String {
        switch self {
        case .start: "play.fill"
        case .end: "stop.fill"
        case .turnLeft: "arrow.turn.up.left"
        case .turnRight: "arrow.turn.up.right"
        case .turnSharpLeft: "arrow.turn.up.left"
        case .turnSharpRight: "arrow.turn.up.right"
        case .turnSlightLeft: "arrow.turn.up.left"
        case .turnSlightRight: "arrow.turn.up.right"
        case .straight: "arrow.up"
        case .uTurn: "arrow.uturn.up"
        case .merge: "arrow.triangle.merge"
        case .exit: "arrow.triangle.branch"
        case .fork: "arrow.triangle.branch"
        case .roundabout: "arrow.triangle.2.circlepath"
        case .ramp: "arrow.up.and.down.and.arrow.left.and.right"
        case .ferry: "ferry.fill"
        case .tunnel: "tunnel.fill"
        case .bridge: "bridge.fill"
        case .toll: "creditcard.fill"
        case .stop: "stop.circle.fill"
        case .yield: "yield"
        case .trafficLight: "trafficlight"
        case .keepLeft: "arrow.left"
        case .keepRight: "arrow.right"
        }
    }
}

/// Lane guidance information
public struct LaneGuidance: Codable {
    public let lanes: [Lane]
    public let activeLanes: [Int]
    public let instruction: String?
    
    public init(lanes: [Lane], activeLanes: [Int], instruction: String? = nil) {
        self.lanes = lanes
        self.activeLanes = activeLanes
        self.instruction = instruction
    }
}

/// Individual lane information
public struct Lane: Codable {
    public let index: Int
    public let isActive: Bool
    public let isRecommended: Bool
    public let maneuverTypes: [ManeuverType]
    public let isToll: Bool
    public let isHOV: Bool
    
    public init(
        index: Int,
        isActive: Bool,
        isRecommended: Bool,
        maneuverTypes: [ManeuverType],
        isToll: Bool = false,
        isHOV: Bool = false
    ) {
        self.index = index
        self.isActive = isActive
        self.isRecommended = isRecommended
        self.maneuverTypes = maneuverTypes
        self.isToll = isToll
        self.isHOV = isHOV
    }
}

