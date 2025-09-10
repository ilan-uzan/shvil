//
//  SmartStopsService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation
import MapKit
import Combine
import SwiftUI

/// Service for generating context-aware smart stop suggestions during navigation
@MainActor
class SmartStopsService: ObservableObject {
    // MARK: - Published Properties
    @Published var activeSuggestions: [SmartStopSuggestion] = []
    @Published var isAnalyzing = false
    @Published var lastAnalysisTime: Date?
    
    // MARK: - Private Properties
    private let contextEngine: ContextEngine
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    private var currentRoute: MKRoute?
    private var currentLocation: CLLocation?
    private var userPreferences: SmartStopsPreferences
    
    // MARK: - Configuration
    private let suggestionThreshold: Double = 0.6
    private let maxSuggestions = 3
    private let analysisInterval: TimeInterval = 30.0 // 30 seconds
    
    // MARK: - Initialization
    init(contextEngine: ContextEngine, locationManager: LocationManager, userPreferences: SmartStopsPreferences = SmartStopsPreferences()) {
        self.contextEngine = contextEngine
        self.locationManager = locationManager
        self.userPreferences = userPreferences
        
        setupObservers()
    }
    
    // MARK: - Public Methods
    func startAnalysis(for route: MKRoute) {
        currentRoute = route
        isAnalyzing = true
        
        // Start periodic analysis
        Timer.publish(every: analysisInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.analyzeSmartStops()
            }
            .store(in: &cancellables)
        
        // Initial analysis
        analyzeSmartStops()
    }
    
    func stopAnalysis() {
        cancellables.removeAll()
        isAnalyzing = false
        activeSuggestions.removeAll()
        currentRoute = nil
    }
    
    func dismissSuggestion(_ suggestion: SmartStopSuggestion) {
        activeSuggestions.removeAll { $0.id == suggestion.id }
    }
    
    func addStopToRoute(_ suggestion: SmartStopSuggestion) {
        // This would integrate with the routing engine to add the stop
        // For now, we'll just dismiss the suggestion
        dismissSuggestion(suggestion)
    }
    
