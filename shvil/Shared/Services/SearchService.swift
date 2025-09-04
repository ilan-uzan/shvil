//
//  SearchService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine
import CoreLocation

class SearchService: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    @Published var searchError: String?
    
    func searchPlaces(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        searchError = nil
        
        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.searchResults = self.generateMockResults(for: query)
            self.isSearching = false
        }
    }
    
    private func generateMockResults(for query: String) -> [SearchResult] {
        return [
            SearchResult(name: "\(query) Location 1", address: "123 Main St", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
            SearchResult(name: "\(query) Location 2", address: "456 Oak Ave", coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094)),
            SearchResult(name: "\(query) Location 3", address: "789 Pine St", coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294))
        ]
    }
}

// MARK: - Search Result Model
struct SearchResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}