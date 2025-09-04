//
//  NavigationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation
import MapKit
import Combine

class NavigationService: NSObject, ObservableObject {
    @Published var isNavigating = false
    @Published var currentRoute: MKRoute?
    @Published var currentStep: MKRoute.Step?
    @Published var remainingDistance: CLLocationDistance = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var routes: [MKRoute] = []
    @Published var selectedRouteIndex = 0
    
    private var directions: MKDirections?
    private var currentStepIndex = 0
    
    override init() {
        super.init()
    }
    
    func calculateRoute(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        directions = MKDirections(request: request)
        directions?.calculate { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Route calculation error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let response = response else {
                    completion(false)
                    return
                }
                
                self?.routes = response.routes
                self?.currentRoute = response.routes.first
                completion(true)
            }
        }
    }
    
    func selectRoute(at index: Int) {
        guard index < routes.count else { return }
        selectedRouteIndex = index
        currentRoute = routes[index]
    }
    
    func startNavigation() {
        guard let route = currentRoute else { return }
        isNavigating = true
        currentStepIndex = 0
        currentStep = route.steps.first
        updateRemainingDistance()
    }
    
    func stopNavigation() {
        isNavigating = false
        currentRoute = nil
        currentStep = nil
        currentStepIndex = 0
        remainingDistance = 0
        remainingTime = 0
    }
    
    func nextStep() {
        guard let route = currentRoute else { return }
        if currentStepIndex < route.steps.count - 1 {
            currentStepIndex += 1
            currentStep = route.steps[currentStepIndex]
        } else {
            // Navigation complete
            stopNavigation()
        }
        updateRemainingDistance()
    }
    
    private func updateRemainingDistance() {
        guard let route = currentRoute else { return }
        let remainingSteps = Array(route.steps.dropFirst(currentStepIndex))
        
        var totalDistance: CLLocationDistance = 0
        
        for step in remainingSteps {
            totalDistance += step.distance
        }
        
        remainingDistance = totalDistance
        remainingTime = route.expectedTravelTime // Use route's total time for now
    }
}