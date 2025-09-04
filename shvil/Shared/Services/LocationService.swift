//
//  LocationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import MapKit

public class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var isLocationEnabled = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco default
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Check location services status asynchronously to avoid UI blocking
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let isEnabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                self?.isLocationEnabled = isEnabled
            }
        }
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func centerOnUserLocation() {
        guard let location = currentLocation else { return }
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.currentLocation = location

            // Update region to follow user
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: self.region.span
            )
        }
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.isLocationEnabled = (status == .authorizedWhenInUse || status == .authorizedAlways)

            if self.isLocationEnabled {
                self.startLocationUpdates()
            }
        }
    }
}
