//
//  RoutingEngine.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import MapKit
import Combine

/// MKDirections wrapper for route calculation and management
@MainActor
class RoutingEngine: ObservableObject {
    // MARK: - Published Properties
    @Published var currentRoute: MKRoute?
    @Published var currentStepIndex = 0
    @Published var remainingDistance: CLLocationDistance = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var isNavigating = false
    @Published var transportType: MKDirectionsTransportType = .automobile
    @Published var routeOptions: [RouteOption] = []
    @Published var selectedRouteOption: RouteOption = .fastest
    
    // MARK: - Private Properties
    private var routeSteps: [MKRoute.Step] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func calculateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, transportType: MKDirectionsTransportType = .automobile) {
        self.transportType = transportType
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = transportType
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Route calculation error: \(error.localizedDescription)")
                    return
                }
                
                guard let response = response else { return }
                
                self?.processRouteResponse(response)
            }
        }
    }
    
    func startNavigation() {
        guard let route = currentRoute else { return }
        
        isNavigating = true
        routeSteps = route.steps
        currentStepIndex = 0
        updateRemainingDistance()
    }
    
    func stopNavigation() {
        isNavigating = false
        currentRoute = nil
        routeSteps = []
        currentStepIndex = 0
        remainingDistance = 0
        remainingTime = 0
    }
    
    func nextStep() {
        guard currentStepIndex < routeSteps.count - 1 else { return }
        currentStepIndex += 1
        updateRemainingDistance()
    }
    
    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        updateRemainingDistance()
    }
    
    func selectRouteOption(_ option: RouteOption) {
        selectedRouteOption = option
        // Recalculate route with selected option
        if let route = currentRoute {
            // This would trigger a new route calculation with the selected option
            // Implementation depends on how route options are structured
        }
    }
    
    // MARK: - Private Methods
    private func processRouteResponse(_ response: MKDirections.Response) {
        let routes = response.routes
        
        // Create route options
        routeOptions = routes.enumerated().map { index, route in
            RouteOption(
                id: index,
                name: routeName(for: route, at: index),
                distance: route.distance,
                expectedTravelTime: route.expectedTravelTime,
                isFastest: index == 0,
                isSafest: isSafestRoute(route),
                route: route
            )
        }
        
        // Select default route (fastest)
        if let firstRoute = routes.first {
            currentRoute = firstRoute
            selectedRouteOption = routeOptions.first ?? .fastest
        }
    }
    
    private func routeName(for route: MKRoute, at index: Int) -> String {
        if index == 0 {
            return "Fastest"
        } else if isSafestRoute(route) {
            return "Safest"
        } else {
            return "Route \(index + 1)"
        }
    }
    
    private func isSafestRoute(_ route: MKRoute) -> Bool {
        // Simple heuristic: route with fewer highway segments is safer
        let highwaySteps = route.steps.filter { $0.instructions.contains("highway") || $0.instructions.contains("freeway") }
        return highwaySteps.count < 3
    }
    
    private func updateRemainingDistance() {
        guard isNavigating, !routeSteps.isEmpty else { return }
        
        let remainingSteps = Array(routeSteps[currentStepIndex...])
        remainingDistance = remainingSteps.reduce(0) { $0 + $1.distance }
        // For now, estimate based on distance (MKRoute.Step doesn't have expectedTravelTime)
        remainingTime = remainingSteps.map { $0.distance / 1000 * 60 }.reduce(0, +) // rough estimate: 1km per minute
    }
}

// MARK: - Supporting Types
struct RouteOption: Identifiable, Equatable {
    let id: Int
    let name: String
    let distance: CLLocationDistance
    let expectedTravelTime: TimeInterval
    let isFastest: Bool
    let isSafest: Bool
    let route: MKRoute
    
    static let fastest = RouteOption(
        id: 0,
        name: "Fastest",
        distance: 0,
        expectedTravelTime: 0,
        isFastest: true,
        isSafest: false,
        route: MKRoute()
    )
    
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
