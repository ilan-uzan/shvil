//
//  UnifiedLocationManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import SwiftUI
import Combine
import MapKit

/// Unified location management service
@MainActor
public class UnifiedLocationManager: NSObject, ObservableObject, LocationServiceProtocol {
    public static let shared = UnifiedLocationManager()
    
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var currentLocation: CLLocation?
    @Published public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Israel default
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published public var isLocationEnabled: Bool = false
    @Published public var locationError: Error?
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        authorizationStatus = locationManager.authorizationStatus
        updateLocationEnabled()
    }
    
    public func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            openLocationSettings()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
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
            requestLocationPermission()
            return
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    public func showDemoRegion() {
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
    
    public func openLocationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func updateLocationEnabled() {
        isLocationEnabled = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
}

// MARK: - CLLocationManagerDelegate

extension UnifiedLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = location
            self?.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = status
            self?.updateLocationEnabled()
            
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self?.startLocationUpdates()
            } else {
                self?.stopLocationUpdates()
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
