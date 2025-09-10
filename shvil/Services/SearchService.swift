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
    
    // Caching
    private let searchCache = NSCache<NSString, NSArray>()
    private let autocompleteCache = NSCache<NSString, NSArray>()
    private let cacheExpirationTime: TimeInterval = 300 // 5 minutes
    
    // Search categories and filters
    @Published var selectedCategory: SearchCategory = .all
    @Published var searchFilters: SearchFilters = SearchFilters()
    
    init() {
        loadRecentSearches()
        setupSearchTextObserver()
        setupCaches()
    }
    
    private func setupCaches() {
        searchCache.countLimit = 50
        autocompleteCache.countLimit = 100
    }
    
    func search(for query: String) {
        guard !query.isEmpty else {
            searchResults = []
            autocompleteSuggestions = []
            isShowingSuggestions = false
            return
        }
        
        // Check cache first
        let cacheKey = "\(query)_\(selectedCategory.rawValue)" as NSString
        if let cachedResults = searchCache.object(forKey: cacheKey) as? [SearchResult] {
            searchResults = cachedResults
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
        
        // Check cache first
        let cacheKey = query as NSString
        if let cachedSuggestions = autocompleteCache.object(forKey: cacheKey) as? [SearchSuggestion] {
            autocompleteSuggestions = cachedSuggestions
            isShowingSuggestions = true
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
                
                // Cache the results
                let cacheKey = "\(query)_\(self.selectedCategory.rawValue)" as NSString
                self.searchCache.setObject(filteredResults as NSArray, forKey: cacheKey)
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
            
            // Cache the suggestions
            let cacheKey = query as NSString
            self.autocompleteCache.setObject(Array(allSuggestions) as NSArray, forKey: cacheKey)
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
                        id: UUID(),
                        name: item.name ?? "Unknown",
                        address: item.placemark.title ?? "",
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude,
                        category: self.determineCategory(from: item).rawValue,
                        rating: self.extractRating(from: item),
                        distance: 0.0, // Distance calculation not available
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
                        id: UUID(),
                        name: placemark.name ?? "Address",
                        address: self.formatAddress(from: placemark),
                        latitude: placemark.location?.coordinate.latitude ?? 0,
                        longitude: placemark.location?.coordinate.longitude ?? 0,
                        category: "address",
                        rating: nil,
                        distance: nil,
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
            .map { SearchSuggestion(id: UUID(), text: $0.name, category: $0.category, popularity: 1) }
    }
    
    private func getPopularSuggestions(query: String) -> [SearchSuggestion] {
        let popularSearches = [
            "קפה", "מסעדה", "בית חולים", "תחנת דלק", "פארק", "מוזיאון",
            "Coffee", "Restaurant", "Hospital", "Gas Station", "Park", "Museum"
        ]
        
        return popularSearches
            .filter { $0.localizedCaseInsensitiveContains(query) }
            .prefix(2)
            .map { SearchSuggestion(id: UUID(), text: $0, category: "popular", popularity: 5) }
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
            filteredResults = filteredResults.filter { $0.category == selectedCategory.rawValue }
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
                let resultLocation = CLLocation(latitude: result.latitude, longitude: result.longitude)
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


// MARK: - Search Suggestion Model


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

