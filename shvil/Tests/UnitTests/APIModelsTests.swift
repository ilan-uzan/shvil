//
//  APIModelsTests.swift
//  shvil
//
//  Created by ilan on 2024.
//

/*
import XCTest
@testable import shvil

final class APIModelsTests: XCTestCase {
    
    // MARK: - Authentication Models Tests
    
    func testAuthenticationResponse() {
        let user = User(
            id: "test-id",
            email: "test@example.com",
            displayName: "Test User",
            avatarURL: "https://example.com/avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let session = Session(
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        let authResponse = AuthenticationResponse(
            user: user,
            session: session,
            isSuccess: true,
            error: nil
        )
        
        XCTAssertNotNil(authResponse)
        XCTAssertTrue(authResponse.isSuccess)
        XCTAssertNotNil(authResponse.user)
        XCTAssertNotNil(authResponse.session)
        XCTAssertNil(authResponse.error)
    }
    
    func testAuthenticationResponseFailure() {
        let error = APIError(
            code: "AUTH_FAILED",
            message: "Authentication failed",
            details: "Invalid credentials"
        )
        
        let authResponse = AuthenticationResponse(
            user: nil,
            session: nil,
            isSuccess: false,
            error: error
        )
        
        XCTAssertNotNil(authResponse)
        XCTAssertFalse(authResponse.isSuccess)
        XCTAssertNil(authResponse.user)
        XCTAssertNil(authResponse.session)
        XCTAssertNotNil(authResponse.error)
    }
    
    // MARK: - User Model Tests
    
    func testUserModel() {
        let user = User(
            id: "test-id",
            email: "test@example.com",
            displayName: "Test User",
            avatarURL: "https://example.com/avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(user.id, "test-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "Test User")
        XCTAssertEqual(user.avatarURL, "https://example.com/avatar.jpg")
        XCTAssertNotNil(user.createdAt)
        XCTAssertNotNil(user.updatedAt)
    }
    
    func testUserModelCodable() throws {
        let user = User(
            id: "test-id",
            email: "test@example.com",
            displayName: "Test User",
            avatarURL: "https://example.com/avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let data = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: data)
        
        XCTAssertEqual(user.id, decoded.id)
        XCTAssertEqual(user.email, decoded.email)
        XCTAssertEqual(user.displayName, decoded.displayName)
        XCTAssertEqual(user.avatarURL, decoded.avatarURL)
    }
    
    // MARK: - Session Model Tests
    
    func testSessionModel() {
        let session = Session(
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        XCTAssertEqual(session.accessToken, "test-token")
        XCTAssertEqual(session.refreshToken, "test-refresh")
        XCTAssertNotNil(session.expiresAt)
    }
    
    func testSessionModelCodable() throws {
        let session = Session(
            accessToken: "test-token",
            refreshToken: "test-refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(Session.self, from: data)
        
        XCTAssertEqual(session.accessToken, decoded.accessToken)
        XCTAssertEqual(session.refreshToken, decoded.refreshToken)
    }
    
    // MARK: - API Error Tests
    
    func testAPIError() {
        let error = APIError(
            code: "TEST_ERROR",
            message: "Test error message",
            details: "Test error details"
        )
        
        XCTAssertEqual(error.code, "TEST_ERROR")
        XCTAssertEqual(error.message, "Test error message")
        XCTAssertEqual(error.details, "Test error details")
    }
    
    func testAPIErrorCodable() throws {
        let error = APIError(
            code: "TEST_ERROR",
            message: "Test error message",
            details: "Test error details"
        )
        
        let data = try JSONEncoder().encode(error)
        let decoded = try JSONDecoder().decode(APIError.self, from: data)
        
        XCTAssertEqual(error.code, decoded.code)
        XCTAssertEqual(error.message, decoded.message)
        XCTAssertEqual(error.details, decoded.details)
    }
    
    // MARK: - Search Models Tests
    
    func testSearchResult() {
        let result = SearchResult(
            name: "Test Location",
            address: "123 Test St",
            latitude: 37.7749,
            longitude: -122.4194,
            category: "restaurant",
            rating: 4.5,
            distance: 1.2,
            isOpen: true
        )
        
        XCTAssertEqual(result.name, "Test Location")
        XCTAssertEqual(result.address, "123 Test St")
        XCTAssertEqual(result.latitude, 37.7749)
        XCTAssertEqual(result.longitude, -122.4194)
        XCTAssertEqual(result.category, "restaurant")
        XCTAssertEqual(result.rating, 4.5)
        XCTAssertEqual(result.distance, 1.2)
        XCTAssertEqual(result.isOpen, true)
    }
    
    func testSearchSuggestion() {
        let suggestion = SearchSuggestion(
            text: "Coffee Shop",
            type: .place,
            confidence: 0.95
        )
        
        XCTAssertEqual(suggestion.text, "Coffee Shop")
        XCTAssertEqual(suggestion.type, .place)
        XCTAssertEqual(suggestion.confidence, 0.95)
    }
    
    // MARK: - Adventure Models Tests
    
    func testAdventureStop() {
        let location = LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            address: "123 Test St"
        )
        
        let stop = AdventureStop(
            name: "Test Stop",
            description: "A test stop",
            location: location,
            category: .food,
            order: 1,
            estimatedDuration: 3600,
            isCompleted: false
        )
        
        XCTAssertEqual(stop.name, "Test Stop")
        XCTAssertEqual(stop.description, "A test stop")
        XCTAssertEqual(stop.location.latitude, 37.7749)
        XCTAssertEqual(stop.location.longitude, -122.4194)
        XCTAssertEqual(stop.category, .food)
        XCTAssertEqual(stop.order, 1)
        XCTAssertEqual(stop.estimatedDuration, 3600)
        XCTAssertEqual(stop.isCompleted, false)
    }
    
    func testLocationData() {
        let location = LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            address: "123 Test St"
        )
        
        XCTAssertEqual(location.latitude, 37.7749)
        XCTAssertEqual(location.longitude, -122.4194)
        XCTAssertEqual(location.address, "123 Test St")
    }
    
    // MARK: - Enum Tests
    
    func testStopCategory() {
        XCTAssertEqual(StopCategory.food.rawValue, "food")
        XCTAssertEqual(StopCategory.museum.rawValue, "museum")
        XCTAssertEqual(StopCategory.park.rawValue, "park")
        XCTAssertEqual(StopCategory.shop.rawValue, "shop")
        XCTAssertEqual(StopCategory.entertainment.rawValue, "entertainment")
    }
    
    func testPriceLevel() {
        XCTAssertEqual(PriceLevel.free.rawValue, "free")
        XCTAssertEqual(PriceLevel.low.rawValue, "low")
        XCTAssertEqual(PriceLevel.medium.rawValue, "medium")
        XCTAssertEqual(PriceLevel.high.rawValue, "high")
        XCTAssertEqual(PriceLevel.expensive.rawValue, "expensive")
    }
    
    func testAdventureMood() {
        XCTAssertEqual(AdventureMood.fun.rawValue, "fun")
        XCTAssertEqual(AdventureMood.relaxed.rawValue, "relaxed")
        XCTAssertEqual(AdventureMood.adventurous.rawValue, "adventurous")
        XCTAssertEqual(AdventureMood.cultural.rawValue, "cultural")
        XCTAssertEqual(AdventureMood.romantic.rawValue, "romantic")
    }
    
    // MARK: - Performance Tests
    
    func testLargeDatasetEncoding() throws {
        var results: [SearchResult] = []
        
        for i in 0..<1000 {
            let result = SearchResult(
                name: "Location \(i)",
                address: "Address \(i)",
                latitude: Double(i),
                longitude: Double(i)
            )
            results.append(result)
        }
        
        let data = try JSONEncoder().encode(results)
        XCTAssertFalse(data.isEmpty)
    }
    
    func testLargeDatasetDecoding() throws {
        var results: [SearchResult] = []
        
        for i in 0..<1000 {
            let result = SearchResult(
                name: "Location \(i)",
                address: "Address \(i)",
                latitude: Double(i),
                longitude: Double(i)
            )
            results.append(result)
        }
        
        let data = try JSONEncoder().encode(results)
        let decoded = try JSONDecoder().decode([SearchResult].self, from: data)
        
        XCTAssertEqual(results.count, decoded.count)
    }
}
*/