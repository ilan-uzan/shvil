//
//  LocationServiceProtocol.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import Foundation
import MapKit

/// Protocol for location services to ensure compatibility
@MainActor
public protocol LocationServiceProtocol: ObservableObject {
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var isLocationEnabled: Bool { get }
    var region: MKCoordinateRegion { get set }
    var locationError: Error? { get }
    
    func requestLocationPermission()
    func startLocationUpdates()
    func stopLocationUpdates()
    func centerOnUserLocation()
    func showDemoRegion()
    func openLocationSettings()
}

// MARK: - LocationManager Conformance

extension LocationManager: LocationServiceProtocol {
    // LocationManager already conforms to the protocol with all required properties and methods
}
