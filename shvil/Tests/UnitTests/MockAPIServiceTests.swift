//
//  MockAPIServiceTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

/*
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
    }
    
    func testMockAuthenticationFailure() {
        let auth = mockAPIService.mockAuthenticationFailure()
        
        XCTAssertNotNil(auth)
        XCTAssertFalse(auth.isSuccess)
        XCTAssertNotNil(auth.error)
    }
    
    // MARK: - User Profile Tests
    
    func testMockUserProfile() {
        let profile = mockAPIService.mockUserProfile()
        
        XCTAssertNotNil(profile)
        XCTAssertFalse(profile.displayName.isEmpty)
        XCTAssertNotNil(profile.email)
        XCTAssertNotNil(profile.avatarURL)
    }
    
    func testMockUserProfileUpdate() {
        let profile = mockAPIService.mockUserProfile()
        let updatedProfile = mockAPIService.mockUserProfileUpdate(profile)
        
        XCTAssertNotNil(updatedProfile)
        XCTAssertEqual(updatedProfile.id, profile.id)
        XCTAssertNotEqual(updatedProfile.displayName, profile.displayName)
    }
    
    // MARK: - Adventure Tests
    
    func testMockAdventure() {
        let adventure = mockAPIService.mockAdventure()
        
        XCTAssertNotNil(adventure)
        XCTAssertFalse(adventure.title.isEmpty)
        XCTAssertFalse(adventure.description.isEmpty)
        XCTAssertFalse(adventure.stops.isEmpty)
    }
    
    func testMockAdventureStops() {
        let stops = mockAPIService.mockAdventureStops()
        
        XCTAssertFalse(stops.isEmpty)
        XCTAssertTrue(stops.count >= 3)
        
        for stop in stops {
            XCTAssertFalse(stop.name.isEmpty)
            XCTAssertNotNil(stop.location)
        }
    }
    
    func testMockAdventureCreation() {
        let adventure = mockAPIService.mockAdventureCreation()
        
        XCTAssertNotNil(adventure)
        XCTAssertFalse(adventure.title.isEmpty)
        XCTAssertNotNil(adventure.id)
    }
    
    // MARK: - Search Tests
    
    func testMockSearchResults() {
        let results = mockAPIService.mockSearchResults()
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.count >= 5)
        
        for result in results {
            XCTAssertFalse(result.name.isEmpty)
            XCTAssertNotNil(result.location)
        }
    }
    
    func testMockSearchSuggestions() {
        let suggestions = mockAPIService.mockSearchSuggestions()
        
        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertTrue(suggestions.count >= 3)
        
        for suggestion in suggestions {
            XCTAssertFalse(suggestion.text.isEmpty)
            XCTAssertNotNil(suggestion.type)
        }
    }
    
    // MARK: - Route Tests
    
    func testMockRoute() {
        let route = mockAPIService.mockRoute()
        
        XCTAssertNotNil(route)
        XCTAssertFalse(route.steps.isEmpty)
        XCTAssertTrue(route.distance > 0)
        XCTAssertTrue(route.duration > 0)
    }
    
    func testMockRouteCalculation() {
        let route = mockAPIService.mockRouteCalculation()
        
        XCTAssertNotNil(route)
        XCTAssertFalse(route.steps.isEmpty)
        XCTAssertTrue(route.distance > 0)
        XCTAssertTrue(route.duration > 0)
    }
    
    // MARK: - Social Tests
    
    func testMockSocialPlans() {
        let plans = mockAPIService.mockSocialPlans()
        
        XCTAssertFalse(plans.isEmpty)
        XCTAssertTrue(plans.count >= 3)
        
        for plan in plans {
            XCTAssertFalse(plan.title.isEmpty)
            XCTAssertNotNil(plan.creator)
        }
    }
    
    func testMockSocialPlanCreation() {
        let plan = mockAPIService.mockSocialPlanCreation()
        
        XCTAssertNotNil(plan)
        XCTAssertFalse(plan.title.isEmpty)
        XCTAssertNotNil(plan.id)
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
    
    // MARK: - Performance Tests
    
    func testMockPerformanceMetrics() {
        let metrics = mockAPIService.mockPerformanceMetrics()
        
        XCTAssertNotNil(metrics)
        XCTAssertTrue(metrics.responseTime > 0)
        XCTAssertTrue(metrics.memoryUsage > 0)
        XCTAssertTrue(metrics.cpuUsage > 0)
    }
    
    // MARK: - Data Validation Tests
    
    func testMockDataValidation() {
        let isValid = mockAPIService.mockDataValidation()
        
        XCTAssertTrue(isValid)
    }
    
    func testMockDataValidationFailure() {
        let isValid = mockAPIService.mockDataValidationFailure()
        
        XCTAssertFalse(isValid)
    }
    
    // MARK: - Edge Cases
    
    func testMockEmptyResults() {
        let results = mockAPIService.mockEmptyResults()
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func testMockLargeDataset() {
        let results = mockAPIService.mockLargeDataset()
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.count >= 100)
    }
    
    // MARK: - Async Operations
    
    func testMockAsyncOperation() async {
        let result = await mockAPIService.mockAsyncOperation()
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result.isSuccess)
    }
    
    func testMockAsyncOperationFailure() async {
        let result = await mockAPIService.mockAsyncOperationFailure()
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result.isSuccess)
    }
    
    // MARK: - Concurrent Operations
    
    func testMockConcurrentOperations() async {
        let results = await mockAPIService.mockConcurrentOperations()
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.count >= 3)
        
        for result in results {
            XCTAssertTrue(result.isSuccess)
        }
    }
    
    // MARK: - Timeout Tests
    
    func testMockTimeout() async {
        let result = await mockAPIService.mockTimeout()
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result.isSuccess)
        XCTAssertEqual(result.error?.code, "TIMEOUT")
    }
    
    // MARK: - Rate Limiting Tests
    
    func testMockRateLimit() async {
        let result = await mockAPIService.mockRateLimit()
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result.isSuccess)
        XCTAssertEqual(result.error?.code, "RATE_LIMIT")
    }
}
*/