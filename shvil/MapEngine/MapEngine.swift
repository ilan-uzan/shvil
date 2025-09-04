//
//  MapEngine.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import MapKit
import Combine

/// MapKit wrapper for search, annotations, overlays, and camera management
@MainActor
public class MapEngine: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var searchResults: [SearchResult] = []
    @Published var annotations: [CustomMapAnnotation] = []
    @Published var overlays: [MKOverlay] = []
    @Published var isSearching = false
    @Published var selectedAnnotation: CustomMapAnnotation?
    
    // MARK: - Private Properties
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSearchCompleter()
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
    }
    
    // MARK: - Search Methods
    func searchPlaces(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        searchCompleter.queryFragment = query
    }
    
    /// Search for places using MapKit and return results directly
    public func searchPlaces(query: String, region: MKCoordinateRegion? = nil) async throws -> [SearchResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = region {
            request.region = region
        } else {
            request.region = MKCoordinateRegion(
                center: self.region.center,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
        }
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems.map { item in
            SearchResult(
                name: item.name ?? "Unknown",
                address: item.placemark.title ?? "",
                coordinate: item.placemark.coordinate
            )
        }
    }
    
    func performSearch(query: String, completion: @escaping ([SearchResult]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let response = response else {
                    completion([])
                    return
                }
                
                let results = response.mapItems.map { mapItem in
                    SearchResult(
                        name: mapItem.name ?? "Unknown",
                        address: mapItem.placemark.title ?? "",
                        coordinate: mapItem.placemark.coordinate,
                        mapItem: mapItem
                    )
                }
                self?.searchResults = results
                completion(results)
            }
        }
    }
    
    // MARK: - Annotation Methods
    func addAnnotation(_ annotation: CustomMapAnnotation) {
        annotations.append(annotation)
    }
    
    func removeAnnotation(_ annotation: CustomMapAnnotation) {
        annotations.removeAll { $0.id == annotation.id }
    }
    
    func clearAnnotations() {
        annotations.removeAll()
    }
    
    func selectAnnotation(_ annotation: CustomMapAnnotation) {
        selectedAnnotation = annotation
    }
    
    // MARK: - Overlay Methods
    func addOverlay(_ overlay: MKOverlay) {
        overlays.append(overlay)
    }
    
    func removeOverlay(_ overlay: MKOverlay) {
        overlays.removeAll { $0.isEqual(overlay) }
    }
    
    func clearOverlays() {
        overlays.removeAll()
    }
    
    // MARK: - Camera Methods
    func setRegion(_ newRegion: MKCoordinateRegion, animated: Bool = true) {
        region = newRegion
    }
    
    func centerOnLocation(_ location: CLLocation, span: MKCoordinateSpan? = nil) {
        let newSpan = span ?? MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let newRegion = MKCoordinateRegion(center: location.coordinate, span: newSpan)
        setRegion(newRegion)
    }
    
    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan? = nil) {
        let newSpan = span ?? MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let newRegion = MKCoordinateRegion(center: coordinate, span: newSpan)
        setRegion(newRegion)
    }
    
    func fitAnnotations(animated: Bool = true) {
        guard !annotations.isEmpty else { return }
        
        let coordinates = annotations.map { $0.coordinate }
        
        // Calculate bounding box
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, 0.01),
            longitudeDelta: max(maxLon - minLon, 0.01)
        )
        
        let region = MKCoordinateRegion(center: center, span: span)
        setRegion(region, animated: animated)
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension MapEngine: MKLocalSearchCompleterDelegate {
    public nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.map { completion in
            SearchResult(
                name: completion.title,
                address: completion.subtitle,
                coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), // Will be filled when selected
                mapItem: nil
            )
        }
        Task { @MainActor in
            searchResults = results
            isSearching = false
        }
    }
    
    public nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
        Task { @MainActor in
            isSearching = false
        }
    }
}

// MARK: - Supporting Types

struct CustomMapAnnotation: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let type: AnnotationType
    
    static func == (lhs: CustomMapAnnotation, rhs: CustomMapAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}

enum AnnotationType {
    case userLocation
    case searchResult
    case savedPlace
    case safetyReport(SafetyReportType)
    case friend
}

// SafetyReportType is defined in SafetyKit
