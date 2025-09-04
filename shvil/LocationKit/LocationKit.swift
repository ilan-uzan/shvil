//
//  LocationKit.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation

/// Location permission and accuracy management
@MainActor
class LocationKit: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var accuracyMode: LocationAccuracyMode = .balanced

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10 meters
    }

    // MARK: - Public Methods

    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Handle denied case - show settings alert
            break
        case .authorizedWhenInUse:
            // Request always authorization for background navigation
            requestAlwaysAuthorization()
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }

        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }

    func startBackgroundLocationUpdates() {
        guard authorizationStatus == .authorizedAlways else {
            return
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func stopBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
    }

    func setAccuracyMode(_ mode: LocationAccuracyMode) {
        accuracyMode = mode

        switch mode {
        case .high:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 1
        case .balanced:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10
        case .low:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 100
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationKit: @preconcurrency CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            stopLocationUpdates()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// MARK: - Supporting Types

enum LocationAccuracyMode: String, CaseIterable {
    case high
    case balanced
    case low

    var displayName: String {
        switch self {
        case .high: "High Accuracy"
        case .balanced: "Balanced"
        case .low: "Low Power"
        }
    }
}
