//
//  CacheManagerTests.swift
//  shvilTests
//
//  Created by ilan on 2024.
//

import XCTest
@testable import shvil

@MainActor
final class CacheManagerTests: XCTestCase {
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
    }
    
    override func tearDown() {
        cacheManager.clearAllCaches()
        super.tearDown()
    }
    
    func testCacheManagerInitialization() {
        XCTAssertNotNil(cacheManager)
        XCTAssertEqual(cacheManager.memoryUsage, 0)
        XCTAssertEqual(cacheManager.diskUsage, 0)
        XCTAssertEqual(cacheManager.cacheHitRate, 0.0)
    }
    
    func testImageCaching() {
        let testImage = UIImage(systemName: "star")!
        let testKey = "test_image_key"
        
        // Cache the image
        cacheManager.cacheImage(testImage, forKey: testKey)
        
        // Retrieve the cached image
        let cachedImage = cacheManager.getCachedImage(forKey: testKey)
        
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(cachedImage?.size, testImage.size)
    }
    
    func testDataCaching() {
        let testData = "test data".data(using: .utf8)!
        let testKey = "test_data_key"
        
        // Cache the data
        cacheManager.cacheData(testData, forKey: testKey)
        
        // Retrieve the cached data
        let cachedData = cacheManager.getCachedData(forKey: testKey)
        
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, testData)
    }
    
    func testDataCachingWithExpiration() {
        let testData = "test data".data(using: .utf8)!
        let testKey = "test_data_key_expired"
        let shortExpiration: TimeInterval = 0.1 // 100ms
        
        // Cache the data with short expiration
        cacheManager.cacheData(testData, forKey: testKey, expirationTime: shortExpiration)
        
        // Retrieve immediately - should work
        let cachedData = cacheManager.getCachedData(forKey: testKey)
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, testData)
        
        // Wait for expiration
        let expectation = XCTestExpectation(description: "Data expired")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Retrieve after expiration - should be nil
        let expiredData = cacheManager.getCachedData(forKey: testKey)
        XCTAssertNil(expiredData)
    }
    
    func testComputedValueCaching() {
        let testValue = "test computed value" as NSString
        let testKey = "test_computed_key"
        
        // Cache the computed value
        cacheManager.cacheComputedValue(testValue, forKey: testKey)
        
        // Retrieve the cached value
        let cachedValue = cacheManager.getCachedComputedValue(forKey: testKey, type: NSString.self)
        
        XCTAssertNotNil(cachedValue)
        XCTAssertEqual(cachedValue, testValue)
    }
    
    func testDiskCaching() {
        let testData = "test disk data".data(using: .utf8)!
        let testKey = "test_disk_key"
        
        // Cache to disk
        cacheManager.cacheToDisk(testData, forKey: testKey)
        
        // Retrieve from disk
        let cachedData = cacheManager.getCachedDataFromDisk(forKey: testKey)
        
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, testData)
    }
    
    func testCacheRemoval() {
        let testImage = UIImage(systemName: "star")!
        let testKey = "test_removal_key"
        
        // Cache the image
        cacheManager.cacheImage(testImage, forKey: testKey)
        
        // Verify it's cached
        let cachedImage = cacheManager.getCachedImage(forKey: testKey)
        XCTAssertNotNil(cachedImage)
        
        // Remove from cache
        cacheManager.removeCachedImage(forKey: testKey)
        
        // Verify it's removed
        let removedImage = cacheManager.getCachedImage(forKey: testKey)
        XCTAssertNil(removedImage)
    }
    
    func testClearAllCaches() {
        let testImage = UIImage(systemName: "star")!
        let testData = "test data".data(using: .utf8)!
        
        // Cache some data
        cacheManager.cacheImage(testImage, forKey: "test_image")
        cacheManager.cacheData(testData, forKey: "test_data")
        
        // Verify data is cached
        XCTAssertNotNil(cacheManager.getCachedImage(forKey: "test_image"))
        XCTAssertNotNil(cacheManager.getCachedData(forKey: "test_data"))
        
        // Clear all caches
        cacheManager.clearAllCaches()
        
        // Verify all data is removed
        XCTAssertNil(cacheManager.getCachedImage(forKey: "test_image"))
        XCTAssertNil(cacheManager.getCachedData(forKey: "test_data"))
    }
    
    func testCacheStatistics() {
        let testImage = UIImage(systemName: "star")!
        let testKey = "test_stats_key"
        
        // Cache and retrieve to generate hits
        cacheManager.cacheImage(testImage, forKey: testKey)
        _ = cacheManager.getCachedImage(forKey: testKey)
        
        // Try to get non-existent data to generate misses
        _ = cacheManager.getCachedImage(forKey: "non_existent_key")
        
        // Wait for statistics to update
        let expectation = XCTestExpectation(description: "Statistics updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Cache hit rate should be calculated
        XCTAssertGreaterThanOrEqual(cacheManager.cacheHitRate, 0.0)
        XCTAssertLessThanOrEqual(cacheManager.cacheHitRate, 1.0)
    }
}
