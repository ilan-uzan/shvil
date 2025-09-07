//
//  APIModelsTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

import XCTest
@testable import shvil

final class APIModelsTests: XCTestCase {
    
    // MARK: - Authentication Models Tests
    
    func testAuthenticationResponse() {
        let user = User(
            id: "test-user-id",
            email: "test@example.com",
            displayName: "Test User",
            avatarURL: "https://example.com/avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let session = Session(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        let response = AuthenticationResponse(
            isSuccess: true,
            user: user,
            session: session,
            error: nil
        )
        
        XCTAssertTrue(response.isSuccess)
        XCTAssertNotNil(response.user)
        XCTAssertNotNil(response.session)
        XCTAssertNil(response.error)
        XCTAssertEqual(response.user?.id, "test-user-id")
        XCTAssertEqual(response.user?.email, "test@example.com")
    }
    
    func testAuthenticationResponseFailure() {
        let error = APIError(
            code: "AUTH_FAILED",
            message: "Authentication failed",
            details: "Invalid credentials"
        )
        
        let response = AuthenticationResponse(
            isSuccess: false,
            user: nil,
            session: nil,
            error: error
        )
        
        XCTAssertFalse(response.isSuccess)
        XCTAssertNil(response.user)
        XCTAssertNil(response.session)
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error?.code, "AUTH_FAILED")
    }
    
    // MARK: - User Models Tests
    
    func testUser() {
        let user = User(
            id: "user-123",
            email: "user@example.com",
            displayName: "John Doe",
            avatarURL: "https://example.com/avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(user.id, "user-123")
        XCTAssertEqual(user.email, "user@example.com")
        XCTAssertEqual(user.displayName, "John Doe")
        XCTAssertEqual(user.avatarURL, "https://example.com/avatar.jpg")
        XCTAssertNotNil(user.createdAt)
        XCTAssertNotNil(user.updatedAt)
    }
    
    func testUserProfile() {
        let profile = UserProfile(
            id: "profile-123",
            displayName: "Jane Smith",
            email: "jane@example.com",
            avatarURL: "https://example.com/avatar.jpg",
            bio: "Adventure enthusiast",
            preferences: UserPreferences(
                language: "en",
                units: "metric",
                notifications: true,
                privacy: "public"
            ),
            stats: UserStats(
                adventuresCompleted: 5,
                totalDistance: 100.5,
                totalTime: 7200,
                achievements: ["first_adventure", "explorer"]
            ),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(profile.id, "profile-123")
        XCTAssertEqual(profile.displayName, "Jane Smith")
        XCTAssertEqual(profile.email, "jane@example.com")
        XCTAssertEqual(profile.bio, "Adventure enthusiast")
        XCTAssertNotNil(profile.preferences)
        XCTAssertNotNil(profile.stats)
        XCTAssertEqual(profile.stats?.adventuresCompleted, 5)
        XCTAssertEqual(profile.stats?.totalDistance, 100.5)
    }
    
    // MARK: - Adventure Models Tests
    
    func testAdventure() {
        let stop = AdventureStop(
            id: "stop-1",
            name: "Mountain Peak",
            description: "Beautiful mountain view",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            order: 1,
            isCompleted: false,
            completedAt: nil
        )
        
        let adventure = Adventure(
            id: "adventure-123",
            title: "Mountain Trail",
            description: "A challenging mountain trail",
            createdBy: "user-123",
            stops: [stop],
            status: .active,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(adventure.id, "adventure-123")
        XCTAssertEqual(adventure.title, "Mountain Trail")
        XCTAssertEqual(adventure.createdBy, "user-123")
        XCTAssertEqual(adventure.stops.count, 1)
        XCTAssertEqual(adventure.status, .active)
        XCTAssertNotNil(adventure.createdAt)
        XCTAssertNotNil(adventure.updatedAt)
    }
    
    func testAdventureStop() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let stop = AdventureStop(
            id: "stop-1",
            name: "Mountain Peak",
            description: "Beautiful mountain view",
            coordinate: coordinate,
            order: 1,
            isCompleted: false,
            completedAt: nil
        )
        
        XCTAssertEqual(stop.id, "stop-1")
        XCTAssertEqual(stop.name, "Mountain Peak")
        XCTAssertEqual(stop.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(stop.coordinate.longitude, coordinate.longitude)
        XCTAssertEqual(stop.order, 1)
        XCTAssertFalse(stop.isCompleted)
        XCTAssertNil(stop.completedAt)
    }
    
    // MARK: - Route Models Tests
    
    func testRoute() {
        let waypoint = RouteWaypoint(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            name: "Start Point",
            order: 1
        )
        
        let route = Route(
            id: "route-123",
            distance: 5.5,
            estimatedTime: 3600,
            waypoints: [waypoint],
            createdAt: Date()
        )
        
        XCTAssertEqual(route.id, "route-123")
        XCTAssertEqual(route.distance, 5.5)
        XCTAssertEqual(route.estimatedTime, 3600)
        XCTAssertEqual(route.waypoints.count, 1)
        XCTAssertNotNil(route.createdAt)
    }
    
    func testRouteWaypoint() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let waypoint = RouteWaypoint(
            coordinate: coordinate,
            name: "Start Point",
            order: 1
        )
        
        XCTAssertEqual(waypoint.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(waypoint.coordinate.longitude, coordinate.longitude)
        XCTAssertEqual(waypoint.name, "Start Point")
        XCTAssertEqual(waypoint.order, 1)
    }
    
    // MARK: - Social Models Tests
    
    func testSocialPlan() {
        let participant = PlanParticipant(
            id: "participant-1",
            userId: "user-123",
            displayName: "John Doe",
            avatarURL: "https://example.com/avatar.jpg",
            joinedAt: Date()
        )
        
        let option = PlanOption(
            id: "option-1",
            title: "Hiking Trail",
            description: "A scenic hiking trail",
            votes: 5,
            voters: ["user-1", "user-2", "user-3", "user-4", "user-5"]
        )
        
        let plan = Plan(
            id: "plan-123",
            title: "Weekend Adventure",
            description: "A fun weekend adventure",
            createdBy: "user-123",
            participants: [participant],
            options: [option],
            status: .active,
            votingEndsAt: Date().addingTimeInterval(86400),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(plan.id, "plan-123")
        XCTAssertEqual(plan.title, "Weekend Adventure")
        XCTAssertEqual(plan.createdBy, "user-123")
        XCTAssertEqual(plan.participants.count, 1)
        XCTAssertEqual(plan.options.count, 1)
        XCTAssertEqual(plan.status, .active)
        XCTAssertNotNil(plan.votingEndsAt)
    }
    
    func testPlanParticipant() {
        let participant = PlanParticipant(
            id: "participant-1",
            userId: "user-123",
            displayName: "John Doe",
            avatarURL: "https://example.com/avatar.jpg",
            joinedAt: Date()
        )
        
        XCTAssertEqual(participant.id, "participant-1")
        XCTAssertEqual(participant.userId, "user-123")
        XCTAssertEqual(participant.displayName, "John Doe")
        XCTAssertEqual(participant.avatarURL, "https://example.com/avatar.jpg")
        XCTAssertNotNil(participant.joinedAt)
    }
    
    func testPlanOption() {
        let option = PlanOption(
            id: "option-1",
            title: "Hiking Trail",
            description: "A scenic hiking trail",
            votes: 5,
            voters: ["user-1", "user-2", "user-3", "user-4", "user-5"]
        )
        
        XCTAssertEqual(option.id, "option-1")
        XCTAssertEqual(option.title, "Hiking Trail")
        XCTAssertEqual(option.votes, 5)
        XCTAssertEqual(option.voters.count, 5)
    }
    
    // MARK: - Error Models Tests
    
    func testAPIError() {
        let error = APIError(
            code: "VALIDATION_ERROR",
            message: "Invalid input data",
            details: "The email field is required"
        )
        
        XCTAssertEqual(error.code, "VALIDATION_ERROR")
        XCTAssertEqual(error.message, "Invalid input data")
        XCTAssertEqual(error.details, "The email field is required")
    }
    
    func testAPIErrorWithoutDetails() {
        let error = APIError(
            code: "SERVER_ERROR",
            message: "Internal server error",
            details: nil
        )
        
        XCTAssertEqual(error.code, "SERVER_ERROR")
        XCTAssertEqual(error.message, "Internal server error")
        XCTAssertNil(error.details)
    }
    
    // MARK: - Performance Models Tests
    
    func testPerformanceMetrics() {
        let metrics = PerformanceMetrics(
            responseTime: 150.5,
            memoryUsage: 1024 * 1024 * 50, // 50MB
            cpuUsage: 25.5,
            timestamp: Date()
        )
        
        XCTAssertEqual(metrics.responseTime, 150.5)
        XCTAssertEqual(metrics.memoryUsage, 1024 * 1024 * 50)
        XCTAssertEqual(metrics.cpuUsage, 25.5)
        XCTAssertNotNil(metrics.timestamp)
    }
    
    // MARK: - Enum Tests
    
    func testAdventureStatus() {
        XCTAssertEqual(AdventureStatus.active.rawValue, "active")
        XCTAssertEqual(AdventureStatus.completed.rawValue, "completed")
        XCTAssertEqual(AdventureStatus.cancelled.rawValue, "cancelled")
        XCTAssertEqual(AdventureStatus.paused.rawValue, "paused")
    }
    
    func testPlanStatus() {
        XCTAssertEqual(PlanStatus.draft.rawValue, "draft")
        XCTAssertEqual(PlanStatus.active.rawValue, "active")
        XCTAssertEqual(PlanStatus.completed.rawValue, "completed")
        XCTAssertEqual(PlanStatus.cancelled.rawValue, "cancelled")
    }
    
    func testContractTestStatus() {
        XCTAssertEqual(ContractTestStatus.notRun.displayName, "Not Run")
        XCTAssertEqual(ContractTestStatus.running.displayName, "Running")
        XCTAssertEqual(ContractTestStatus.passed.displayName, "Passed")
        XCTAssertEqual(ContractTestStatus.partial.displayName, "Partial")
        XCTAssertEqual(ContractTestStatus.failed.displayName, "Failed")
    }
    
    // MARK: - Codable Tests
    
    func testUserCodable() {
        let user = User(
            id: "user-123",
            email: "user@example.com",
            displayName: "John Doe",
            avatarURL: "https://example.com/avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(user)
            XCTAssertFalse(data.isEmpty)
            
            // Test decoding
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedUser = try decoder.decode(User.self, from: data)
            
            XCTAssertEqual(decodedUser.id, user.id)
            XCTAssertEqual(decodedUser.email, user.email)
            XCTAssertEqual(decodedUser.displayName, user.displayName)
            XCTAssertEqual(decodedUser.avatarURL, user.avatarURL)
        } catch {
            XCTFail("Failed to encode/decode User: \(error)")
        }
    }
    
    func testAdventureCodable() {
        let stop = AdventureStop(
            id: "stop-1",
            name: "Mountain Peak",
            description: "Beautiful mountain view",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            order: 1,
            isCompleted: false,
            completedAt: nil
        )
        
        let adventure = Adventure(
            id: "adventure-123",
            title: "Mountain Trail",
            description: "A challenging mountain trail",
            createdBy: "user-123",
            stops: [stop],
            status: .active,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(adventure)
            XCTAssertFalse(data.isEmpty)
            
            // Test decoding
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedAdventure = try decoder.decode(Adventure.self, from: data)
            
            XCTAssertEqual(decodedAdventure.id, adventure.id)
            XCTAssertEqual(decodedAdventure.title, adventure.title)
            XCTAssertEqual(decodedAdventure.createdBy, adventure.createdBy)
            XCTAssertEqual(decodedAdventure.stops.count, adventure.stops.count)
            XCTAssertEqual(decodedAdventure.status, adventure.status)
        } catch {
            XCTFail("Failed to encode/decode Adventure: \(error)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStrings() {
        let user = User(
            id: "",
            email: "",
            displayName: "",
            avatarURL: "",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(user.id.isEmpty)
        XCTAssertTrue(user.email.isEmpty)
        XCTAssertTrue(user.displayName.isEmpty)
        XCTAssertTrue(user.avatarURL.isEmpty)
    }
    
    func testNilValues() {
        let user = User(
            id: "user-123",
            email: "user@example.com",
            displayName: "John Doe",
            avatarURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertNil(user.avatarURL)
    }
    
    func testZeroValues() {
        let route = Route(
            id: "route-123",
            distance: 0.0,
            estimatedTime: 0,
            waypoints: [],
            createdAt: Date()
        )
        
        XCTAssertEqual(route.distance, 0.0)
        XCTAssertEqual(route.estimatedTime, 0)
        XCTAssertTrue(route.waypoints.isEmpty)
    }
}
