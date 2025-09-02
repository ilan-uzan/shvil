//
//  LocationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isLocationEnabled = false
    @Published var locationError: LocationError?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        
        authorizationStatus = locationManager.authorizationStatus
        isLocationEnabled = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    // MARK: - Public Methods
    
    /// Request location permission
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = .permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationError = .unknown
        }
    }
    
    /// Start location updates
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = .permissionDenied
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
        locationError = nil
    }
    
    /// Stop location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    /// Calculate distance between two coordinates
    func distance(from coordinate1: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        return location1.distance(from: location2)
    }
    
    /// Format distance for display
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filter out old or inaccurate locations
        let age = location.timestamp.timeIntervalSinceNow
        if abs(age) > 30 || location.horizontalAccuracy > 100 {
            return
        }
        
        Task { @MainActor in
            currentLocation = location
            locationError = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorToSet: LocationError
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorToSet = .permissionDenied
            case .locationUnknown:
                errorToSet = .locationUnknown
            case .network:
                errorToSet = .networkError
            default:
                errorToSet = .unknown
            }
        } else {
            errorToSet = .unknown
        }
        
        Task { @MainActor in
            locationError = errorToSet
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                isLocationEnabled = true
                startLocationUpdates()
            case .denied, .restricted:
                isLocationEnabled = false
                locationError = .permissionDenied
            case .notDetermined:
                isLocationEnabled = false
            @unknown default:
                isLocationEnabled = false
                locationError = .unknown
            }
        }
    }
}

// MARK: - Location Error
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnknown
    case networkError
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable location access in Settings."
        case .locationUnknown:
            return "Unable to determine your location. Please try again."
        case .networkError:
            return "Network error while getting location. Please check your connection."
        case .timeout:
            return "Location request timed out. Please try again."
        case .unknown:
            return "An unknown error occurred while getting your location."
        }
    }
}
