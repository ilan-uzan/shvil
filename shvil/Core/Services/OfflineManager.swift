//
//  OfflineManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import MapKit

/// Manages offline map tiles and data caching
@MainActor
public class OfflineManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var isOfflineMode = false
    @Published public var downloadedRegions: [DownloadRegion] = []
    @Published public var isDownloading = false
    @Published public var downloadProgress: Double = 0.0
    @Published public var storageUsed: Int64 = 0
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let tilesDirectory: URL
    private let dataDirectory: URL
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private let maxCacheSize: Int64 = 500 * 1024 * 1024 // 500MB
    private let tileSize: Int64 = 50 * 1024 // 50KB per tile
    private let maxTilesPerRegion = 1000
    
    // MARK: - Initialization
    
    public init() {
        // Set up cache directories
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("OfflineCache")
        tilesDirectory = cacheDirectory.appendingPathComponent("Tiles")
        dataDirectory = cacheDirectory.appendingPathComponent("Data")
        
        createDirectoriesIfNeeded()
        loadDownloadedRegions()
        calculateStorageUsed()
        
        // Monitor network connectivity
        setupNetworkMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Download a region for offline use
    public func downloadRegion(
        center: CLLocationCoordinate2D,
        radius: Double,
        name: String,
        completion: @escaping (Result<DownloadRegion, Error>) -> Void
    ) {
        let region = DownloadRegion(
            id: UUID(),
            name: name,
            center: center,
            radius: radius,
            status: .downloading,
            downloadedAt: Date(),
            size: 0
        )
        
        downloadedRegions.append(region)
        isDownloading = true
        downloadProgress = 0.0
        
        Task {
            do {
                let downloadedRegion = try await performRegionDownload(region)
                await MainActor.run {
                    self.updateRegionStatus(downloadedRegion, status: .completed)
                    self.isDownloading = false
                    self.downloadProgress = 1.0
                    self.calculateStorageUsed()
                    completion(.success(downloadedRegion))
                }
            } catch {
                await MainActor.run {
                    self.updateRegionStatus(region, status: .failed)
                    self.isDownloading = false
                    self.error = error
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Delete a downloaded region
    public func deleteRegion(_ region: DownloadRegion) {
        // Remove tiles for this region
        let regionTilesDirectory = tilesDirectory.appendingPathComponent(region.id.uuidString)
        try? fileManager.removeItem(at: regionTilesDirectory)
        
        // Remove data for this region
        let regionDataFile = dataDirectory.appendingPathComponent("\(region.id.uuidString).json")
        try? fileManager.removeItem(at: regionDataFile)
        
        // Remove from list
        downloadedRegions.removeAll { $0.id == region.id }
        calculateStorageUsed()
    }
    
    /// Clear all offline data
    public func clearAllOfflineData() {
        // Remove all tiles
        try? fileManager.removeItem(at: tilesDirectory)
        try? fileManager.createDirectory(at: tilesDirectory, withIntermediateDirectories: true)
        
        // Remove all data
        try? fileManager.removeItem(at: dataDirectory)
        try? fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
        
        // Clear regions list
        downloadedRegions.removeAll()
        calculateStorageUsed()
    }
    
    /// Check if a location is covered by offline data
    public func isLocationOfflineAvailable(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return downloadedRegions.contains { region in
            let regionCenter = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            return location.distance(from: regionCenter) <= region.radius
        }
    }
    
    /// Get offline tile for coordinate and zoom level
    public func getOfflineTile(for coordinate: CLLocationCoordinate2D, zoomLevel: Int) -> Data? {
        // Find the region that contains this coordinate
        guard let region = downloadedRegions.first(where: { region in
            let regionCenter = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return location.distance(from: regionCenter) <= region.radius
        }) else { return nil }
        
        // Calculate tile coordinates
        let tileX = Int(floor((coordinate.longitude + 180.0) / 360.0 * pow(2.0, Double(zoomLevel))))
        let tileY = Int(floor((1.0 - log(tan(coordinate.latitude * .pi / 180.0) + 1.0 / cos(coordinate.latitude * .pi / 180.0)) / .pi) / 2.0 * pow(2.0, Double(zoomLevel))))
        
        let tilePath = tilesDirectory
            .appendingPathComponent(region.id.uuidString)
            .appendingPathComponent("\(zoomLevel)")
            .appendingPathComponent("\(tileX)")
            .appendingPathComponent("\(tileY).png")
        
        return try? Data(contentsOf: tilePath)
    }
    
    /// Cache search results for offline use
    public func cacheSearchResults(_ results: [SearchResult], for query: String) {
        let cacheData = SearchCache(
            query: query,
            results: results,
            timestamp: Date()
        )
        
        let cacheFile = dataDirectory.appendingPathComponent("search_\(query.hashValue).json")
        
        do {
            let data = try JSONEncoder().encode(cacheData)
            try data.write(to: cacheFile)
        } catch {
            print("Failed to cache search results: \(error)")
        }
    }
    
    /// Get cached search results
    public func getCachedSearchResults(for query: String) -> [SearchResult]? {
        let cacheFile = dataDirectory.appendingPathComponent("search_\(query.hashValue).json")
        
        guard let data = try? Data(contentsOf: cacheFile) else { return nil }
        
        do {
            let cache = try JSONDecoder().decode(SearchCache.self, from: data)
            
            // Check if cache is still valid (24 hours)
            let cacheAge = Date().timeIntervalSince(cache.timestamp)
            if cacheAge < 86400 {
                return cache.results
            } else {
                // Remove expired cache
                try? fileManager.removeItem(at: cacheFile)
                return nil
            }
        } catch {
            return nil
        }
    }
    
    /// Cache route for offline use
    public func cacheRoute(_ route: Route) {
        let routeData = RouteCache(
            route: route,
            timestamp: Date()
        )
        
        let cacheFile = dataDirectory.appendingPathComponent("route_\(route.id.uuidString).json")
        
        do {
            let data = try JSONEncoder().encode(routeData)
            try data.write(to: cacheFile)
        } catch {
            print("Failed to cache route: \(error)")
        }
    }
    
    /// Get cached route
    public func getCachedRoute(id: UUID) -> Route? {
        let cacheFile = dataDirectory.appendingPathComponent("route_\(id.uuidString).json")
        
        guard let data = try? Data(contentsOf: cacheFile) else { return nil }
        
        do {
            let cache = try JSONDecoder().decode(RouteCache.self, from: data)
            
            // Check if cache is still valid (7 days for routes)
            let cacheAge = Date().timeIntervalSince(cache.timestamp)
            if cacheAge < 604800 {
                return cache.route
            } else {
                // Remove expired cache
                try? fileManager.removeItem(at: cacheFile)
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: tilesDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
    }
    
    private func loadDownloadedRegions() {
        let regionsFile = dataDirectory.appendingPathComponent("regions.json")
        
        guard let data = try? Data(contentsOf: regionsFile) else { return }
        
        do {
            downloadedRegions = try JSONDecoder().decode([DownloadRegion].self, from: data)
        } catch {
            print("Failed to load downloaded regions: \(error)")
        }
    }
    
    private func saveDownloadedRegions() {
        let regionsFile = dataDirectory.appendingPathComponent("regions.json")
        
        do {
            let data = try JSONEncoder().encode(downloadedRegions)
            try data.write(to: regionsFile)
        } catch {
            print("Failed to save downloaded regions: \(error)")
        }
    }
    
    private func calculateStorageUsed() {
        var totalSize: Int64 = 0
        
        // Calculate tiles size
        if let enumerator = fileManager.enumerator(at: tilesDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        // Calculate data size
        if let enumerator = fileManager.enumerator(at: dataDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        storageUsed = totalSize
    }
    
    private func setupNetworkMonitoring() {
        NotificationCenter.default.publisher(for: .networkStatusChanged)
            .sink { [weak self] notification in
                if let isConnected = notification.object as? Bool {
                    self?.isOfflineMode = !isConnected
                }
            }
            .store(in: &cancellables)
    }
    
    private func performRegionDownload(_ region: DownloadRegion) async throws -> DownloadRegion {
        // This is a simplified implementation
        // In a real app, you'd download actual map tiles from a tile server
        
        let regionTilesDirectory = tilesDirectory.appendingPathComponent(region.id.uuidString)
        try fileManager.createDirectory(at: regionTilesDirectory, withIntermediateDirectories: true)
        
        // Simulate tile download
        let totalTiles = min(maxTilesPerRegion, Int(region.radius / 1000) * 10) // Estimate tiles needed
        
        for i in 0..<totalTiles {
            // Simulate download progress
            await MainActor.run {
                self.downloadProgress = Double(i) / Double(totalTiles)
            }
            
            // Simulate tile download delay
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Create a placeholder tile (in real implementation, download from server)
            let tileData = createPlaceholderTile()
            let tilePath = regionTilesDirectory
                .appendingPathComponent("10") // zoom level 10
                .appendingPathComponent("\(i % 10)") // tile X
                .appendingPathComponent("\(i % 10).png") // tile Y
            
            try fileManager.createDirectory(at: tilePath.deletingLastPathComponent(), withIntermediateDirectories: true)
            try tileData.write(to: tilePath)
        }
        
        // Update region with actual size
        let regionSize = try calculateRegionSize(regionTilesDirectory)
        
        var updatedRegion = region
        updatedRegion.size = regionSize
        updatedRegion.status = .completed
        
        return updatedRegion
    }
    
    private func createPlaceholderTile() -> Data {
        // Create a simple placeholder tile image
        // In a real implementation, this would be downloaded from a tile server
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.systemGray5.cgColor)
            context.cgContext.fill(rect)
            
            // Add a simple pattern
            context.cgContext.setStrokeColor(UIColor.systemGray3.cgColor)
            context.cgContext.setLineWidth(1)
            
            for i in stride(from: 0, to: 256, by: 32) {
                context.cgContext.move(to: CGPoint(x: i, y: 0))
                context.cgContext.addLine(to: CGPoint(x: i, y: 256))
                context.cgContext.move(to: CGPoint(x: 0, y: i))
                context.cgContext.addLine(to: CGPoint(x: 256, y: i))
            }
            
            context.cgContext.strokePath()
        }
        
        return image.pngData() ?? Data()
    }
    
    private func calculateRegionSize(_ directory: URL) throws -> Int64 {
        var totalSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        return totalSize
    }
    
    private func updateRegionStatus(_ region: DownloadRegion, status: DownloadStatus) {
        if let index = downloadedRegions.firstIndex(where: { $0.id == region.id }) {
            downloadedRegions[index].status = status
            saveDownloadedRegions()
        }
    }
}

// MARK: - Download Region Model

public struct DownloadRegion: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let center: CLLocationCoordinate2D
    public let radius: Double // in meters
    public var status: DownloadStatus
    public let downloadedAt: Date
    public var size: Int64 // in bytes
    
    public init(
        id: UUID = UUID(),
        name: String,
        center: CLLocationCoordinate2D,
        radius: Double,
        status: DownloadStatus = .pending,
        downloadedAt: Date = Date(),
        size: Int64 = 0
    ) {
        self.id = id
        self.name = name
        self.center = center
        self.radius = radius
        self.status = status
        self.downloadedAt = downloadedAt
        self.size = size
    }
}

// MARK: - Download Status

public enum DownloadStatus: String, CaseIterable, Codable {
    case pending
    case downloading
    case completed
    case failed
    case paused
    
    public var displayName: String {
        switch self {
        case .pending: "Pending"
        case .downloading: "Downloading"
        case .completed: "Completed"
        case .failed: "Failed"
        case .paused: "Paused"
        }
    }
}

// MARK: - Cache Models

private struct SearchCache: Codable {
    let query: String
    let results: [SearchResult]
    let timestamp: Date
}

private struct RouteCache: Codable {
    let route: Route
    let timestamp: Date
}

// MARK: - Notification Names

public extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
