//
//  MockAPIServiceTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

import XCTest
@testable import shvil

final class MockAPIServiceTests: XCTestCase {
    var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService.shared
    }
    
    override func tearDown() {
        mockAPIService = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Tests
    
    func testMockAuthentication() {
        let auth = mockAPIService.mockAuthentication()
        
        XCTAssertNotNil(auth)
        XCTAssertTrue(auth.isSuccess)
        XCTAssertNotNil(auth.user)
        XCTAssertNotNil(auth.session)
        XCTAssertTrue(auth.user.id.count > 0)
        XCTAssertTrue(auth.user.email.count > 0)
    }
    
    func testMockAuthenticationFailure() {
        let auth = mockAPIService.mockAuthenticationFailure()
        
        XCTAssertNotNil(auth)
        XCTAssertFalse(auth.isSuccess)
        XCTAssertNil(auth.user)
        XCTAssertNil(auth.session)
        XCTAssertNotNil(auth.error)
    }
    
    // MARK: - User Profile Tests
    
    func testMockUserProfile() {
        let profile = mockAPIService.mockUserProfile()
        
        XCTAssertNotNil(profile)
        XCTAssertFalse(profile.id.isEmpty)
        XCTAssertFalse(profile.displayName.isEmpty)
        XCTAssertFalse(profile.email.isEmpty)
        XCTAssertNotNil(profile.avatarURL)
        XCTAssertNotNil(profile.createdAt)
        XCTAssertNotNil(profile.updatedAt)
    }
    
    func testMockUserProfileUpdate() {
        let profile = mockAPIService.mockUserProfile()
        let updatedProfile = mockAPIService.mockUserProfileUpdate(profile)
        
        XCTAssertNotNil(updatedProfile)
        XCTAssertEqual(updatedProfile.id, profile.id)
        XCTAssertNotEqual(updatedProfile.displayName, profile.displayName)
        XCTAssertTrue(updatedProfile.updatedAt! > profile.updatedAt!)
    }
    
    // MARK: - Adventure Tests
    
    func testMockAdventure() {
        let adventure = mockAPIService.mockAdventure()
        
        XCTAssertNotNil(adventure)
        XCTAssertFalse(adventure.id.isEmpty)
        XCTAssertFalse(adventure.title.isEmpty)
        XCTAssertFalse(adventure.description.isEmpty)
        XCTAssertNotNil(adventure.createdAt)
        XCTAssertNotNil(adventure.updatedAt)
        XCTAssertTrue(adventure.stops.count > 0)
    }
    
    func testMockAdventureList() {
        let adventures = mockAPIService.mockAdventureList()
        
        XCTAssertNotNil(adventures)
        XCTAssertTrue(adventures.count > 0)
        XCTAssertTrue(adventures.count <= 10)
        
        for adventure in adventures {
            XCTAssertFalse(adventure.id.isEmpty)
            XCTAssertFalse(adventure.title.isEmpty)
        }
    }
    
    func testMockAdventureCreation() {
        let newAdventure = mockAPIService.mockAdventureCreation()
        
        XCTAssertNotNil(newAdventure)
        XCTAssertFalse(newAdventure.id.isEmpty)
        XCTAssertFalse(newAdventure.title.isEmpty)
        XCTAssertNotNil(newAdventure.createdAt)
    }
    
    // MARK: - Route Tests
    
    func testMockRoute() {
        let route = mockAPIService.mockRoute()
        
        XCTAssertNotNil(route)
        XCTAssertFalse(route.id.isEmpty)
        XCTAssertTrue(route.distance > 0)
        XCTAssertTrue(route.estimatedTime > 0)
        XCTAssertTrue(route.waypoints.count > 0)
        XCTAssertNotNil(route.createdAt)
    }
    
    func testMockRouteList() {
        let routes = mockAPIService.mockRouteList()
        
        XCTAssertNotNil(routes)
        XCTAssertTrue(routes.count > 0)
        XCTAssertTrue(routes.count <= 5)
        
        for route in routes {
            XCTAssertFalse(route.id.isEmpty)
            XCTAssertTrue(route.distance > 0)
        }
    }
    
    func testMockRouteCalculation() {
        let route = mockAPIService.mockRouteCalculation()
        
        XCTAssertNotNil(route)
        XCTAssertFalse(route.id.isEmpty)
        XCTAssertTrue(route.distance > 0)
        XCTAssertTrue(route.estimatedTime > 0)
        XCTAssertTrue(route.waypoints.count > 0)
    }
    
    // MARK: - Social Features Tests
    
    func testMockSocialPlan() {
        let plan = mockAPIService.mockSocialPlan()
        
        XCTAssertNotNil(plan)
        XCTAssertFalse(plan.id.isEmpty)
        XCTAssertFalse(plan.title.isEmpty)
        XCTAssertFalse(plan.description.isEmpty)
        XCTAssertNotNil(plan.createdAt)
        XCTAssertNotNil(plan.updatedAt)
        XCTAssertTrue(plan.participants.count > 0)
        XCTAssertTrue(plan.options.count > 0)
    }
    
    func testMockSocialPlanList() {
        let plans = mockAPIService.mockSocialPlanList()
        
        XCTAssertNotNil(plans)
        XCTAssertTrue(plans.count > 0)
        XCTAssertTrue(plans.count <= 10)
        
        for plan in plans {
            XCTAssertFalse(plan.id.isEmpty)
            XCTAssertFalse(plan.title.isEmpty)
        }
    }
    
    func testMockSocialPlanCreation() {
        let newPlan = mockAPIService.mockSocialPlanCreation()
        
        XCTAssertNotNil(newPlan)
        XCTAssertFalse(newPlan.id.isEmpty)
        XCTAssertFalse(newPlan.title.isEmpty)
        XCTAssertNotNil(newPlan.createdAt)
    }
    
    // MARK: - Error Tests
    
    func testMockNetworkError() {
        let error = mockAPIService.mockNetworkError()
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.code, "NETWORK_ERROR")
        XCTAssertFalse(error.message.isEmpty)
    }
    
    func testMockValidationError() {
        let error = mockAPIService.mockValidationError()
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.code, "VALIDATION_ERROR")
        XCTAssertFalse(error.message.isEmpty)
    }
    
    func testMockServerError() {
        let error = mockAPIService.mockServerError()
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.code, "SERVER_ERROR")
        XCTAssertFalse(error.message.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testMockPerformanceMetrics() {
        let metrics = mockAPIService.mockPerformanceMetrics()
        
        XCTAssertNotNil(metrics)
        XCTAssertTrue(metrics.responseTime > 0)
        XCTAssertTrue(metrics.responseTime < 1000) // Should be under 1 second
        XCTAssertTrue(metrics.memoryUsage > 0)
        XCTAssertTrue(metrics.cpuUsage >= 0)
        XCTAssertTrue(metrics.cpuUsage <= 100)
    }
    
    // MARK: - Data Consistency Tests
    
    func testDataConsistency() {
        // Test that mock data is consistent
        let profile = mockAPIService.mockUserProfile()
        let adventure = mockAPIService.mockAdventure()
        
        // User ID should be consistent
        XCTAssertEqual(profile.id, adventure.createdBy)
        
        // Adventure should have valid stops
        for stop in adventure.stops {
            XCTAssertFalse(stop.id.isEmpty)
            XCTAssertFalse(stop.name.isEmpty)
            XCTAssertNotNil(stop.coordinate)
        }
    }
    
    func testMockDataUniqueness() {
        // Test that multiple calls return different data
        let profile1 = mockAPIService.mockUserProfile()
        let profile2 = mockAPIService.mockUserProfile()
        
        // Should have different IDs
        XCTAssertNotEqual(profile1.id, profile2.id)
        
        let adventure1 = mockAPIService.mockAdventure()
        let adventure2 = mockAPIService.mockAdventure()
        
        // Should have different IDs
        XCTAssertNotEqual(adventure1.id, adventure2.id)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyDataHandling() {
        // Test that empty data is handled gracefully
        let emptyList: [Adventure] = []
        XCTAssertTrue(emptyList.isEmpty)
        
        let emptyPlans: [Plan] = []
        XCTAssertTrue(emptyPlans.isEmpty)
    }
    
    func testNilDataHandling() {
        // Test that nil data is handled gracefully
        let auth = mockAPIService.mockAuthenticationFailure()
        XCTAssertNil(auth.user)
        XCTAssertNil(auth.session)
        XCTAssertNotNil(auth.error)
    }
    
    // MARK: - Mock Data Validation
    
    func testMockDataValidation() {
        let profile = mockAPIService.mockUserProfile()
        
        // Validate email format
        XCTAssertTrue(profile.email.contains("@"))
        XCTAssertTrue(profile.email.contains("."))
        
        // Validate display name
        XCTAssertTrue(profile.displayName.count > 0)
        XCTAssertTrue(profile.displayName.count < 100)
        
        // Validate dates
        XCTAssertTrue(profile.createdAt! < Date())
        XCTAssertTrue(profile.updatedAt! >= profile.createdAt!)
    }
    
    func testMockAdventureValidation() {
        let adventure = mockAPIService.mockAdventure()
        
        // Validate adventure data
        XCTAssertTrue(adventure.title.count > 0)
        XCTAssertTrue(adventure.title.count < 200)
        XCTAssertTrue(adventure.description.count > 0)
        XCTAssertTrue(adventure.description.count < 1000)
        
        // Validate stops
        for stop in adventure.stops {
            XCTAssertTrue(stop.name.count > 0)
            XCTAssertTrue(stop.name.count < 100)
        }
    }
}
