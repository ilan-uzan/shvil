//
//  NavigationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import MapKit
import Combine

// MARK: - Transport Modes
enum TransportMode: String, CaseIterable, Codable {
    case car = "car"
    case bike = "bike"
    case walking = "walking"
    case transit = "transit"
    case truck = "truck"
    
    var displayName: String {
        switch self {
        case .car: return "Car"
        case .bike: return "Bike"
        case .walking: return "Walking"
        case .transit: return "Public Transit"
        case .truck: return "Truck"
        }
    }
    
    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .bike: return "bicycle"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        case .truck: return "truck.box.fill"
        }
    }
    
    var mapKitTransportType: MKDirectionsTransportType {
        switch self {
        case .car: return .automobile
        case .bike: return .walking // MapKit doesn't have bike, use walking
        case .walking: return .walking
        case .transit: return .transit
        case .truck: return .automobile // Use car routing for trucks
        }
    }
}

// MARK: - Route Options
struct RouteOptions: Codable {
    var transportMode: TransportMode
    var avoidTolls: Bool
    var avoidHighways: Bool
    var avoidFerries: Bool
    var preferBikeLanes: Bool
    var truckHeight: Double? // in meters
    var truckWeight: Double? // in tons
    var truckHazmat: Bool
    
    static let `default` = RouteOptions(
        transportMode: .car,
        avoidTolls: false,
        avoidHighways: false,
        avoidFerries: false,
        preferBikeLanes: true,
        truckHeight: nil,
        truckWeight: nil,
        truckHazmat: false
    )
}

// MARK: - Route Result
struct RouteResult: Identifiable, Codable {
    let id = UUID()
    let transportMode: TransportMode
    let distance: CLLocationDistance
    let expectedTravelTime: TimeInterval
    let polyline: [CLLocationCoordinate2D]
    let steps: [RouteStep]
    let tolls: [TollInfo]
    let gasStations: [GasStation]
    let trafficIncidents: [TrafficIncident]
    
    var formattedDistance: String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: distance)
    }
    
    var formattedTime: String {
        let hours = Int(expectedTravelTime) / 3600
        let minutes = Int(expectedTravelTime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Route Step
struct RouteStep: Identifiable, Codable {
    let id = UUID()
    let instructions: String
    let distance: CLLocationDistance
    let expectedTravelTime: TimeInterval
    let transportType: TransportMode
    let maneuverType: ManeuverType
    let coordinate: CLLocationCoordinate2D
    
    var formattedDistance: String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: distance)
    }
}

// MARK: - Maneuver Types
enum ManeuverType: String, Codable {
    case start = "start"
    case end = "end"
    case turnLeft = "turn_left"
    case turnRight = "turn_right"
    case continueStraight = "continue_straight"
    case merge = "merge"
    case exit = "exit"
    case roundabout = "roundabout"
    case ferry = "ferry"
    case transit = "transit"
    
    var icon: String {
        switch self {
        case .start: return "play.circle.fill"
        case .end: return "stop.circle.fill"
        case .turnLeft: return "arrow.turn.up.left"
        case .turnRight: return "arrow.turn.up.right"
        case .continueStraight: return "arrow.up"
        case .merge: return "arrow.merge"
        case .exit: return "arrow.branch"
        case .roundabout: return "arrow.clockwise"
        case .ferry: return "ferry.fill"
        case .transit: return "bus.fill"
        }
    }
}

// MARK: - Toll Information
struct TollInfo: Identifiable, Codable {
    let id = UUID()
    let name: String
    let cost: Double
    let currency: String
    let coordinate: CLLocationCoordinate2D
    
    var formattedCost: String {
        return "\(currency) \(String(format: "%.2f", cost))"
    }
}

// MARK: - Gas Station
struct GasStation: Identifiable, Codable {
    let id = UUID()
    let name: String
    let brand: String
    let coordinate: CLLocationCoordinate2D
    let gasPrices: [GasPrice]
    let amenities: [String]
    
    var lowestPrice: GasPrice? {
        gasPrices.min { $0.price < $1.price }
    }
}

// MARK: - Gas Price
struct GasPrice: Identifiable, Codable {
    let id = UUID()
    let fuelType: FuelType
    let price: Double
    let currency: String
    let lastUpdated: Date
    
    var formattedPrice: String {
        return "\(currency) \(String(format: "%.3f", price))"
    }
}

// MARK: - Fuel Types
enum FuelType: String, CaseIterable, Codable {
    case regular = "regular"
    case midgrade = "midgrade"
    case premium = "premium"
    case diesel = "diesel"
    case electric = "electric"
    
    var displayName: String {
        switch self {
        case .regular: return "Regular"
        case .midgrade: return "Midgrade"
        case .premium: return "Premium"
        case .diesel: return "Diesel"
        case .electric: return "Electric"
        }
    }
}