    func snoozeSuggestion(_ suggestion: SmartStopSuggestion, duration: TimeInterval = 300) {
        // Mark suggestion as snoozed and re-analyze after duration
        dismissSuggestion(suggestion)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.analyzeSmartStops()
        }
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        // Observe location updates
        locationManager.$currentLocation
            .sink { [weak self] location in
                self?.currentLocation = location
                if self?.isAnalyzing == true {
                    self?.analyzeSmartStops()
                }
            }
            .store(in: &cancellables)
    }
    
    private func analyzeSmartStops() {
        guard let route = currentRoute else { return }
        
        Task {
            let suggestions = await generateSmartStopSuggestions(for: route)
            
            await MainActor.run {
                // Filter out already shown suggestions
                let newSuggestions = suggestions.filter { suggestion in
                    !activeSuggestions.contains { $0.id == suggestion.id }
                }
                
                // Add new suggestions
                activeSuggestions.append(contentsOf: newSuggestions)
                
                // Keep only top suggestions
                activeSuggestions = Array(activeSuggestions
                    .sorted { $0.relevanceScore > $1.relevanceScore }
                    .prefix(maxSuggestions))
                
                lastAnalysisTime = Date()
            }
        }
    }
    
    private func generateSmartStopSuggestions(for route: MKRoute) async -> [SmartStopSuggestion] {
        var suggestions: [SmartStopSuggestion] = []
        
        // Fuel stops
        if let fuelSuggestions = await generateFuelSuggestions(for: route) {
            suggestions.append(contentsOf: fuelSuggestions)
        }
        
        // Food stops
        if let foodSuggestions = await generateFoodSuggestions(for: route) {
            suggestions.append(contentsOf: foodSuggestions)
        }
        
        // Rest stops
        if let restSuggestions = await generateRestSuggestions(for: route) {
            suggestions.append(contentsOf: restSuggestions)
        }
        
        // Charging stations
        if let chargingSuggestions = await generateChargingSuggestions(for: route) {
            suggestions.append(contentsOf: chargingSuggestions)
        }
        
        // Weather-based suggestions
        if let weatherSuggestions = await generateWeatherSuggestions(for: route) {
            suggestions.append(contentsOf: weatherSuggestions)
        }
        
        // Filter by relevance threshold
        return suggestions.filter { $0.relevanceScore >= suggestionThreshold }
    }
    
    private func generateFuelSuggestions(for route: MKRoute) async -> [SmartStopSuggestion]? {
        // Check if fuel stop is needed based on route distance and user preferences
        let routeDistance = route.distance
        let estimatedFuelNeeded = routeDistance / 1000 * 0.08 // Rough estimate: 8L per 100km
        
        // If route is long enough to need fuel
        if routeDistance > 50000 && estimatedFuelNeeded > 20 { // 50km+ and 20L+ needed
            return [SmartStopSuggestion(
                type: .fuel,
                title: "Fuel Stop",
                subtitle: "Long route ahead - consider refueling",
                relevanceScore: 0.9,
                estimatedDistance: 5000, // 5km
                estimatedTime: 10, // 10 minutes
                icon: "fuelpump.fill",
                color: .orange
            )]
        }
        
        return nil
    }
    
    private func generateFoodSuggestions(for route: MKRoute) async -> [SmartStopSuggestion]? {
        let hour = Calendar.current.component(.hour, from: Date())
        let routeDuration = route.expectedTravelTime
        
        // Check if it's meal time and route is long enough
        let isMealTime = (hour >= 11 && hour <= 14) || (hour >= 17 && hour <= 20)
        let isLongRoute = routeDuration > 3600 // 1 hour
        
        if isMealTime && isLongRoute {
            return [SmartStopSuggestion(
                type: .food,
                title: "Food Stop",
                subtitle: "Meal time - find restaurants nearby",
                relevanceScore: 0.8,
                estimatedDistance: 2000, // 2km
                estimatedTime: 5, // 5 minutes
                icon: "fork.knife",
                color: .green
            )]
        }
        
        return nil
    }
    
    private func generateRestSuggestions(for route: MKRoute) async -> [SmartStopSuggestion]? {
        let routeDuration = route.expectedTravelTime
        
        // Suggest rest stop for very long drives
        if routeDuration > 7200 { // 2 hours
            return [SmartStopSuggestion(
                type: .rest,
                title: "Rest Stop",
                subtitle: "Long drive ahead - take a break",
                relevanceScore: 0.7,
                estimatedDistance: 10000, // 10km
                estimatedTime: 15, // 15 minutes
                icon: "bed.double.fill",
                color: .blue
            )]
        }
        
        return nil
    }
    
    private func generateChargingSuggestions(for route: MKRoute) async -> [SmartStopSuggestion]? {
        // This would check if the user has an electric vehicle
        // For now, we'll use a simple heuristic
        let routeDistance = route.distance
        
        if routeDistance > 100000 { // 100km
            return [SmartStopSuggestion(
                type: .charging,
                title: "Charging Station",
                subtitle: "Long route - find charging stations",
                relevanceScore: 0.6,
                estimatedDistance: 15000, // 15km
                estimatedTime: 30, // 30 minutes
                icon: "bolt.car.fill",
                color: .purple
            )]
        }
        
        return nil
    }
    
    private func generateWeatherSuggestions(for route: MKRoute) async -> [SmartStopSuggestion]? {
        // This would integrate with a weather API
        // For now, we'll use a simple time-based heuristic
        let hour = Calendar.current.component(.hour, from: Date())
        let isEvening = hour >= 18 || hour <= 6
        
        if isEvening {
            return [SmartStopSuggestion(
                type: .weather,
                title: "Indoor Stop",
                subtitle: "Evening hours - find indoor activities",
                relevanceScore: 0.5,
                estimatedDistance: 5000, // 5km
                estimatedTime: 20, // 20 minutes
                icon: "house.fill",
                color: .gray
            )]
        }
        
        return nil
    }
}

// MARK: - Supporting Types
public struct SmartStopSuggestion: Identifiable, Equatable {
    public let id = UUID()
    public let type: SmartStopSuggestionType
    public let title: String
    public let subtitle: String
    public let relevanceScore: Double
    public let estimatedDistance: CLLocationDistance
    public let estimatedTime: TimeInterval
    public let icon: String
    public let color: SmartStopSuggestionColor
    
    public static func == (lhs: SmartStopSuggestion, rhs: SmartStopSuggestion) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum SmartStopSuggestionType: String, CaseIterable {
    case fuel = "fuel"
    case food = "food"
    case rest = "rest"
    case charging = "charging"
    case weather = "weather"
    
    var displayName: String {
        switch self {
        case .fuel: return "Fuel"
        case .food: return "Food"
        case .rest: return "Rest"
        case .charging: return "Charging"
        case .weather: return "Weather"
        }
    }
}

public enum SmartStopSuggestionColor: String, CaseIterable {
    case orange = "orange"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case gray = "gray"
    
    var color: Color {
        switch self {
        case .orange: return Color.orange
        case .green: return Color.green
        case .blue: return Color.blue
        case .purple: return Color.purple
        case .gray: return Color.gray
        }
    }
}

// MARK: - Smart Stops Preferences
struct SmartStopsPreferences: Codable {
    var enableFuelStops: Bool = true
    var enableFoodStops: Bool = true
    var enableRestStops: Bool = true
    var enableChargingStops: Bool = false
    var enableWeatherStops: Bool = true
    var suggestionSensitivity: Double = 0.6 // 0.0 to 1.0
    var maxSuggestions: Int = 3
    var snoozeDuration: TimeInterval = 300 // 5 minutes
}
