//
//  LocationManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import MapKit
import SwiftUI

/// Unified location management service
@MainActor
public class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published public var currentLocation: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isLocationEnabled = false
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Israel default
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published public var locationError: Error?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupLocationManager()
        checkLocationServicesStatus()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10 meters
    }
    
    private func checkLocationServicesStatus() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let isEnabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                self?.isLocationEnabled = isEnabled
            }
        }
    }
    
    // MARK: - Public Methods
    
    public func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Handle denied case - show settings alert
            break
        case .authorizedWhenInUse:
            startLocationUpdates()
        case .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    public func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    public func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    public func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    public func centerOnUserLocation() {
        guard let location = currentLocation else { 
            // If no location available, show demo region
            showDemoRegion()
            return
        }
        
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    public func showDemoRegion() {
        // Show a demo region when location is not available
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Israel
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    public func openLocationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: @preconcurrency CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        
        // Update region to follow user
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: region.span
        )
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        isLocationEnabled = (status == .authorizedWhenInUse || status == .authorizedAlways)
        
        if isLocationEnabled {
            startLocationUpdates()
        } else {
            stopLocationUpdates()
            // Show demo region when location is denied
            showDemoRegion()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        print("Location error: \(error.localizedDescription)")
    }
}

// MARK: - Supporting Types

public enum LocationPermission: String, CaseIterable {
    case notDetermined = "notDetermined"
    case denied = "denied"
    case whenInUse = "whenInUse"
    case always = "always"
    
    public var displayName: String {
        switch self {
        case .notDetermined: "Not Determined"
        case .denied: "Denied"
        case .whenInUse: "When In Use"
        case .always: "Always"
        }
    }
    
    public var icon: String {
        switch self {
        case .notDetermined: "questionmark.circle"
        case .denied: "xmark.circle"
        case .whenInUse: "checkmark.circle"
        case .always: "checkmark.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .notDetermined: .orange
        case .denied: .red
        case .whenInUse, .always: .green
        }
    }
}