// MARK: - Traffic Incident
struct TrafficIncident: Identifiable, Codable {
    let id = UUID()
    let type: IncidentType
    let severity: IncidentSeverity
    let description: String
    let coordinate: CLLocationCoordinate2D
    let startTime: Date
    let endTime: Date?
    
    var isActive: Bool {
        let now = Date()
        return now >= startTime && (endTime == nil || now <= endTime!)
    }
}

// MARK: - Incident Types
enum IncidentType: String, Codable {
    case accident = "accident"
    case roadwork = "roadwork"
    case congestion = "congestion"
    case hazard = "hazard"
    case weather = "weather"
    case closure = "closure"
    
    var icon: String {
        switch self {
        case .accident: return "exclamationmark.triangle.fill"
        case .roadwork: return "hammer.fill"
        case .congestion: return "car.2.fill"
        case .hazard: return "exclamationmark.octagon.fill"
        case .weather: return "cloud.rain.fill"
        case .closure: return "xmark.octagon.fill"
        }
    }
}

// MARK: - Incident Severity
enum IncidentSeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - Navigation Service
@MainActor
class NavigationService: NSObject, ObservableObject {
    static let shared = NavigationService()
    
    // MARK: - Published Properties
    @Published var currentRoute: RouteResult?
    @Published var alternativeRoutes: [RouteResult] = []
    @Published var isNavigating = false
    @Published var currentStep: RouteStep?
    @Published var navigationError: NavigationError?
    @Published var routeOptions = RouteOptions.default
    
    // MARK: - Private Properties
    private let directions = MKDirections()
    private var currentRequest: MKDirections.Request?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Calculate routes between two points
    func calculateRoutes(
        from start: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        options: RouteOptions? = nil
    ) async {
        let options = options ?? routeOptions
        
        do {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = options.transportMode.mapKitTransportType
            
            // Apply route options
            if options.avoidTolls {
                request.requestsAlternateRoutes = true
            }
            
            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            
            // Convert to our RouteResult format
            let routes = response.routes.map { route in
                convertToRouteResult(route, transportMode: options.transportMode)
            }
            
            if let primaryRoute = routes.first {
                currentRoute = primaryRoute
                alternativeRoutes = Array(routes.dropFirst())
            }
            
        } catch {
            navigationError = .routeCalculationFailed(error.localizedDescription)
        }
    }
    
    /// Start navigation with the current route
    func startNavigation() {
        guard let route = currentRoute else { return }
        
        isNavigating = true
        currentStep = route.steps.first
        // TODO: Implement real-time navigation updates
    }
    
    /// Stop navigation
    func stopNavigation() {
        isNavigating = false
        currentStep = nil
    }
    
    /// Get gas stations along the route
    func getGasStationsAlongRoute() async -> [GasStation] {
        // TODO: Implement gas station API integration
        return []
    }
    
    /// Get toll information for the route
    func getTollInformation() async -> [TollInfo] {
        // TODO: Implement toll API integration
        return []
    }
    
    /// Get traffic incidents along the route
    func getTrafficIncidents() async -> [TrafficIncident] {
        // TODO: Implement traffic incident API integration
        return []
    }
    
    // MARK: - Private Methods
    
    private func convertToRouteResult(_ route: MKRoute, transportMode: TransportMode) -> RouteResult {
        let steps = route.steps.map { step in
            RouteStep(
                instructions: step.instructions,
                distance: step.distance,
                expectedTravelTime: 0, // MKRoute.Step doesn't have expectedTravelTime
                transportType: transportMode,
                maneuverType: convertManeuverType(step.transportType),
                coordinate: step.polyline.coordinate
            )
        }
        
        return RouteResult(
            transportMode: transportMode,
            distance: route.distance,
            expectedTravelTime: route.expectedTravelTime,
            polyline: route.polyline.coordinates,
            steps: steps,
            tolls: [], // TODO: Populate from API
            gasStations: [], // TODO: Populate from API
            trafficIncidents: [] // TODO: Populate from API
        )
    }
    
    private func convertManeuverType(_ transportType: MKDirectionsTransportType) -> ManeuverType {
        switch transportType {
        case .automobile:
            return .continueStraight
        case .walking:
            return .continueStraight
        case .transit:
            return .transit
        case .any:
            return .continueStraight
        default:
            return .continueStraight
        }
    }
}

// MARK: - Navigation Error
enum NavigationError: LocalizedError {
    case routeCalculationFailed(String)
    case noRoutesFound
    case locationUnavailable
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .routeCalculationFailed(let message):
            return "Route calculation failed: \(message)"
        case .noRoutesFound:
            return "No routes found for the selected destination"
        case .locationUnavailable:
            return "Location services are unavailable"
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}

// MARK: - Extensions
extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        let pointCount = pointCount
        let points = self.points()
        
        for i in 0..<pointCount {
            coords.append(points[i].coordinate)
        }
        
        return coords
    }
}
