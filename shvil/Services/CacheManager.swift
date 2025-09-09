//
//  CacheManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI
import Combine

/// High-performance caching system for images, data, and computed values
@MainActor
public class CacheManager: ObservableObject {
    // MARK: - Singleton
    
    public static let shared = CacheManager()
    
    // MARK: - Published Properties
    
    @Published public var memoryUsage: UInt64 = 0
    @Published public var diskUsage: UInt64 = 0
    @Published public var cacheHitRate: Double = 0.0
    
    // MARK: - Private Properties
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let dataCache = NSCache<NSString, CacheItem>()
    private let computedCache = NSCache<NSString, CacheItem>()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let imageCacheDirectory: URL
    private let dataCacheDirectory: URL
    
    private var cacheStats = CacheStats()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private let maxMemoryCacheSize: Int = 50 * 1024 * 1024 // 50MB
    private let maxDiskCacheSize: Int = 200 * 1024 * 1024 // 200MB
    private let defaultExpirationTime: TimeInterval = 3600 // 1 hour
    
    // MARK: - Initialization
    
    private init() {
        // Set up cache directories
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("Cache")
        imageCacheDirectory = cacheDirectory.appendingPathComponent("Images")
        dataCacheDirectory = cacheDirectory.appendingPathComponent("Data")
        
        createDirectoriesIfNeeded()
        setupCaches()
        startMonitoring()
    }
    
