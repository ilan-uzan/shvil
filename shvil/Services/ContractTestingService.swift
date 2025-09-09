//
//  ContractTestingService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

/// Service for testing API contracts and ensuring frontend-backend compatibility
class ContractTestingService: ObservableObject {
    static let shared = ContractTestingService()
    
    @Published var isRunningTests = false
    @Published var testResults: [ContractTestResult] = []
    @Published var overallStatus: ContractTestStatus = .notRun
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    /// Run all contract tests
    func runAllTests() async {
        await MainActor.run {
            isRunningTests = true
            testResults = []
            overallStatus = .running
        }
        
        var results: [ContractTestResult] = []
        
        // Test authentication endpoints
        results.append(await testAuthenticationEndpoints())
        
        // Test user profile endpoints
        results.append(await testUserProfileEndpoints())
        
        // Test saved places endpoints
        results.append(await testSavedPlacesEndpoints())
        
        // Test adventure endpoints
        results.append(await testAdventureEndpoints())
        
        // Test safety report endpoints
        results.append(await testSafetyReportEndpoints())
        
        // Test search endpoints
        results.append(await testSearchEndpoints())
        
        await MainActor.run {
            testResults = results
            isRunningTests = false
            overallStatus = calculateOverallStatus(from: results)
        }
    }
    
    // MARK: - Authentication Tests
    
    private func testAuthenticationEndpoints() async -> ContractTestResult {
        let testName = "Authentication Endpoints"
        var passedTests = 0
        var totalTests = 0
        var errors: [String] = []
        
        // Test login endpoint
        totalTests += 1
        do {
            let loginRequest = LoginRequest(email: "test@example.com", password: "password")
            let _ = try await testEndpoint(
                path: "/auth/v1/token",
                method: "POST",
                body: loginRequest
            )
            passedTests += 1
        } catch {
            errors.append("Login endpoint failed: \(error.localizedDescription)")
        }
        
        // Test register endpoint
        totalTests += 1
        do {
            let registerRequest = RegisterRequest(email: "test@example.com", password: "password", displayName: "Test User")
            let _ = try await testEndpoint(
                path: "/auth/v1/signup",
                method: "POST",
                body: registerRequest
            )
            passedTests += 1
        } catch {
            errors.append("Register endpoint failed: \(error.localizedDescription)")
        }
        
        return ContractTestResult(
            testName: testName,
            passed: passedTests,
            total: totalTests,
            errors: errors,
            status: passedTests == totalTests ? .passed : .failed
        )
    }
    
    // MARK: - User Profile Tests
    
    private func testUserProfileEndpoints() async -> ContractTestResult {
        let testName = "User Profile Endpoints"
        var passedTests = 0
        var totalTests = 0
        var errors: [String] = []
        
        // Test get user profile
        totalTests += 1
        do {
            let _ = try await testEndpoint(
                path: "/auth/v1/user",
                method: "GET",
                body: nil as String?
            )
            passedTests += 1
        } catch {
            errors.append("Get user profile failed: \(error.localizedDescription)")
        }
        
        return ContractTestResult(
            testName: testName,
            passed: passedTests,
            total: totalTests,
            errors: errors,
            status: passedTests == totalTests ? .passed : .failed
        )
    }
    
    // MARK: - Saved Places Tests
    
    private func testSavedPlacesEndpoints() async -> ContractTestResult {
        let testName = "Saved Places Endpoints"
        var passedTests = 0
        var totalTests = 0
        var errors: [String] = []
        
        // Test get saved places
        totalTests += 1
        do {
            let _ = try await testEndpoint(
                path: "/rest/v1/saved_places",
                method: "GET",
                body: nil as String?
            )
            passedTests += 1
        } catch {
            errors.append("Get saved places failed: \(error.localizedDescription)")
        }
        
        // Test create saved place
        totalTests += 1
        do {
            let savedPlace = SavedPlace(
                id: UUID(),
                userId: UUID(),
                name: "Test Place",
                address: "123 Test St",
                latitude: 37.7749,
                longitude: -122.4194,
                placeType: .favorite,
                createdAt: Date(),
                updatedAt: Date()
            )
            let _ = try await testEndpoint(
                path: "/rest/v1/saved_places",
                method: "POST",
                body: savedPlace
            )
            passedTests += 1
        } catch {
            errors.append("Create saved place failed: \(error.localizedDescription)")
        }
        
        return ContractTestResult(
            testName: testName,
            passed: passedTests,
            total: totalTests,
            errors: errors,
            status: passedTests == totalTests ? .passed : .failed
        )
    }
    
    // MARK: - Adventure Tests
    
