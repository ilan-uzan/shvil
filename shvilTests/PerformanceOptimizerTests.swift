//
//  PerformanceOptimizerTests.swift
//  shvilTests
//
//  Created by ilan on 2024.
//

import XCTest
@testable import shvil

@MainActor
final class PerformanceOptimizerTests: XCTestCase {
    var performanceOptimizer: PerformanceOptimizer!
    
    override func setUp() {
        super.setUp()
        performanceOptimizer = PerformanceOptimizer.shared
    }
    
    override func tearDown() {
        performanceOptimizer.stopMonitoring()
        super.tearDown()
    }
    
    func testPerformanceOptimizerInitialization() {
        XCTAssertNotNil(performanceOptimizer)
        XCTAssertFalse(performanceOptimizer.isOptimizing)
        XCTAssertEqual(performanceOptimizer.memoryUsage, 0)
        XCTAssertEqual(performanceOptimizer.cpuUsage, 0.0)
        XCTAssertEqual(performanceOptimizer.frameRate, 60.0)
    }
    
    func testPerformanceMonitoring() {
        performanceOptimizer.startMonitoring()
        XCTAssertTrue(performanceOptimizer.isOptimizing)
        
        // Wait a bit for monitoring to start
        let expectation = XCTestExpectation(description: "Performance monitoring started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        performanceOptimizer.stopMonitoring()
        XCTAssertFalse(performanceOptimizer.isOptimizing)
    }
    
    func testMemoryUsageMonitoring() {
        performanceOptimizer.startMonitoring()
        
        // Wait for memory usage to be calculated
        let expectation = XCTestExpectation(description: "Memory usage calculated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // Memory usage should be greater than 0
        XCTAssertGreaterThan(performanceOptimizer.memoryUsage, 0)
        
        performanceOptimizer.stopMonitoring()
    }
    
    func testFrameRateMonitoring() {
        performanceOptimizer.startMonitoring()
        
        // Wait for frame rate to be calculated
        let expectation = XCTestExpectation(description: "Frame rate calculated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // Frame rate should be reasonable (between 30 and 120 fps)
        XCTAssertGreaterThan(performanceOptimizer.frameRate, 30.0)
        XCTAssertLessThan(performanceOptimizer.frameRate, 120.0)
        
        performanceOptimizer.stopMonitoring()
    }
}
