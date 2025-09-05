//
//  NavigationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import AVFoundation
import Combine
import CoreLocation
import Foundation
import MapKit

/// Main navigation service for turn-by-turn guidance
@MainActor
public class NavigationService: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published public var isNavigating = false
    @Published public var currentRoute: Route?
    @Published public var routes: [Route] = []
    @Published public var selectedRouteIndex = 0
    @Published public var currentStep: RouteStep?
    @Published public var remainingTime: TimeInterval = 0
    @Published public var remainingDistance: Double = 0
    @Published public var nextStep: RouteStep?
    @Published public var isRerouting = false
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var routeCalculationTask: Task<Void, Never>?
    private var rerouteTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Navigation state
    private var currentLocation: CLLocation?
    private var destination: CLLocationCoordinate2D?
    private var waypoints: [CLLocationCoordinate2D] = []
    private var currentStepIndex = 0
    private var isVoiceEnabled = true
    private var isHapticEnabled = true
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupLocationManager()
        setupSpeechSynthesizer()
    }
    
    // MARK: - Public Methods
    
    /// Calculate routes from origin to destination
    public func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D] = [],
        options: RouteOptions = RouteOptions(),
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        self.destination = destination
        self.waypoints = waypoints
        
        routeCalculationTask?.cancel()
        routeCalculationTask = Task {
            do {
                let calculatedRoutes = try await calculateRoutes(
                    from: origin,
                    to: destination,
                    waypoints: waypoints,
                    options: options
                )
                
                await MainActor.run {
                    self.routes = calculatedRoutes
                    self.selectedRouteIndex = 0
                    self.currentRoute = calculatedRoutes.first
                    completion(true)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    completion(false)
                }
            }
        }
    }
    
    /// Start navigation with the selected route
    public func startNavigation() {
        guard let route = currentRoute else { return }
        
        isNavigating = true
        currentStepIndex = 0
        updateCurrentStep()
        startRerouteTimer()
        
        // Provide haptic feedback
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .medium)
        }
        
        // Announce start of navigation
        announceInstruction("Starting navigation to \(route.name)")
    }
    
    /// Stop navigation
    public func stopNavigation() {
        isNavigating = false
        currentRoute = nil
        currentStep = nil
        nextStep = nil
        remainingTime = 0
        remainingDistance = 0
        stopRerouteTimer()
        
        // Provide haptic feedback
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .light)
        }
    }
    
    /// Select a different route
    public func selectRoute(at index: Int) {
        guard index < routes.count else { return }
        
        selectedRouteIndex = index
        currentRoute = routes[index]
        
        if isNavigating {
            // Restart navigation with new route
            startNavigation()
        }
    }
    
    /// Add a waypoint to the current route
    public func addWaypoint(_ coordinate: CLLocationCoordinate2D) {
        guard let currentRoute = currentRoute else { return }
        
        waypoints.append(coordinate)
        
        // Recalculate route with new waypoint
        calculateRoute(
            from: currentLocation?.coordinate ?? CLLocationCoordinate2D(),
            to: destination ?? CLLocationCoordinate2D(),
            waypoints: waypoints,
            options: currentRoute.options
        ) { success in
            if success {
                self.startNavigation()
            }
        }
    }
    
    /// Toggle voice guidance
    public func toggleVoiceGuidance() {
        isVoiceEnabled.toggle()
        
        if isVoiceEnabled {
            announceInstruction("Voice guidance enabled")
        } else {
            announceInstruction("Voice guidance disabled")
        }
    }
    
    /// Toggle haptic feedback
    public func toggleHapticFeedback() {
        isHapticEnabled.toggle()
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    private func setupSpeechSynthesizer() {
        speechSynthesizer.delegate = self
    }
    
    private func calculateRoutes(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D],
        options: RouteOptions
    ) async throws -> [Route] {
        // Create MKMapKit request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        // Add waypoints
        if !waypoints.isEmpty {
            request.transportType = mapKitTransportType(for: options.transportationMode)
        }
        
        // Configure request based on options
        configureRequest(request, with: options)
        
        // Calculate directions
        let directions = MKDirections(request: request)
        
        return try await withCheckedThrowingContinuation { continuation in
            directions.calculate { response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let response = response else {
                    continuation.resume(throwing: NavigationError.noRoutesFound)
                    return
                }
                
                let routes = response.routes.map { mkRoute in
                    self.convertMKRouteToRoute(mkRoute, options: options)
                }
                
                continuation.resume(returning: routes)
            }
        }
    }
    
    private func mapKitTransportType(for mode: TransportationMode) -> MKDirectionsTransportType {
        switch mode {
        case .driving: return .automobile
        case .walking: return .walking
        case .cycling: return .walking // MapKit doesn't have cycling, use walking
        case .publicTransport: return .transit
        case .mixed: return .automobile
        }
    }
    
    private func configureRequest(_ request: MKDirections.Request, with options: RouteOptions) {
        // MapKit doesn't support all our options, so we'll use what's available
        // In a real implementation, you'd use a more advanced routing service
        // like Google Maps API or Mapbox for full feature support
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
            isFastest: true, // MapKit doesn't provide multiple route options easily
            isSafest: false
        )
    }
    
    private func convertMKStepToRouteStep(_ mkStep: MKRoute.Step) -> RouteStep {
        let maneuverType = determineManeuverType(from: mkStep.instructions)
        
        return RouteStep(
            instruction: mkStep.instructions,
            distance: mkStep.distance,
            expectedTravelTime: mkStep.distance / 1000 * 60, // rough estimate: 1km per minute
            polyline: mkStep.polyline.coordinates,
            maneuverType: maneuverType,
            roadName: mkStep.instructions
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
    
    private func updateCurrentStep() {
        guard let route = currentRoute,
              currentStepIndex < route.steps.count else { return }
        
        currentStep = route.steps[currentStepIndex]
        nextStep = currentStepIndex + 1 < route.steps.count ? route.steps[currentStepIndex + 1] : nil
        
        // Update remaining time and distance
        let remainingSteps = Array(route.steps.suffix(from: currentStepIndex))
        remainingTime = remainingSteps.reduce(0) { $0 + $1.expectedTravelTime }
        remainingDistance = remainingSteps.reduce(0) { $0 + $1.distance }
    }
    
    private func announceInstruction(_ instruction: String) {
        guard isVoiceEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 0.8
        
        speechSynthesizer.speak(utterance)
    }
    
    private func startRerouteTimer() {
        stopRerouteTimer()
        rerouteTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkForReroute()
            }
        }
    }
    
    private func stopRerouteTimer() {
        rerouteTimer?.invalidate()
        rerouteTimer = nil
    }
    
    private func checkForReroute() {
        guard isNavigating,
              let currentLocation = currentLocation,
              let route = currentRoute else { return }
        
        // Check if user has deviated from route
        let deviation = calculateRouteDeviation(from: currentLocation, to: route)
        
        if deviation > 50 { // 50 meters deviation threshold
            triggerReroute()
        }
    }
    
    private func calculateRouteDeviation(from location: CLLocation, to route: Route) -> Double {
        // Find the closest point on the route polyline
        var minDistance = Double.greatestFiniteMagnitude
        
        for coordinate in route.polyline {
            let routeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = location.distance(from: routeLocation)
            minDistance = min(minDistance, distance)
        }
        
        return minDistance
    }
    
    private func triggerReroute() {
        guard let destination = destination else { return }
        
        isRerouting = true
        
        calculateRoute(
            from: currentLocation?.coordinate ?? CLLocationCoordinate2D(),
            to: destination,
            waypoints: waypoints,
            options: currentRoute?.options ?? RouteOptions()
        ) { [weak self] success in
            self?.isRerouting = false
            if success {
                self?.startNavigation()
                self?.announceInstruction("Route recalculated")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension NavigationService: @preconcurrency CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            currentLocation = location
            
            if isNavigating {
                // Check if we've completed the current step
                checkStepCompletion()
            }
        }
    }
    
    private func checkStepCompletion() {
        guard let currentStep = currentStep,
              let currentLocation = currentLocation else { return }
        
        // Check if we're close to the end of the current step
        let stepEnd = currentStep.polyline.last
        if let stepEnd = stepEnd {
            let stepEndLocation = CLLocation(latitude: stepEnd.latitude, longitude: stepEnd.longitude)
            let distance = currentLocation.distance(from: stepEndLocation)
            
            if distance < 20 { // 20 meters threshold
                moveToNextStep()
            }
        }
    }
    
    private func moveToNextStep() {
        guard let route = currentRoute else { return }
        
        currentStepIndex += 1
        
        if currentStepIndex >= route.steps.count {
            // Navigation completed
            announceInstruction("You have arrived at your destination")
            stopNavigation()
        } else {
            updateCurrentStep()
            
            // Announce next instruction
            if let nextInstruction = currentStep?.instruction {
                announceInstruction(nextInstruction)
            }
            
            // Provide haptic feedback
            if isHapticEnabled {
                HapticFeedback.shared.impact(style: .light)
            }
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension NavigationService: @preconcurrency AVSpeechSynthesizerDelegate {
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Handle speech completion if needed
    }
}

// MARK: - Navigation Errors

public enum NavigationError: LocalizedError {
    case noRoutesFound
    case locationNotAvailable
    case routeCalculationFailed
    case invalidCoordinates
    
    public var errorDescription: String? {
        switch self {
        case .noRoutesFound:
            "No routes found to destination"
        case .locationNotAvailable:
            "Current location not available"
        case .routeCalculationFailed:
            "Failed to calculate route"
        case .invalidCoordinates:
            "Invalid coordinates provided"
        }
    }
}

