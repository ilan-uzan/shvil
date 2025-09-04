//
//  NavigationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import MapKit
import Combine

// MARK: - Simple Navigation Service
class NavigationService: NSObject, ObservableObject {
    @Published var isNavigating = false
    @Published var currentLocation: CLLocation?
    @Published var destination: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startNavigation(to destination: CLLocation) {
        self.destination = destination
        isNavigating = true
    }
    
    func stopNavigation() {
        isNavigating = false
        destination = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension NavigationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}