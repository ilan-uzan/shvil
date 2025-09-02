//
//  SearchService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import MapKit
import Combine

@MainActor
class SearchService: NSObject, ObservableObject {
    static let shared = SearchService()
    
    // MARK: - Published Properties
    @Published var searchResults: [MKMapItem] = []
    @Published var recentSearches: [SearchResult] = []
    @Published var isSearching = false
    @Published var searchError: SearchError?
    
    // MARK: - Private Properties
    private let searchCompleter = MKLocalSearchCompleter()
    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSearchCompleter()
        loadRecentSearches()
    }
    
    // MARK: - Public Methods
    
    /// Search for places with the given query
    func search(query: String, region: MKCoordinateRegion? = nil) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        searchError = nil
        
        do {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            if let region = region {
                request.region = region
            }
            
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            searchResults = response.mapItems
            
            // Save to recent searches
            await saveToRecentSearches(query: query, results: response.mapItems)
            
        } catch {
            searchError = .searchFailed(error.localizedDescription)
        }
        
        isSearching = false
    }
    
    /// Get search suggestions as user types
    func getSearchSuggestions(for query: String, region: MKCoordinateRegion? = nil) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchCompleter.queryFragment = ""
            return
        }
        
        if let region = region {
            searchCompleter.region = region
        }
        
        searchCompleter.queryFragment = query
    }
    
    /// Clear search results
    func clearSearch() {
        searchResults = []
        searchError = nil
    }
    
    /// Clear recent searches
    func clearRecentSearches() {
        recentSearches = []
        userDefaults.removeObject(forKey: recentSearchesKey)
    }
    
    /// Remove a specific recent search
    func removeRecentSearch(_ search: SearchResult) {
        recentSearches.removeAll { $0.id == search.id }
        saveRecentSearches()
    }
    
    // MARK: - Private Methods
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        searchCompleter.pointOfInterestFilter = .includingAll
    }
    
    private func saveToRecentSearches(query: String, results: [MKMapItem]) async {
        guard let firstResult = results.first else { return }
        
        let searchResult = SearchResult(
            query: query,
            title: firstResult.name ?? "Unknown",
            subtitle: firstResult.placemark.title ?? "",
            coordinate: firstResult.placemark.coordinate,
            mapItem: firstResult
        )
        
        // Remove if already exists
        recentSearches.removeAll { $0.query.lowercased() == query.lowercased() }
        
        // Add to beginning
        recentSearches.insert(searchResult, at: 0)
        
        // Limit to max count
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        do {
            let data = try JSONEncoder().encode(recentSearches)
            userDefaults.set(data, forKey: recentSearchesKey)
        } catch {
            print("Failed to save recent searches: \(error)")
        }
    }
    
    private func loadRecentSearches() {
        guard let data = userDefaults.data(forKey: recentSearchesKey) else { return }
        
        do {
            recentSearches = try JSONDecoder().decode([SearchResult].self, from: data)
        } catch {
            print("Failed to load recent searches: \(error)")
            recentSearches = []
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension SearchService: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Handle search suggestions if needed
        // For now, we'll focus on the main search functionality
    }
    
    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            searchError = .searchFailed(error.localizedDescription)
        }
    }
}

// MARK: - Search Models
struct SearchResult: Identifiable, Codable {
    let id: UUID
    let query: String
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    
    // Store map item data for reconstruction
    private let mapItemData: Data?
    
    init(query: String, title: String, subtitle: String, coordinate: CLLocationCoordinate2D, mapItem: MKMapItem) {
        self.id = UUID()
        self.query = query
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.timestamp = Date()
        
        // Store essential map item data
        self.mapItemData = try? NSKeyedArchiver.archivedData(withRootObject: mapItem, requiringSecureCoding: true)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, query, title, subtitle, coordinate, timestamp, mapItemData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        query = try container.decode(String.self, forKey: .query)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        mapItemData = try container.decodeIfPresent(Data.self, forKey: .mapItemData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(query, forKey: .query)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(mapItemData, forKey: .mapItemData)
    }
}

// MARK: - Search Error
enum SearchError: LocalizedError {
    case searchFailed(String)
    case noResults
    case networkError
    case locationRequired
    
    var errorDescription: String? {
        switch self {
        case .searchFailed(let message):
            return "Search failed: \(message)"
        case .noResults:
            return "No results found for your search"
        case .networkError:
            return "Network error. Please check your connection."
        case .locationRequired:
            return "Location access required for better search results"
        }
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
