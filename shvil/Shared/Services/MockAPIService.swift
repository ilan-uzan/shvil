//
//  MockAPIService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

/// Mock API service for testing and development
class MockAPIService: ObservableObject {
    static let shared = MockAPIService()
    
    @Published var isConnected = true
    @Published var responseDelay: TimeInterval = 0.1
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Authentication
    
    func login(_ request: LoginRequest) async throws -> APIResponse<User> {
        try await simulateDelay()
        
        if request.email == "test@example.com" && request.password == "password" {
            let user = User(
                id: UUID(),
                email: request.email,
                displayName: "Test User",
                avatarUrl: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            return APIResponse(data: user, error: nil, success: true, message: "Login successful")
        } else {
            let error = APIError(code: "INVALID_CREDENTIALS", message: "Invalid email or password", details: nil)
            return APIResponse(data: nil, error: error, success: false, message: "Login failed")
        }
    }
    
    func register(_ request: RegisterRequest) async throws -> APIResponse<User> {
        try await simulateDelay()
        
        let user = User(
            id: UUID(),
            email: request.email,
            displayName: request.displayName,
            avatarUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        return APIResponse(data: user, error: nil, success: true, message: "Registration successful")
    }
    
    func logout() async throws -> APIResponse<String> {
        try await simulateDelay()
        return APIResponse(data: "Logged out", error: nil, success: true, message: "Logout successful")
    }
    
    // MARK: - User Profile
    
    func getUserProfile() async throws -> APIResponse<UserProfile> {
        try await simulateDelay()
        
        let user = User(
            id: UUID(),
            email: "test@example.com",
            displayName: "Test User",
            avatarUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let preferences = UserPreferences(
            language: "en",
            theme: "light",
            notifications: NotificationSettings(),
            privacy: PrivacySettings()
        )
        
        let stats = UserStats(
            totalAdventures: 5,
            totalDistance: 100.0,
            favoritePlaces: 3,
            joinedAt: Date()
        )
        
        let profile = UserProfile(user: user, preferences: preferences, stats: stats)
        return APIResponse(data: profile, error: nil, success: true, message: "Profile retrieved")
    }
    
    // MARK: - Saved Places
    
    func getSavedPlaces() async throws -> APIResponse<[SavedPlace]> {
        try await simulateDelay()
        
        let places = [
            SavedPlace(
                id: UUID(),
                userId: UUID(),
                name: "Home",
                address: "123 Main St",
                latitude: 37.7749,
                longitude: -122.4194,
                placeType: .home,
                createdAt: Date(),
                updatedAt: Date()
            ),
            SavedPlace(
                id: UUID(),
                userId: UUID(),
                name: "Work",
                address: "456 Business Ave",
                latitude: 37.7849,
                longitude: -122.4094,
                placeType: .work,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        return APIResponse(data: places, error: nil, success: true, message: "Places retrieved")
    }
    
    func createSavedPlace(_ place: SavedPlace) async throws -> APIResponse<SavedPlace> {
        try await simulateDelay()
        return APIResponse(data: place, error: nil, success: true, message: "Place created")
    }
    
    func updateSavedPlace(_ place: SavedPlace) async throws -> APIResponse<SavedPlace> {
        try await simulateDelay()
        return APIResponse(data: place, error: nil, success: true, message: "Place updated")
    }
    
    func deleteSavedPlace(id: UUID) async throws -> APIResponse<String> {
        try await simulateDelay()
        return APIResponse(data: "Deleted", error: nil, success: true, message: "Place deleted")
    }
    
    // MARK: - Adventures
    
    func getAdventures() async throws -> APIResponse<[Adventure]> {
        try await simulateDelay()
        
        let adventures = [
            Adventure(
                id: UUID(),
                userId: UUID(),
                title: "City Walk",
                description: "A nice walk around the city",
                routeData: RouteData(
                    origin: LocationData(latitude: 37.7749, longitude: -122.4194, address: "Start", name: "Start"),
                    destination: LocationData(latitude: 37.7849, longitude: -122.4094, address: "End", name: "End"),
                    waypoints: [],
                    distance: 2000,
                    duration: 1200,
                    transportMode: "walking",
                    estimatedArrival: Date()
                ),
                stops: [],
                status: .draft,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        return APIResponse(data: adventures, error: nil, success: true, message: "Adventures retrieved")
    }
    
    func createAdventure(_ request: CreateAdventureRequest) async throws -> APIResponse<Adventure> {
        try await simulateDelay()
        
        let adventure = Adventure(
            id: UUID(),
            userId: UUID(),
            title: request.title,
            description: request.description,
            routeData: request.routeData,
            stops: request.stops,
            status: .draft,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return APIResponse(data: adventure, error: nil, success: true, message: "Adventure created")
    }
    
    func updateAdventure(id: UUID, _ request: UpdateAdventureRequest) async throws -> APIResponse<Adventure> {
        try await simulateDelay()
        
        // Mock update - in real implementation, this would fetch and update the adventure
        let adventure = Adventure(
            id: id,
            userId: UUID(),
            title: request.title ?? "Updated Adventure",
            description: request.description,
            routeData: RouteData(
                origin: LocationData(latitude: 37.7749, longitude: -122.4194, address: "Start", name: "Start"),
                destination: LocationData(latitude: 37.7849, longitude: -122.4094, address: "End", name: "End"),
                waypoints: [],
                distance: 2000,
                duration: 1200,
                transportMode: "walking",
                estimatedArrival: Date()
            ),
            stops: request.stops ?? [],
            status: request.status ?? .draft,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return APIResponse(data: adventure, error: nil, success: true, message: "Adventure updated")
    }
    
    func deleteAdventure(id: UUID) async throws -> APIResponse<String> {
        try await simulateDelay()
        return APIResponse(data: "Deleted", error: nil, success: true, message: "Adventure deleted")
    }
    
    // MARK: - Safety Reports
    
    func getSafetyReports() async throws -> APIResponse<[SafetyReport]> {
        try await simulateDelay()
        
        let reports = [
            SafetyReport(
                id: UUID(),
                userId: UUID(),
                latitude: 37.7749,
                longitude: -122.4194,
                reportType: "hazard",
                description: "Slippery surface",
                severity: 2,
                isResolved: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        return APIResponse(data: reports, error: nil, success: true, message: "Safety reports retrieved")
    }
    
    func createSafetyReport(_ request: CreateSafetyReportRequest) async throws -> APIResponse<SafetyReport> {
        try await simulateDelay()
        
        let report = SafetyReport(
            id: UUID(),
            userId: UUID(),
            latitude: request.latitude,
            longitude: request.longitude,
            reportType: request.reportType,
            description: request.description,
            severity: request.severity,
            isResolved: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return APIResponse(data: report, error: nil, success: true, message: "Safety report created")
    }
    
    // MARK: - Search
    
    func search(query: String) async throws -> APIResponse<[SearchResult]> {
        try await simulateDelay()
        
        let results = [
            SearchResult(
                id: UUID(),
                name: "Test Location",
                address: "123 Test St",
                latitude: 37.7749,
                longitude: -122.4194,
                category: "restaurant",
                rating: 4.5,
                distance: 100.0,
                isOpen: true
            )
        ]
        
        return APIResponse(data: results, error: nil, success: true, message: "Search completed")
    }
    
    // MARK: - Helper Methods
    
    private func simulateDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64(responseDelay * 1_000_000_000))
    }
}

// MARK: - Additional Models

struct NotificationSettings: Codable {
    let push: Bool
    let email: Bool
    let sms: Bool
    
    init() {
        self.push = true
        self.email = false
        self.sms = false
    }
}

struct PrivacySettings: Codable {
    let shareLocation: Bool
    let shareAdventures: Bool
    let sharePlaces: Bool
    
    init() {
        self.shareLocation = false
        self.shareAdventures = false
        self.sharePlaces = false
    }
}
