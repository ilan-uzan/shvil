//
//  ContextEngine.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation
import Combine
import MapKit

/// On-device heuristics for context-aware suggestions
class ContextEngine: ObservableObject {
    // MARK: - Published Properties
    @Published var contextSuggestions: [ContextSuggestion] = []
    @Published var smartStops: [SmartStop] = []
    @Published var isAnalyzing = false
    
    // MARK: - Private Properties
    private let persistence: Persistence
    private var cancellables = Set<AnyCancellable>()
    private var lastAnalysisTime: Date?
    
    // MARK: - Context Data
    private var recentDestinations: [Destination] = []
    private var timeBasedPatterns: [TimePattern] = []
    private var locationHistory: [LocationEntry] = []
    
    // MARK: - Initialization
    init(persistence: Persistence = Persistence()) {
        self.persistence = persistence
        loadContextData()
    }
    
    // MARK: - Public Methods
    func analyzeContext(currentLocation: CLLocation?, timeOfDay: Date = Date()) {
        isAnalyzing = true
        
        Task {
            await performContextAnalysis(currentLocation: currentLocation, timeOfDay: timeOfDay)
            
            await MainActor.run {
                isAnalyzing = false
                lastAnalysisTime = Date()
            }
        }
    }
    
    func generateSmartStops(for route: MKRoute, currentLocation: CLLocation?) {
        Task {
            let stops = await calculateSmartStops(for: route, currentLocation: currentLocation)
            
            await MainActor.run {
                smartStops = stops
            }
        }
    }
    
    func addDestination(_ destination: Destination) {
        recentDestinations.append(destination)
        // Keep only last 50 destinations
        if recentDestinations.count > 50 {
            recentDestinations.removeFirst(recentDestinations.count - 50)
        }
        
        // Save to persistence
        Task {
            await persistence.saveDestinations(recentDestinations)
        }
    }
    
    func addLocationEntry(_ entry: LocationEntry) {
        locationHistory.append(entry)
        // Keep only last 1000 entries
        if locationHistory.count > 1000 {
            locationHistory.removeFirst(locationHistory.count - 1000)
        }
    }
    
    // MARK: - Private Methods
    private func performContextAnalysis(currentLocation: CLLocation?, timeOfDay: Date) async {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: timeOfDay)
        let weekday = calendar.component(.weekday, from: timeOfDay)
        
        var suggestions: [ContextSuggestion] = []
        
        // Time-based suggestions
        let timeBasedSuggestions = generateTimeBasedSuggestions(hour: hour, weekday: weekday)
        suggestions.append(contentsOf: timeBasedSuggestions)
        
        // Location-based suggestions
        if let location = currentLocation {
            let locationBasedSuggestions = generateLocationBasedSuggestions(currentLocation: location)
            suggestions.append(contentsOf: locationBasedSuggestions)
        }
        
        // Recency-based suggestions
        let recencySuggestions = generateRecencySuggestions()
        suggestions.append(contentsOf: recencySuggestions)
        
        // Sort by relevance score
        suggestions.sort { $0.relevanceScore > $1.relevanceScore }
        
        // Take top 3 suggestions
        suggestions = Array(suggestions.prefix(3))
        
