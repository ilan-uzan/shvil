//
//  SearchService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class SearchService: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    @Published var searchText = ""
    @Published var recentSearches: [SearchResult] = []
    
    private let geocoder = CLGeocoder()
    
    init() {
        loadRecentSearches()
    }
    
    func search(for query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        searchText = query
        
        // Use MKLocalSearch for better results
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    return
                }
                
                guard let response = response else { return }
                
                self?.searchResults = response.mapItems.compactMap { item in
                    SearchResult(
                        name: item.name ?? "Unknown",
                        address: item.placemark.title ?? "",
                        coordinate: item.placemark.coordinate,
                        mapItem: item
                    )
                }
            }
        }
    }
    
    func addToRecentSearches(_ result: SearchResult) {
        recentSearches.removeAll { $0.id == result.id }
        recentSearches.insert(result, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        // Load from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "recentSearches"),
           let searches = try? JSONDecoder().decode([SearchResult].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: "recentSearches")
        }
    }
}

public struct SearchResult: Identifiable, Codable {
    public let id = UUID()
    public let name: String
    public let address: String
    public let coordinate: CLLocationCoordinate2D
    public let mapItem: MKMapItem?
    
    public init(name: String, address: String, coordinate: CLLocationCoordinate2D, mapItem: MKMapItem? = nil) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.mapItem = mapItem
    }
    
    // Custom Codable implementation for CLLocationCoordinate2D
    private enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapItem = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}