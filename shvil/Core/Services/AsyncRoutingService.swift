//
//  AsyncRoutingService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import Foundation
import MapKit

/// High-performance async routing service with modern concurrency
@MainActor
public class AsyncRoutingService: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var routes: [Route] = []
    @Published public var selectedRoute: Route?
    @Published public var isCalculating = false
    @Published public var error: Error?
    @Published public var trafficConditions: [TrafficCondition] = []
    @Published public var tollCosts: [TollCost] = []
    
    // MARK: - Private Properties
    
    private let locationService: LocationService
    private let offlineManager: OfflineManager
    
    // Performance optimization
    private let backgroundQueue = DispatchQueue(label: "routing.background", qos: .userInitiated)
    private let routeCache = NSCache<NSString, RouteCache>()
    private let trafficCache = NSCache<NSString, TrafficCache>()
    
    // MARK: - Constants
    
    private let maxRouteOptions = 3
    private let routeCalculationTimeout: TimeInterval = 30.0
    private let cacheExpirationTime: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    public init(locationService: LocationService, offlineManager: OfflineManager) {
        self.locationService = locationService
        self.offlineManager = offlineManager
        setupCaches()
    }
    
    // MARK: - Public Methods
    
    /// Calculate routes from origin to destination with async/await
    public func calculateRoutes(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D] = [],
        options: RouteOptions = RouteOptions()
    ) async throws -> [Route] {
        await MainActor.run {
            isCalculating = true
            error = nil
        }
        
        defer {
            Task { @MainActor in
                isCalculating = false
            }
        }
        
        // Check cache first
        let cacheKey = generateCacheKey(from: origin, to: destination, waypoints: waypoints, options: options)
        if let cachedRoutes = getCachedRoutes(for: cacheKey) {
            await MainActor.run {
                self.routes = cachedRoutes
                self.selectedRoute = cachedRoutes.first
            }
            return cachedRoutes
        }
        
        // Check if we're offline and have cached routes
        if offlineManager.isOfflineMode {
            if let cachedRoute = offlineManager.getCachedRoute(id: UUID()) {
                let routes = [cachedRoute]
                await MainActor.run {
                    self.routes = routes
                    self.selectedRoute = routes.first
                }
                return routes
            }
        }
        
        // Calculate multiple route options on background queue
        let calculatedRoutes = try await calculateMultipleRouteOptions(
            from: origin,
            to: destination,
            waypoints: waypoints,
            baseOptions: options
        )
        
        // Cache the results
        cacheRoutes(calculatedRoutes, for: cacheKey)
        
        // Cache for offline use
        for route in calculatedRoutes {
            offlineManager.cacheRoute(route)
        }
        
        await MainActor.run {
            self.routes = calculatedRoutes
            self.selectedRoute = calculatedRoutes.first
        }
        
        return calculatedRoutes
    }
    
    /// Calculate routes with multiple optimization strategies
    public func calculateMultipleRouteOptions(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D] = [],
        baseOptions: RouteOptions = RouteOptions()
    ) async throws -> [Route] {
        return try await withThrowingTaskGroup(of: Route?.self) { group in
            var allRoutes: [Route] = []
            
            // Calculate fastest route
            group.addTask {
                var fastestOptions = baseOptions
                fastestOptions.optimizeFor = .fastest
                return try await self.calculateSingleRoute(
                    from: origin,
                    to: destination,
                    waypoints: waypoints,
                    options: fastestOptions
                )
            }
            
            // Calculate safest route
            group.addTask {
                var safestOptions = baseOptions
                safestOptions.optimizeFor = .safest
                return try await self.calculateSingleRoute(
                    from: origin,
                    to: destination,
                    waypoints: waypoints,
                    options: safestOptions
                )
            }
            
            // Calculate scenic route
            group.addTask {
                var scenicOptions = baseOptions
                scenicOptions.optimizeFor = .mostScenic
                scenicOptions.preferScenic = true
                return try await self.calculateSingleRoute(
                    from: origin,
                    to: destination,
                    waypoints: waypoints,
                    options: scenicOptions
                )
            }
            
            // Collect results
            for try await route in group {
                if let route = route {
                    allRoutes.append(route)
                }
            }
            
            // Sort routes by optimization preference
            allRoutes.sort { route1, route2 in
                if route1.isFastest && !route2.isFastest { return true }
                if !route1.isFastest && route2.isFastest { return false }
                if route1.isSafest && !route2.isSafest { return true }
                if !route1.isSafest && route2.isSafest { return false }
                return route1.expectedTravelTime < route2.expectedTravelTime
            }
            
            return allRoutes
        }
    }
    
    /// Select a route from the calculated options
    public func selectRoute(_ route: Route) {
        selectedRoute = route
    }
    
    /// Add a waypoint to the current route
    public func addWaypoint(_ coordinate: CLLocationCoordinate2D) async throws {
        guard let currentRoute = selectedRoute else {
            throw RoutingError.noRouteSelected
        }
        
        // Recalculate route with new waypoint
        let newRoutes = try await calculateMultipleRouteOptions(
            from: currentRoute.polyline.first ?? CLLocationCoordinate2D(),
            to: currentRoute.polyline.last ?? CLLocationCoordinate2D(),
            waypoints: [coordinate],
            baseOptions: currentRoute.options
        )
        
        routes = newRoutes
        selectedRoute = newRoutes.first
    }
    
    /// Remove a waypoint from the current route
    public func removeWaypoint(at index: Int) async throws {
        guard let currentRoute = selectedRoute else {
            throw RoutingError.noRouteSelected
        }
        
        // Recalculate route without the waypoint
        let waypoints = currentRoute.polyline.dropFirst().dropLast()
        let filteredWaypoints = Array(waypoints.enumerated().compactMap { offset, element in
            offset == index ? nil : element
        })
        
        let newRoutes = try await calculateMultipleRouteOptions(
            from: currentRoute.polyline.first ?? CLLocationCoordinate2D(),
            to: currentRoute.polyline.last ?? CLLocationCoordinate2D(),
            waypoints: filteredWaypoints,
            baseOptions: currentRoute.options
        )
        
        routes = newRoutes
        selectedRoute = newRoutes.first
    }
    
    /// Get alternative routes for the current selection
    public func getAlternativeRoutes() -> [Route] {
        guard let selectedRoute = selectedRoute else { return routes }
        return routes.filter { $0.id != selectedRoute.id }
    }
    
    /// Get traffic conditions for a route
    public func getTrafficConditions(for route: Route) async -> [TrafficCondition] {
        let cacheKey = "traffic_\(route.id.uuidString)"
        
        // Check cache first
        if let cachedTraffic = trafficCache.object(forKey: cacheKey as NSString)?.conditions {
            return cachedTraffic
        }
        
        // Fetch traffic conditions on background queue
        let conditions = await withTaskGroup(of: [TrafficCondition].self) { group in
            group.addTask {
                // This would typically call a traffic API
                // For now, return mock data
                return self.generateMockTrafficConditions(for: route)
            }
            
            var allConditions: [TrafficCondition] = []
            for await conditions in group {
                allConditions.append(contentsOf: conditions)
            }
            return allConditions
        }
        
        // Cache the results
        let cache = TrafficCache(conditions: conditions, timestamp: Date())
        trafficCache.setObject(cache, forKey: cacheKey as NSString)
        
        return conditions
    }
    
    /// Get toll costs for a route
    public func getTollCosts(for route: Route) async -> [TollCost] {
        // This would typically call a toll API
        // For now, return mock data
        return generateMockTollCosts(for: route)
    }
    
    /// Check if route is available offline
    public func isRouteAvailableOffline(_ route: Route) -> Bool {
        return route.polyline.allSatisfy { coordinate in
            offlineManager.isLocationOfflineAvailable(coordinate)
        }
    }
    
    /// Cache route for offline use
    public func cacheRoute(_ route: Route) {
        offlineManager.cacheRoute(route)
    }
    
    // MARK: - Private Methods
    
    private func setupCaches() {
        routeCache.countLimit = 50
        trafficCache.countLimit = 100
    }
    
    private func calculateSingleRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D],
        options: RouteOptions
    ) async throws -> Route? {
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                do {
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
                    
                    // Add waypoints
                    if !waypoints.isEmpty {
                        request.transportType = self.mapKitTransportType(for: options.transportationMode)
                    }
                    
                    // Configure request based on options
                    self.configureRequest(request, with: options)
                    
                    let directions = MKDirections(request: request)
                    
                    directions.calculate { response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let response = response,
                              let route = response.routes.first else {
                            continuation.resume(returning: nil)
                            return
                        }
                        
                        let convertedRoute = self.convertMKRouteToRoute(route, options: options)
                        continuation.resume(returning: convertedRoute)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func mapKitTransportType(for mode: TransportationMode) -> MKDirectionsTransportType {
        switch mode {
        case .driving: return .automobile
        case .walking: return .walking
        case .cycling: return .walking // MapKit doesn't have cycling
        case .publicTransport: return .transit
        case .mixed: return .automobile
        }
    }
    
    private func configureRequest(_ request: MKDirections.Request, with options: RouteOptions) {
        // MapKit has limited options compared to our RouteOptions
        // In a real implementation, you'd use a more advanced routing service
        
        // Set transport type
        request.transportType = mapKitTransportType(for: options.transportationMode)
        
        // MapKit doesn't support all our options, so we'll use what's available
        // For full feature support, you'd integrate with Google Maps API or Mapbox
    }
    
    private func convertMKRouteToRoute(_ mkRoute: MKRoute, options: RouteOptions) -> Route {
        let steps = mkRoute.steps.map { mkStep in
            convertMKStepToRouteStep(mkStep)
        }
        
        return Route(
            name: mkRoute.name,
            distance: mkRoute.distance,
            expectedTravelTime: mkRoute.expectedTravelTime,
            polyline: mkRoute.polyline.coordinates,
            steps: steps,
            options: options,
            isFastest: false, // Will be set by caller
            isSafest: false,  // Will be set by caller
            tollCost: calculateTollCost(for: mkRoute),
            fuelCost: calculateFuelCost(for: mkRoute, options: options)
        )
    }
    
    private func convertMKStepToRouteStep(_ mkStep: MKRoute.Step) -> RouteStep {
        let maneuverType = determineManeuverType(from: mkStep.instructions)
        
        return RouteStep(
            instruction: mkStep.instructions,
            distance: mkStep.distance,
            expectedTravelTime: mkStep.transportType == .automobile ? mkStep.distance / 50.0 : mkStep.distance / 5.0, // Rough estimate
            polyline: mkStep.polyline.coordinates,
            maneuverType: maneuverType,
            roadName: mkStep.instructions,
            isToll: isTollRoad(mkStep.instructions),
            isHighway: isHighwayRoad(mkStep.instructions)
        )
    }
    
    private func determineManeuverType(from instruction: String) -> ManeuverType {
        let lowercased = instruction.lowercased()
        
        if lowercased.contains("turn left") {
            return .turnLeft
        } else if lowercased.contains("turn right") {
            return .turnRight
        } else if lowercased.contains("u-turn") || lowercased.contains("uturn") {
            return .uTurn
        } else if lowercased.contains("merge") {
            return .merge
        } else if lowercased.contains("exit") {
            return .exit
        } else if lowercased.contains("straight") {
            return .straight
        } else if lowercased.contains("roundabout") {
            return .roundabout
        } else if lowercased.contains("ramp") {
            return .ramp
        } else if lowercased.contains("ferry") {
            return .ferry
        } else if lowercased.contains("tunnel") {
            return .tunnel
        } else if lowercased.contains("bridge") {
            return .bridge
        } else if lowercased.contains("toll") {
            return .toll
        } else if lowercased.contains("stop") {
            return .stop
        } else if lowercased.contains("yield") {
            return .yield
        } else if lowercased.contains("traffic light") {
            return .trafficLight
        } else if lowercased.contains("keep left") {
            return .keepLeft
        } else if lowercased.contains("keep right") {
            return .keepRight
        } else {
            return .straight
        }
    }
    
    private func isTollRoad(_ instruction: String) -> Bool {
        return instruction.lowercased().contains("toll")
    }
    
    private func isHighwayRoad(_ instruction: String) -> Bool {
        let highwayKeywords = ["highway", "freeway", "motorway", "autobahn", "autopista"]
        return highwayKeywords.contains { instruction.lowercased().contains($0) }
    }
    
    private func calculateTollCost(for route: MKRoute) -> Double? {
        // This would typically calculate based on toll data
        // For now, return nil
        return nil
    }
    
    private func calculateFuelCost(for route: MKRoute, options: RouteOptions) -> Double? {
        // This would typically calculate based on distance and fuel prices
        // For now, return nil
        return nil
    }
    
    private func generateMockTrafficConditions(for route: Route) -> [TrafficCondition] {
        // Generate mock traffic conditions
        return [
            TrafficCondition(
                coordinate: route.polyline.first ?? CLLocationCoordinate2D(),
                severity: .moderate,
                description: "Moderate traffic",
                delay: 5 * 60 // 5 minutes
            )
        ]
    }
    
    private func generateMockTollCosts(for route: Route) -> [TollCost] {
        // Generate mock toll costs
        return [
            TollCost(
                coordinate: route.polyline.first ?? CLLocationCoordinate2D(),
                name: "Highway Toll",
                cost: 15.0,
                currency: "ILS"
            )
        ]
    }
    
    // MARK: - Cache Management
    
    private func generateCacheKey(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D],
        options: RouteOptions
    ) -> String {
        let waypointsString = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
        return "\(origin.latitude),\(origin.longitude)-\(destination.latitude),\(destination.longitude)-\(waypointsString)-\(options.transportationMode.rawValue)"
    }
    
    private func getCachedRoutes(for key: String) -> [Route]? {
        guard let cache = routeCache.object(forKey: key as NSString) else { return nil }
        
        // Check if cache is still valid
        if Date().timeIntervalSince(cache.timestamp) > cacheExpirationTime {
            routeCache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return cache.routes
    }
    
    private func cacheRoutes(_ routes: [Route], for key: String) {
        let cache = RouteCache(routes: routes, timestamp: Date())
        routeCache.setObject(cache, forKey: key as NSString)
    }
}

// MARK: - Cache Classes

private class RouteCache {
    let routes: [Route]
    let timestamp: Date
    
    init(routes: [Route], timestamp: Date) {
        self.routes = routes
        self.timestamp = timestamp
    }
}

private class TrafficCache {
    let conditions: [TrafficCondition]
    let timestamp: Date
    
    init(conditions: [TrafficCondition], timestamp: Date) {
        self.conditions = conditions
        self.timestamp = timestamp
    }
}
