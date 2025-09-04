//
//  TestHelpers.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import CoreLocation

/// Test helpers and utilities for Shvil app
class TestHelpers {
    static let shared = TestHelpers()
    
    private init() {}
    
    // MARK: - Test Data
    
    let testCoordinates = TestCoordinates()
    let testLocations = TestLocations()
    
    // MARK: - Mock Data Creation
    
    func createMockSearchResult() -> SearchResult {
        return SearchResult(
            name: "Test Restaurant",
            subtitle: "Test Subtitle",
            address: "123 Test Street, Test City",
            coordinate: testCoordinates.telAviv,
            mapItem: nil,
            category: .food,
            rating: 4.5,
            isOpen: true,
            phoneNumber: "123-456-7890",
            website: "https://test.com",
            hours: ["9:00-17:00"],
            priceLevel: 2,
            photos: []
        )
    }
    
    func createMockAdventurePlan() -> AdventurePlan {
        let stop = AdventureStop(
            name: "Test Stop",
            description: "Test Description",
            coordinate: testCoordinates.telAviv,
            category: .food,
            estimatedDuration: 60,
            openingHours: "9:00-17:00",
            priceLevel: .medium,
            rating: 4.5,
            isAccessible: true,
            tags: ["test", "mock"]
        )
        
        return AdventurePlan(
            id: UUID(),
            title: "Test Adventure",
            description: "Test Adventure Description",
            theme: .adventurous,
            stops: [stop],
            totalDuration: 120,
            totalDistance: 1000,
            budgetLevel: .medium,
            status: .draft,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func createMockRoute() -> Route {
        let routeOption = RouteOptions(
            avoidTolls: false,
            avoidFerries: false,
            preferScenic: false
        )
        
        return Route(
            id: UUID(),
            name: "Test Route",
            distance: 10000, // 10km
            expectedTravelTime: 1800, // 30 minutes
            polyline: [testCoordinates.telAviv, testCoordinates.jerusalem],
            steps: [],
            options: routeOption,
            isFastest: true,
            isSafest: false,
            tollCost: nil,
            fuelCost: nil,
            createdAt: Date()
        )
    }
    
    func createMockSafetyReport() -> SafetyReport {
        return SafetyReport(
            id: UUID(),
            type: .accident,
            coordinate: testCoordinates.telAviv,
            description: "Test incident",
            createdAt: Date()
        )
    }
    
    // MARK: - Test Utilities
    
    func waitForAsyncOperation(timeout: TimeInterval = 5.0) {
        // Simple wait without XCTest dependencies
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    func simulateNetworkDelay() {
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    func simulateNetworkError() -> Error {
        return NSError(domain: "TestNetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "Network connection lost"])
    }
}

// MARK: - Test Data Structures

struct TestCoordinates {
    let telAviv = CLLocationCoordinate2D(latitude: 32.0853, longitude: 34.7818)
    let jerusalem = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
    let haifa = CLLocationCoordinate2D(latitude: 32.7940, longitude: 34.9896)
    let eilat = CLLocationCoordinate2D(latitude: 29.5581, longitude: 34.9482)
    let netanya = CLLocationCoordinate2D(latitude: 32.3215, longitude: 34.8532)
}

struct TestLocations {
    let telAviv = CLLocation(latitude: 32.0853, longitude: 34.7818)
    let jerusalem = CLLocation(latitude: 31.7683, longitude: 35.2137)
    let haifa = CLLocation(latitude: 32.7940, longitude: 34.9896)
    let eilat = CLLocation(latitude: 29.5581, longitude: 34.9482)
    let netanya = CLLocation(latitude: 32.3215, longitude: 34.8532)
}

// MARK: - Mock Services

class MockSearchService: SearchService {
    var mockResults: [SearchResult] = []
    var shouldThrowError = false
    
    override func search(for query: String) {
        if shouldThrowError {
            error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock search error"])
            return
        }
        
        searchResults = mockResults
    }
    
    override func getAutocompleteSuggestions(for query: String) {
        if shouldThrowError {
            error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock autocomplete error"])
            return
        }
        
        autocompleteSuggestions = [
            SearchSuggestion(text: "Test Suggestion 1", type: .popular, category: .food),
            SearchSuggestion(text: "Test Suggestion 2", type: .recent, category: .entertainment)
        ]
    }
}

class MockNavigationService: NavigationService {
    var mockRoutes: [Route] = []
    var shouldThrowError = false
    
    override func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D] = [], options: RouteOptions = RouteOptions(), completion: @escaping (Bool) -> Void = { _ in }) {
        if shouldThrowError {
            error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock navigation error"])
            completion(false)
            return
        }
        
        routes = mockRoutes
        currentRoute = mockRoutes.first
        completion(true)
    }
}

class MockAdventureService: AdventureService {
    var mockAdventure: AdventurePlan?
    var shouldThrowError = false
    
    override func generateAdventure(input: AdventureGenerationInput) async throws -> AdventurePlan {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock adventure error"])
        }
        
        guard let adventure = mockAdventure else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No mock adventure set"])
        }
        
        return adventure
    }
}

// MARK: - Test Extensions

// Note: XCTestCase extensions removed as XCTest is not available in main target