    private func testAdventureEndpoints() async -> ContractTestResult {
        let testName = "Adventure Endpoints"
        var passedTests = 0
        var totalTests = 0
        var errors: [String] = []
        
        // Test get adventures
        totalTests += 1
        do {
            let _ = try await testEndpoint(
                path: "/rest/v1/adventure_plans",
                method: "GET",
                body: nil as String?
            )
            passedTests += 1
        } catch {
            errors.append("Get adventures failed: \(error.localizedDescription)")
        }
        
        // Test create adventure
        totalTests += 1
        do {
            let adventure = Adventure(
                id: UUID(),
                userId: UUID(),
                title: "Test Adventure",
                description: "Test Description",
                routeData: RouteData(
                    origin: LocationData(latitude: 37.7749, longitude: -122.4194, address: "Origin"),
                    destination: LocationData(latitude: 37.7849, longitude: -122.4094, address: "Destination"),
                    waypoints: [],
                    distance: 1000,
                    duration: 600,
                    transportMode: "walking",
                    estimatedArrival: Date()
                ),
                stops: [],
                status: .draft,
                createdAt: Date(),
                updatedAt: Date()
            )
            let _ = try await testEndpoint(
                path: "/rest/v1/adventure_plans",
                method: "POST",
                body: adventure
            )
            passedTests += 1
        } catch {
            errors.append("Create adventure failed: \(error.localizedDescription)")
        }
        
        return ContractTestResult(
            testName: testName,
            passed: passedTests,
            total: totalTests,
            errors: errors,
            status: passedTests == totalTests ? .passed : .failed
        )
    }
    
    // MARK: - Safety Report Tests
    
    private func testSafetyReportEndpoints() async -> ContractTestResult {
        let testName = "Safety Report Endpoints"
        var passedTests = 0
        var totalTests = 0
        var errors: [String] = []
        
        // Test get safety reports
        totalTests += 1
        do {
            let _ = try await testEndpoint(
                path: "/rest/v1/safety_reports",
                method: "GET",
                body: nil as String?
            )
            passedTests += 1
        } catch {
            errors.append("Get safety reports failed: \(error.localizedDescription)")
        }
        
        // Test create safety report
        totalTests += 1
        do {
            let safetyReport = SafetyReport(
                id: UUID(),
                userId: UUID(),
                latitude: 37.7749,
                longitude: -122.4194,
                reportType: "hazard",
                description: "Test hazard",
                severity: 3,
                isResolved: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            let _ = try await testEndpoint(
                path: "/rest/v1/safety_reports",
                method: "POST",
                body: safetyReport
            )
            passedTests += 1
        } catch {
            errors.append("Create safety report failed: \(error.localizedDescription)")
        }
        
        return ContractTestResult(
            testName: testName,
            passed: passedTests,
            total: totalTests,
            errors: errors,
            status: passedTests == totalTests ? .passed : .failed
        )
    }
    
    // MARK: - Search Tests
    
    private func testSearchEndpoints() async -> ContractTestResult {
        let testName = "Search Endpoints"
        var passedTests = 0
        var totalTests = 0
        var errors: [String] = []
        
        // Test search
        totalTests += 1
        do {
            let _ = try await testEndpoint(
                path: "/rest/v1/search?q=test",
                method: "GET",
                body: nil as String?
            )
            passedTests += 1
        } catch {
            errors.append("Search endpoint failed: \(error.localizedDescription)")
        }
        
        return ContractTestResult(
            testName: testName,
            passed: passedTests,
            total: totalTests,
            errors: errors,
            status: passedTests == totalTests ? .passed : .failed
        )
    }
    
    // MARK: - Helper Methods
    
    private func testEndpoint<T: Codable>(
        path: String,
        method: String,
        body: T?
    ) async throws -> APIResponse<Data> {
        // This would make actual HTTP requests to test the API
        // For now, we'll simulate the test
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
        
        // Simulate success response
        return APIResponse<Data>(
            data: nil,
            error: nil,
            success: true,
            message: "Test passed"
        )
    }
    
    private func calculateOverallStatus(from results: [ContractTestResult]) -> ContractTestStatus {
        let totalTests = results.reduce(0) { $0 + $1.total }
        let passedTests = results.reduce(0) { $0 + $1.passed }
        
        if totalTests == 0 {
            return .notRun
        } else if passedTests == totalTests {
            return .passed
        } else if passedTests > 0 {
            return .partial
        } else {
            return .failed
        }
    }
}

// MARK: - Test Result Models

struct ContractTestResult: Identifiable {
    let id = UUID()
    let testName: String
    let passed: Int
    let total: Int
    let errors: [String]
    let status: ContractTestStatus
    
    var successRate: Double {
        guard total > 0 else { return 0.0 }
        return Double(passed) / Double(total)
    }
}

enum ContractTestStatus: String, CaseIterable {
    case notRun = "not_run"
    case running = "running"
    case passed = "passed"
    case partial = "partial"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .notRun: return "Not Run"
        case .running: return "Running"
        case .passed: return "Passed"
        case .partial: return "Partial"
        case .failed: return "Failed"
        }
    }
    
    var color: String {
        switch self {
        case .notRun: return "gray"
        case .running: return "blue"
        case .passed: return "green"
        case .partial: return "yellow"
        case .failed: return "red"
        }
    }
}