        await MainActor.run {
            contextSuggestions = suggestions
        }
    }
    
    private func generateTimeBasedSuggestions(hour: Int, weekday: Int) -> [ContextSuggestion] {
        var suggestions: [ContextSuggestion] = []
        
        // Morning commute (7-9 AM, weekdays)
        if hour >= 7 && hour <= 9 && weekday >= 2 && weekday <= 6 {
            suggestions.append(ContextSuggestion(
                title: "Work",
                subtitle: "Based on your morning routine",
                type: .work,
                relevanceScore: 0.9
            ))
        }
        
        // Evening commute (5-7 PM, weekdays)
        if hour >= 17 && hour <= 19 && weekday >= 2 && weekday <= 6 {
            suggestions.append(ContextSuggestion(
                title: "Home",
                subtitle: "Based on your evening routine",
                type: .home,
                relevanceScore: 0.9
            ))
        }
        
        // Lunch time (12-2 PM)
        if hour >= 12 && hour <= 14 {
            suggestions.append(ContextSuggestion(
                title: "Lunch",
                subtitle: "Popular restaurants nearby",
                type: .food,
                relevanceScore: 0.7
            ))
        }
        
        return suggestions
    }
    
    private func generateLocationBasedSuggestions(currentLocation: CLLocation) -> [ContextSuggestion] {
        var suggestions: [ContextSuggestion] = []
        
        // Find nearby saved places
        let nearbyPlaces = recentDestinations.filter { destination in
            let distance = currentLocation.distance(from: CLLocation(
                latitude: destination.coordinate.latitude,
                longitude: destination.coordinate.longitude
            ))
            return distance < 5000 // Within 5km
        }
        
        for place in nearbyPlaces.prefix(2) {
            suggestions.append(ContextSuggestion(
                title: place.name,
                subtitle: place.address,
                type: .savedPlace,
                relevanceScore: 0.8
            ))
        }
        
        return suggestions
    }
    
    private func generateRecencySuggestions() -> [ContextSuggestion] {
        var suggestions: [ContextSuggestion] = []
        
        // Get recent destinations (last 7 days)
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let recent = recentDestinations.filter { $0.timestamp > sevenDaysAgo }
        
        // Group by frequency
        let frequencyMap = Dictionary(grouping: recent, by: { $0.name })
        let sortedByFrequency = frequencyMap.sorted { $0.value.count > $1.value.count }
        
        for (name, destinations) in sortedByFrequency.prefix(2) {
            if let destination = destinations.first {
                suggestions.append(ContextSuggestion(
                    title: destination.name,
                    subtitle: "Visited \(destinations.count) times recently",
                    type: .recent,
                    relevanceScore: 0.6
                ))
            }
        }
        
        return suggestions
    }
    
    private func calculateSmartStops(for route: MKRoute, currentLocation: CLLocation?) async -> [SmartStop] {
        var stops: [SmartStop] = []
        
        // Check for fuel stops (if route is long enough)
        if route.distance > 50000 { // 50km
            stops.append(SmartStop(
                type: .fuel,
                title: "Fuel Stop",
                subtitle: "Low fuel detected",
                relevanceScore: 0.9
            ))
        }
        
        // Check for meal stops (if route is during meal times)
        let hour = Calendar.current.component(.hour, from: Date())
        if (hour >= 11 && hour <= 14) || (hour >= 17 && hour <= 20) {
            stops.append(SmartStop(
                type: .food,
                title: "Food Stop",
                subtitle: "Meal time",
                relevanceScore: 0.7
            ))
        }
        
        // Check for rest stops (if route is very long)
        if route.distance > 100000 { // 100km
            stops.append(SmartStop(
                type: .rest,
                title: "Rest Stop",
                subtitle: "Long drive ahead",
                relevanceScore: 0.8
            ))
        }
        
        return stops
    }
    
    private func loadContextData() {
        Task {
            recentDestinations = await persistence.loadDestinations()
            // Load other context data...
        }
    }
}

// MARK: - Supporting Types
struct ContextSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: SuggestionType
    let relevanceScore: Double
}

enum SuggestionType {
    case home
    case work
    case food
    case savedPlace
    case recent
}

struct SmartStop: Identifiable {
    let id = UUID()
    let type: SmartStopType
    let title: String
    let subtitle: String
    let relevanceScore: Double
}

enum SmartStopType {
    case fuel
    case food
    case rest
}

struct Destination: Codable, Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, timestamp: Date) {
        self.name = name
        self.address = address
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.timestamp = timestamp
    }
}

struct TimePattern: Codable {
    let hour: Int
    let weekday: Int
    let commonDestinations: [String]
    let frequency: Int
}

struct LocationEntry: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let accuracy: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D, timestamp: Date, accuracy: Double) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.timestamp = timestamp
        self.accuracy = accuracy
    }
}
