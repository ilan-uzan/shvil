//
//  SearchService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import MapKit

class SearchService: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    @Published var searchText = ""
    @Published var recentSearches: [SearchResult] = []
    @Published var autocompleteSuggestions: [SearchSuggestion] = []
    @Published var isShowingSuggestions = false
    @Published var error: Error?
    
    private let geocoder = CLGeocoder()
    private var searchTask: Task<Void, Never>?
    private var autocompleteTask: Task<Void, Never>?
    private let debounceDelay: TimeInterval = 0.3
    private var cancellables = Set<AnyCancellable>()
    
    // Search categories and filters
    @Published var selectedCategory: SearchCategory = .all
    @Published var searchFilters: SearchFilters = SearchFilters()
    
    init() {
        loadRecentSearches()
        setupSearchTextObserver()
    }
    
    func search(for query: String) {
        guard !query.isEmpty else {
            searchResults = []
            autocompleteSuggestions = []
            isShowingSuggestions = false
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        searchTask = Task {
            await performSearch(query: query)
        }
    }
    
    func getAutocompleteSuggestions(for query: String) {
        guard !query.isEmpty else {
            autocompleteSuggestions = []
            isShowingSuggestions = false
            return
        }
        
        // Cancel previous autocomplete
        autocompleteTask?.cancel()
        
        autocompleteTask = Task {
            await performAutocomplete(query: query)
        }
    }
    
    func selectSuggestion(_ suggestion: SearchSuggestion) {
        searchText = suggestion.text
        isShowingSuggestions = false
        
        // Perform search with selected suggestion
        search(for: suggestion.text)
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        autocompleteSuggestions = []
        isShowingSuggestions = false
        searchTask?.cancel()
        autocompleteTask?.cancel()
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
    
    func setCategory(_ category: SearchCategory) {
        selectedCategory = category
        if !searchText.isEmpty {
            search(for: searchText)
        }
    }
    
    func updateFilters(_ filters: SearchFilters) {
        searchFilters = filters
        if !searchText.isEmpty {
            search(for: searchText)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSearchTextObserver() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.getAutocompleteSuggestions(for: query)
                } else {
                    self?.autocompleteSuggestions = []
                    self?.isShowingSuggestions = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        await MainActor.run {
            isSearching = true
            error = nil
        }
        
        do {
            // First try local search
            let localResults = await performLocalSearch(query: query)
            
            // Then try geocoding for addresses
            let geocodedResults = await performGeocodingSearch(query: query)
            
            // Combine and deduplicate results
            let allResults = (localResults + geocodedResults).removingDuplicates()
            
            // Apply filters
            let filteredResults = applyFilters(to: allResults)
            
            await MainActor.run {
                self.searchResults = filteredResults
                self.isSearching = false
                self.isShowingSuggestions = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isSearching = false
            }
        }
    }
    
    private func performAutocomplete(query: String) async {
        // Get suggestions from multiple sources
        let localSuggestions = await getLocalSuggestions(query: query)
        let recentSuggestions = getRecentSuggestions(query: query)
        let popularSuggestions = getPopularSuggestions(query: query)
        
        let allSuggestions = (localSuggestions + recentSuggestions + popularSuggestions)
            .removingDuplicates()
            .prefix(5) // Limit to 5 suggestions
        
        await MainActor.run {
            self.autocompleteSuggestions = Array(allSuggestions)
            self.isShowingSuggestions = !self.autocompleteSuggestions.isEmpty
        }
    }
    
    private func performLocalSearch(query: String) async -> [SearchResult] {
        return await withCheckedContinuation { continuation in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            // Set region to Israel if available, otherwise use a default
            let israelCenter = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
            request.region = MKCoordinateRegion(
                center: israelCenter,
                span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
            )
            
            // Apply category filter
            if selectedCategory != .all {
                request.pointOfInterestFilter = getMKPointOfInterestFilter(for: selectedCategory)
            }
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let error = error {
                    print("Local search error: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                
                guard let response = response else {
                    continuation.resume(returning: [])
                    return
                }
                
                let results = response.mapItems.compactMap { item in
                    SearchResult(
                        name: item.name ?? "Unknown",
                        subtitle: item.placemark.title,
                        address: item.placemark.title,
                        coordinate: item.placemark.coordinate,
                        mapItem: item,
                        category: self.determineCategory(from: item),
                        rating: self.extractRating(from: item),
                        isOpen: self.isPlaceOpen(item: item)
                    )
                }
                
                continuation.resume(returning: results)
            }
        }
    }
    
    private func performGeocodingSearch(query: String) async -> [SearchResult] {
        return await withCheckedContinuation { continuation in
            geocoder.geocodeAddressString(query, in: nil, preferredLocale: nil) { placemarks, error in
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                
                guard let placemarks = placemarks else {
                    continuation.resume(returning: [])
                    return
                }
                
                let results = placemarks.compactMap { placemark in
                    SearchResult(
                        name: placemark.name ?? "Address",
                        subtitle: placemark.locality,
                        address: self.formatAddress(from: placemark),
                        coordinate: placemark.location?.coordinate ?? CLLocationCoordinate2D(),
                        mapItem: nil,
                        category: .all,
                        rating: nil,
                        isOpen: nil
                    )
                }
                
                continuation.resume(returning: results)
            }
        }
    }
    
    private func getLocalSuggestions(query: String) async -> [SearchSuggestion] {
        // This would typically call a local search API with autocomplete
        // For now, return empty array
        return []
    }
    
    private func getRecentSuggestions(query: String) -> [SearchSuggestion] {
        return recentSearches
            .filter { $0.name.localizedCaseInsensitiveContains(query) }
            .prefix(3)
            .map { SearchSuggestion(text: $0.name, type: .recent, category: $0.category) }
    }
    
    private func getPopularSuggestions(query: String) -> [SearchSuggestion] {
        let popularSearches = [
            "קפה", "מסעדה", "בית חולים", "תחנת דלק", "פארק", "מוזיאון",
            "Coffee", "Restaurant", "Hospital", "Gas Station", "Park", "Museum"
        ]
        
        return popularSearches
            .filter { $0.localizedCaseInsensitiveContains(query) }
            .prefix(2)
            .map { SearchSuggestion(text: $0, type: .popular, category: .all) }
    }
    
    private func getMKPointOfInterestFilter(for category: SearchCategory) -> MKPointOfInterestFilter {
        switch category {
        case .all:
            return MKPointOfInterestFilter(including: [])
        case .food:
            return MKPointOfInterestFilter(including: [.restaurant, .cafe, .bakery, .brewery, .winery, .foodMarket])
        case .shopping:
            return MKPointOfInterestFilter(including: [.store])
        case .entertainment:
            return MKPointOfInterestFilter(including: [.amusementPark, .aquarium, .beach, .campground, .marina, .movieTheater, .nationalPark, .nightlife, .park, .stadium, .theater, .zoo])
        case .services:
            return MKPointOfInterestFilter(including: [.bank, .postOffice, .library, .school, .university, .hospital, .pharmacy, .police, .fireStation])
        case .transportation:
            return MKPointOfInterestFilter(including: [.airport, .carRental, .evCharger, .gasStation, .parking, .publicTransport])
        }
    }
    
    private func determineCategory(from item: MKMapItem) -> SearchCategory {
        // Determine category based on MKMapItem properties
        if let pointOfInterestCategory = item.pointOfInterestCategory {
            switch pointOfInterestCategory {
            case .restaurant, .cafe, .bakery, .brewery, .winery, .foodMarket:
                return .food
            case .store:
                return .shopping
            case .amusementPark, .aquarium, .beach, .campground, .marina, .movieTheater, .nationalPark, .nightlife, .park, .stadium, .theater, .zoo:
                return .entertainment
            case .bank, .postOffice, .library, .school, .university, .hospital, .pharmacy, .police, .fireStation:
                return .services
            case .airport, .carRental, .evCharger, .gasStation, .parking, .publicTransport:
                return .transportation
            default:
                return .all
            }
        }
        
        return .all
    }
    
    private func extractRating(from item: MKMapItem) -> Double? {
        // Extract rating from MKMapItem if available
        return nil // MapKit doesn't provide ratings directly
    }
    
    private func isPlaceOpen(item: MKMapItem) -> Bool? {
        // Check if place is currently open
        return nil // This would require additional API calls
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    private func applyFilters(to results: [SearchResult]) -> [SearchResult] {
        var filteredResults = results
        
        // Apply category filter
        if selectedCategory != .all {
            filteredResults = filteredResults.filter { $0.category == selectedCategory }
        }
        
        // Apply other filters
        if searchFilters.isOpenOnly {
            filteredResults = filteredResults.filter { $0.isOpen == true }
        }
        
        if searchFilters.minRating > 0 {
            filteredResults = filteredResults.filter { 
                guard let rating = $0.rating else { return false }
                return rating >= searchFilters.minRating
            }
        }
        
        if searchFilters.maxDistance > 0, let userLocation = getCurrentLocation() {
            filteredResults = filteredResults.filter { result in
                let resultLocation = CLLocation(latitude: result.coordinate.latitude, longitude: result.coordinate.longitude)
                return userLocation.distance(from: resultLocation) <= searchFilters.maxDistance
            }
        }
        
        return filteredResults
    }
    
    private func getCurrentLocation() -> CLLocation? {
        // This would get the current location from LocationService
        return nil
    }
    
    private func loadRecentSearches() {
        // Load from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "recentSearches"),
           let searches = try? JSONDecoder().decode([SearchResult].self, from: data)
        {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: "recentSearches")
        }
    }
}

public struct SearchResult: Identifiable, Codable, Equatable {
    public let id = UUID()
    public let name: String
    public let subtitle: String?
    public let address: String?
    public let coordinate: CLLocationCoordinate2D
    public let mapItem: MKMapItem?
    public let category: SearchCategory
    public let rating: Double?
    public let isOpen: Bool?
    public let phoneNumber: String?
    public let website: String?
    public let hours: [String]?
    public let priceLevel: Int?
    public let photos: [String]?

    public init(
        name: String,
        subtitle: String? = nil,
        address: String? = nil,
        coordinate: CLLocationCoordinate2D,
        mapItem: MKMapItem? = nil,
        category: SearchCategory = .all,
        rating: Double? = nil,
        isOpen: Bool? = nil,
        phoneNumber: String? = nil,
        website: String? = nil,
        hours: [String]? = nil,
        priceLevel: Int? = nil,
        photos: [String]? = nil
    ) {
        self.name = name
        self.subtitle = subtitle
        self.address = address
        self.coordinate = coordinate
        self.mapItem = mapItem
        self.category = category
        self.rating = rating
        self.isOpen = isOpen
        self.phoneNumber = phoneNumber
        self.website = website
        self.hours = hours
        self.priceLevel = priceLevel
        self.photos = photos
    }

    // Custom Codable implementation for CLLocationCoordinate2D
    private enum CodingKeys: String, CodingKey {
        case name, subtitle, address, latitude, longitude, category, rating, isOpen, phoneNumber, website, hours, priceLevel, photos
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapItem = nil
        category = try container.decodeIfPresent(SearchCategory.self, forKey: .category) ?? .all
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        isOpen = try container.decodeIfPresent(Bool.self, forKey: .isOpen)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        hours = try container.decodeIfPresent([String].self, forKey: .hours)
        priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel)
        photos = try container.decodeIfPresent([String].self, forKey: .photos)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(isOpen, forKey: .isOpen)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(hours, forKey: .hours)
        try container.encodeIfPresent(priceLevel, forKey: .priceLevel)
        try container.encodeIfPresent(photos, forKey: .photos)
    }
    
    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name == rhs.name && 
               lhs.coordinate.latitude == rhs.coordinate.latitude && 
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// MARK: - Search Suggestion Model

public struct SearchSuggestion: Identifiable, Codable, Equatable {
    public let id = UUID()
    public let text: String
    public let type: SuggestionType
    public let category: SearchCategory
    
    public init(text: String, type: SuggestionType, category: SearchCategory) {
        self.text = text
        self.type = type
        self.category = category
    }
    
    public static func == (lhs: SearchSuggestion, rhs: SearchSuggestion) -> Bool {
        return lhs.text == rhs.text && lhs.type == rhs.type
    }
}

// MARK: - Suggestion Type

public enum SuggestionType: String, CaseIterable, Codable {
    case recent
    case popular
    case local
    case address
    
    public var displayName: String {
        switch self {
        case .recent: "Recent"
        case .popular: "Popular"
        case .local: "Local"
        case .address: "Address"
        }
    }
    
    public var icon: String {
        switch self {
        case .recent: "clock"
        case .popular: "star"
        case .local: "location"
        case .address: "house"
        }
    }
}

// MARK: - Search Filters

public struct SearchFilters: Codable {
    public var isOpenOnly: Bool = false
    public var minRating: Double = 0.0
    public var maxDistance: Double = 0.0 // in meters
    public var priceLevel: Int? = nil // 1-4
    public var hasPhotos: Bool = false
    public var isAccessible: Bool = false
    
    public init(
        isOpenOnly: Bool = false,
        minRating: Double = 0.0,
        maxDistance: Double = 0.0,
        priceLevel: Int? = nil,
        hasPhotos: Bool = false,
        isAccessible: Bool = false
    ) {
        self.isOpenOnly = isOpenOnly
        self.minRating = minRating
        self.maxDistance = maxDistance
        self.priceLevel = priceLevel
        self.hasPhotos = hasPhotos
        self.isAccessible = isAccessible
    }
}

// MARK: - Array Extension for Removing Duplicates

extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
}

