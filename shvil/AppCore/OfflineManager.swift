//
//  OfflineManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import Foundation
import Network

/// Manages offline functionality and data synchronization
@MainActor
class OfflineManager: ObservableObject {
    static let shared = OfflineManager()

    // MARK: - Published Properties

    @Published var isOffline = false
    @Published var pendingSyncOperations: [SyncOperation] = []
    @Published var lastSyncTime: Date?

    // MARK: - Private Properties

    private let networkMonitor = NetworkMonitor.shared
    private let persistence = Persistence()
    private var cancellables = Set<AnyCancellable>()
    private let syncQueue = DispatchQueue(label: "com.shvil.sync", qos: .background)

    private init() {
        setupNetworkMonitoring()
    }

    // MARK: - Network Monitoring

    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected

                if isConnected {
                    Task {
                        await self?.syncPendingOperations()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Sync Operations

    func addSyncOperation(_ operation: SyncOperation) {
        pendingSyncOperations.append(operation)

        if !isOffline {
            Task {
                await syncPendingOperations()
            }
        }
    }

    private func syncPendingOperations() async {
        guard !isOffline else { return }

        let operations = pendingSyncOperations
        pendingSyncOperations.removeAll()

        for operation in operations {
            do {
                try await performSyncOperation(operation)
            } catch {
                // Re-add failed operations to the queue
                pendingSyncOperations.append(operation)
                print("Sync operation failed: \(error)")
            }
        }

        lastSyncTime = Date()
    }

    private func performSyncOperation(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .savePlace:
            if let place = SavedPlace.from(dictionary: operation.data) {
                try await SupabaseService.shared.savePlace(place)
            }
        case .deletePlace:
            if let placeIdString = operation.data["id"] as? String,
               let placeId = UUID(uuidString: placeIdString)
            {
                try await SupabaseService.shared.deletePlace(id: placeId)
            }
        case .shareETA:
            if let routeData = operation.data["route"] as? [String: Any],
               let recipients = operation.data["recipients"] as? [String]
            {
                let route = RouteInfo(
                    duration: routeData["duration"] as? String ?? "",
                    distance: routeData["distance"] as? String ?? "",
                    type: routeData["type"] as? String ?? "",
                    isFastest: routeData["isFastest"] as? Bool ?? false,
                    isSafest: routeData["isSafest"] as? Bool ?? false
                )
                try await SupabaseService.shared.shareETA(route: route, recipients: recipients)
            }
        case .updateLocation:
            // Handle location updates
            break
        }
    }

    // MARK: - Offline Data Management

    func getCachedData<T: Codable>(_: T.Type, key _: String) -> T? {
        // For now, return nil - implement caching in Persistence later
        nil
    }

    func cacheData(_: some Codable, key _: String) {
        // For now, do nothing - implement caching in Persistence later
    }

    func clearCache() {
        // For now, do nothing - implement cache clearing in Persistence later
    }
}

// MARK: - Sync Operation Types

struct SyncOperation: Identifiable, Codable {
    let id: UUID
    let type: SyncOperationType
    let data: [String: Any]
    let timestamp: Date
    let retryCount: Int

    init(type: SyncOperationType, data: Any, retryCount: Int = 0) {
        id = UUID()
        self.type = type
        // Store data as a simple dictionary
        if let dict = data as? [String: Any] {
            self.data = dict
        } else {
            self.data = [:]
        }
        timestamp = Date()
        self.retryCount = retryCount
    }

    // Custom coding keys to handle Any type
    enum CodingKeys: String, CodingKey {
        case id, type, timestamp, retryCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(SyncOperationType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        retryCount = try container.decode(Int.self, forKey: .retryCount)
        data = [:] // Simplified for now
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(retryCount, forKey: .retryCount)
    }
}

enum SyncOperationType: String, Codable {
    case savePlace
    case deletePlace
    case shareETA
    case updateLocation
}

struct ETAShareData: Codable {
    let route: RouteInfo
    let recipients: [String]
}