    // MARK: - Setup
    
    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: imageCacheDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: dataCacheDirectory, withIntermediateDirectories: true)
    }
    
    private func setupCaches() {
        // Configure image cache
        imageCache.countLimit = 100
        imageCache.totalCostLimit = maxMemoryCacheSize
        
        // Configure data cache
        dataCache.countLimit = 200
        dataCache.totalCostLimit = maxMemoryCacheSize / 2
        
        // Configure computed cache
        computedCache.countLimit = 500
        computedCache.totalCostLimit = maxMemoryCacheSize / 4
    }
    
    private func startMonitoring() {
        // Monitor memory usage
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCacheStats()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Image Caching
    
    public func cacheImage(_ image: UIImage, forKey key: String) {
        let nsKey = NSString(string: key)
        let cost = image.cgImage?.width ?? 0 * (image.cgImage?.height ?? 0) * 4
        imageCache.setObject(image, forKey: nsKey, cost: cost)
    }
    
    public func getCachedImage(forKey key: String) -> UIImage? {
        let nsKey = NSString(string: key)
        let image = imageCache.object(forKey: nsKey)
        
        if image != nil {
            cacheStats.hits += 1
        } else {
            cacheStats.misses += 1
        }
        
        return image
    }
    
    public func removeCachedImage(forKey key: String) {
        let nsKey = NSString(string: key)
        imageCache.removeObject(forKey: nsKey)
    }
    
    // MARK: - Data Caching
    
    public func cacheData(_ data: Data, forKey key: String, expirationTime: TimeInterval? = nil) {
        let nsKey = NSString(string: key)
        let cacheItem = CacheItem(
            data: NSData(data: data),
            expirationTime: expirationTime ?? defaultExpirationTime,
            createdAt: Date()
        )
        dataCache.setObject(cacheItem, forKey: nsKey)
    }
    
    public func getCachedData(forKey key: String) -> Data? {
        let nsKey = NSString(string: key)
        guard let cacheItem = dataCache.object(forKey: nsKey) else {
            cacheStats.misses += 1
            return nil
        }
        
        // Check expiration
        if Date().timeIntervalSince(cacheItem.createdAt) > cacheItem.expirationTime {
            dataCache.removeObject(forKey: nsKey)
            cacheStats.misses += 1
            return nil
        }
        
        cacheStats.hits += 1
        return cacheItem.data as? Data
    }
    
    public func removeCachedData(forKey key: String) {
        let nsKey = NSString(string: key)
        dataCache.removeObject(forKey: nsKey)
    }
    
    // MARK: - Computed Value Caching
    
    public func cacheComputedValue<T: AnyObject>(_ value: T, forKey key: String, expirationTime: TimeInterval? = nil) {
        let nsKey = NSString(string: key)
        let cacheItem = CacheItem(
            data: value,
            expirationTime: expirationTime ?? defaultExpirationTime,
            createdAt: Date()
        )
        computedCache.setObject(cacheItem, forKey: nsKey)
    }
    
    public func getCachedComputedValue<T: AnyObject>(forKey key: String, type: T.Type) -> T? {
        let nsKey = NSString(string: key)
        guard let cacheItem = computedCache.object(forKey: nsKey),
              let value = cacheItem.data as? T else {
            cacheStats.misses += 1
            return nil
        }
        
        // Check expiration
        if Date().timeIntervalSince(cacheItem.createdAt) > cacheItem.expirationTime {
            computedCache.removeObject(forKey: nsKey)
            cacheStats.misses += 1
            return nil
        }
        
        cacheStats.hits += 1
        return value
    }
    
    // MARK: - Disk Caching
    
    public func cacheToDisk(_ data: Data, forKey key: String) {
        let fileURL = dataCacheDirectory.appendingPathComponent(key)
        try? data.write(to: fileURL)
    }
    
    public func getCachedDataFromDisk(forKey key: String) -> Data? {
        let fileURL = dataCacheDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL)
    }
    
    public func removeCachedDataFromDisk(forKey key: String) {
        let fileURL = dataCacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Cache Management
    
    public func clearAllCaches() {
        imageCache.removeAllObjects()
        dataCache.removeAllObjects()
        computedCache.removeAllObjects()
        
        // Clear disk cache
        try? fileManager.removeItem(at: imageCacheDirectory)
        try? fileManager.removeItem(at: dataCacheDirectory)
        createDirectoriesIfNeeded()
    }
    
    public func clearExpiredCaches() {
        // This would require iterating through all cached items
        // For now, we'll clear all caches periodically
        clearAllCaches()
    }
    
    // MARK: - Statistics
    
    private func updateCacheStats() {
        memoryUsage = UInt64(imageCache.totalCostLimit + dataCache.totalCostLimit + computedCache.totalCostLimit)
        
        // Calculate disk usage
        diskUsage = calculateDiskUsage()
        
        // Calculate hit rate
        let totalRequests = cacheStats.hits + cacheStats.misses
        cacheHitRate = totalRequests > 0 ? Double(cacheStats.hits) / Double(totalRequests) : 0.0
    }
    
    private func calculateDiskUsage() -> UInt64 {
        var totalSize: UInt64 = 0
        
        if let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += UInt64(fileSize)
                }
            }
        }
        
        return totalSize
    }
}

// MARK: - Supporting Types

private class CacheItem {
    let data: AnyObject
    let expirationTime: TimeInterval
    let createdAt: Date
    
    init(data: AnyObject, expirationTime: TimeInterval, createdAt: Date) {
        self.data = data
        self.expirationTime = expirationTime
        self.createdAt = createdAt
    }
}

private struct CacheStats {
    var hits: Int = 0
    var misses: Int = 0
}

// MARK: - View Extensions

extension View {
    /// Cache view for performance
    public func cached() -> some View {
        self
            .drawingGroup() // Rasterize for caching
    }
    
    /// Lazy load with caching
    public func lazyCached<Content: View>(
        key: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        LazyCachedView(key: key, content: content)
    }
}

// MARK: - Lazy Cached View

private struct LazyCachedView<Content: View>: View {
    let key: String
    let content: () -> Content
    
    @State private var cachedView: AnyView?
    
    var body: some View {
        Group {
            if let cachedView = cachedView {
                cachedView
            } else {
                content()
                    .onAppear {
                        cachedView = AnyView(content())
                    }
            }
        }
    }
}
