//
//  Persistence.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SQLite3
import CoreLocation
import MapKit

/// Local storage and caching using SQLite
public class Persistence: ObservableObject {
    // MARK: - Private Properties
    private var db: OpaquePointer?
    private let dbPath: String
    
    // MARK: - Initialization
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dbPath = documentsPath.appendingPathComponent("shvil.db").path
        
        setupDatabase()
    }
    
    deinit {
        closeDatabase()
    }
    
    // MARK: - Database Setup
    private func setupDatabase() {
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
            print("Unable to open database")
            return
        }
        
        createTables()
    }
    
    private func createTables() {
        let createSavedPlacesTable = """
        CREATE TABLE IF NOT EXISTS saved_places (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            type TEXT NOT NULL,
            created_at REAL NOT NULL,
            user_id TEXT NOT NULL
        );
        """
        
        let createDestinationsTable = """
        CREATE TABLE IF NOT EXISTS destinations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp REAL NOT NULL
        );
        """
        
        let createRoutesTable = """
        CREATE TABLE IF NOT EXISTS routes (
            id TEXT PRIMARY KEY,
            start_latitude REAL NOT NULL,
            start_longitude REAL NOT NULL,
            end_latitude REAL NOT NULL,
            end_longitude REAL NOT NULL,
            transport_type TEXT NOT NULL,
            route_data BLOB NOT NULL,
            created_at REAL NOT NULL
        );
        """
        
        let createSafetyReportsTable = """
        CREATE TABLE IF NOT EXISTS safety_reports (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            description TEXT,
            reporter_id TEXT,
            created_at REAL NOT NULL,
            expires_at REAL NOT NULL,
            is_active INTEGER NOT NULL,
            geohash TEXT NOT NULL
        );
        """
        
        let createTilesMetadataTable = """
        CREATE TABLE IF NOT EXISTS tiles_metadata (
            tile_key TEXT PRIMARY KEY,
            last_updated REAL NOT NULL,
            data_size INTEGER NOT NULL,
            is_offline_available INTEGER NOT NULL
        );
        """
        
        executeQuery(createSavedPlacesTable)
        executeQuery(createDestinationsTable)
        executeQuery(createRoutesTable)
        executeQuery(createSafetyReportsTable)
        executeQuery(createTilesMetadataTable)
    }
    
    private func executeQuery(_ query: String) {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error executing query: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
    
    private func closeDatabase() {
        if sqlite3_close(db) != SQLITE_OK {
            print("Error closing database")
        }
    }
    
    // MARK: - Saved Places
    func savePlace(_ place: SavedPlace) async {
        let query = """
        INSERT OR REPLACE INTO saved_places 
        (id, name, address, latitude, longitude, type, created_at, user_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, place.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, place.name, -1, nil)
            sqlite3_bind_text(statement, 3, place.address, -1, nil)
            sqlite3_bind_double(statement, 4, place.latitude)
            sqlite3_bind_double(statement, 5, place.longitude)
            sqlite3_bind_text(statement, 6, place.type.rawValue, -1, nil)
            sqlite3_bind_double(statement, 7, place.createdAt.timeIntervalSince1970)
            sqlite3_bind_text(statement, 8, place.userId.uuidString, -1, nil)
            
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadSavedPlaces() async -> [SavedPlace] {
        let query = "SELECT * FROM saved_places ORDER BY created_at DESC"
        var places: [SavedPlace] = []
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let place = SavedPlace(from: statement) {
                    places.append(place)
                }
            }
        }
        
        sqlite3_finalize(statement)
        return places
    }
    
    func deletePlace(_ id: UUID) async {
        let query = "DELETE FROM saved_places WHERE id = ?"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.uuidString, -1, nil)
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Destinations
    func saveDestinations(_ destinations: [Destination]) async {
        let query = """
        INSERT OR REPLACE INTO destinations 
        (id, name, address, latitude, longitude, timestamp)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            for destination in destinations {
                sqlite3_bind_text(statement, 1, destination.id.uuidString, -1, nil)
                sqlite3_bind_text(statement, 2, destination.name, -1, nil)
                sqlite3_bind_text(statement, 3, destination.address, -1, nil)
                sqlite3_bind_double(statement, 4, destination.coordinate.latitude)
                sqlite3_bind_double(statement, 5, destination.coordinate.longitude)
                sqlite3_bind_double(statement, 6, destination.timestamp.timeIntervalSince1970)
                
                sqlite3_step(statement)
                sqlite3_reset(statement)
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadDestinations() async -> [Destination] {
        let query = "SELECT * FROM destinations ORDER BY timestamp DESC LIMIT 100"
        var destinations: [Destination] = []
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let destination = Destination(from: statement) {
                    destinations.append(destination)
                }
            }
        }
        
        sqlite3_finalize(statement)
        return destinations
    }
    
    // MARK: - Routes
    func saveRoute(_ route: CachedRoute) async {
        let query = """
        INSERT OR REPLACE INTO routes 
        (id, start_latitude, start_longitude, end_latitude, end_longitude, transport_type, route_data, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            let routeData = Data() // MKRoute is not Encodable, store as empty for now
            
            sqlite3_bind_text(statement, 1, route.id.uuidString, -1, nil)
            sqlite3_bind_double(statement, 2, route.startCoordinate.latitude)
            sqlite3_bind_double(statement, 3, route.startCoordinate.longitude)
            sqlite3_bind_double(statement, 4, route.endCoordinate.latitude)
            sqlite3_bind_double(statement, 5, route.endCoordinate.longitude)
            sqlite3_bind_text(statement, 6, String(describing: route.transportType), -1, nil)
            
            if !routeData.isEmpty {
                sqlite3_bind_blob(statement, 7, routeData.withUnsafeBytes { $0.baseAddress }, Int32(routeData.count), nil)
            }
            
            sqlite3_bind_double(statement, 8, route.createdAt.timeIntervalSince1970)
            
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadLastRoute() async -> CachedRoute? {
        let query = "SELECT * FROM routes ORDER BY created_at DESC LIMIT 1"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let _ = UUID(uuidString: String(cString: sqlite3_column_text(statement, 0)))!
                let startLat = sqlite3_column_double(statement, 1)
                let startLng = sqlite3_column_double(statement, 2)
                let endLat = sqlite3_column_double(statement, 3)
                let endLng = sqlite3_column_double(statement, 4)
                let transportType = MKDirectionsTransportType.automobile // Default value
                let createdAt = Date() // Default value
                
                let route = CachedRoute(
                    startCoordinate: CLLocationCoordinate2D(latitude: startLat, longitude: startLng),
                    endCoordinate: CLLocationCoordinate2D(latitude: endLat, longitude: endLng),
                    transportType: transportType,
                    route: MKRoute(), // Empty route for now
                    createdAt: createdAt
                )
                sqlite3_finalize(statement)
                return route
            }
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    // MARK: - Safety Reports
    func saveSafetyReports(_ reports: [SafetyReport]) async {
        let query = """
        INSERT OR REPLACE INTO safety_reports 
        (id, type, latitude, longitude, description, reporter_id, created_at, expires_at, is_active, geohash)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            for report in reports {
                sqlite3_bind_text(statement, 1, report.id.uuidString, -1, nil)
                sqlite3_bind_text(statement, 2, report.type.rawValue, -1, nil)
                sqlite3_bind_double(statement, 3, report.coordinate.latitude)
                sqlite3_bind_double(statement, 4, report.coordinate.longitude)
                sqlite3_bind_text(statement, 5, report.description, -1, nil)
                sqlite3_bind_text(statement, 6, report.reporterId?.uuidString, -1, nil)
                sqlite3_bind_double(statement, 7, report.createdAt.timeIntervalSince1970)
                sqlite3_bind_double(statement, 8, report.expiresAt.timeIntervalSince1970)
                sqlite3_bind_int(statement, 9, report.isActive ? 1 : 0)
                sqlite3_bind_text(statement, 10, report.geohash, -1, nil)
                
                sqlite3_step(statement)
                sqlite3_reset(statement)
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadSafetyReports() async -> [SafetyReport] {
        let query = "SELECT * FROM safety_reports WHERE is_active = 1 AND expires_at > ? ORDER BY created_at DESC"
        var reports: [SafetyReport] = []
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                if let report = SafetyReport(from: statement) {
                    reports.append(report)
                }
            }
        }
        
        sqlite3_finalize(statement)
        return reports
    }
    
    // MARK: - Tiles Metadata
    func saveTileMetadata(_ metadata: TileMetadata) async {
        let query = """
        INSERT OR REPLACE INTO tiles_metadata 
        (tile_key, last_updated, data_size, is_offline_available)
        VALUES (?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, metadata.tileKey, -1, nil)
            sqlite3_bind_double(statement, 2, metadata.lastUpdated.timeIntervalSince1970)
            sqlite3_bind_int(statement, 3, Int32(metadata.dataSize))
            sqlite3_bind_int(statement, 4, metadata.isOfflineAvailable ? 1 : 0)
            
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadTileMetadata() async -> [TileMetadata] {
        let query = "SELECT * FROM tiles_metadata ORDER BY last_updated DESC"
        var metadata: [TileMetadata] = []
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let tile = TileMetadata(from: statement) {
                    metadata.append(tile)
                }
            }
        }
        
        sqlite3_finalize(statement)
        return metadata
    }
}

// MARK: - Supporting Types
struct CachedRoute: Identifiable {
    let id = UUID()
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
    let transportType: MKDirectionsTransportType
    let route: MKRoute
    let createdAt: Date
    
    init(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, transportType: MKDirectionsTransportType, route: MKRoute, createdAt: Date) {
        self.startCoordinate = startCoordinate
        self.endCoordinate = endCoordinate
        self.transportType = transportType
        self.route = route
        self.createdAt = createdAt
    }
}

struct TileMetadata: Identifiable {
    let id = UUID()
    let tileKey: String
    let lastUpdated: Date
    let dataSize: Int
    let isOfflineAvailable: Bool
}

// MARK: - Extensions for SQLite
extension SavedPlace {
    init?(from statement: OpaquePointer?) {
        guard let statement = statement else { return nil }
        
        guard let idString = sqlite3_column_text(statement, 0),
              let name = sqlite3_column_text(statement, 1),
              let address = sqlite3_column_text(statement, 2),
              let typeString = sqlite3_column_text(statement, 5),
              let userIdString = sqlite3_column_text(statement, 7) else { return nil }
        
        let id = UUID(uuidString: String(cString: idString))!
        let latitude = sqlite3_column_double(statement, 3)
        let longitude = sqlite3_column_double(statement, 4)
        let type = PlaceType(rawValue: String(cString: typeString))!
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
        let userId = UUID(uuidString: String(cString: userIdString))!
        
        self.init(
            id: id,
            name: String(cString: name),
            address: String(cString: address),
            latitude: latitude,
            longitude: longitude,
            type: type,
            createdAt: createdAt,
            userId: userId
        )
    }
}

extension Destination {
    init?(from statement: OpaquePointer?) {
        guard let statement = statement else { return nil }
        
        guard let idString = sqlite3_column_text(statement, 0),
              let name = sqlite3_column_text(statement, 1),
              let address = sqlite3_column_text(statement, 2) else { return nil }
        
        _ = UUID(uuidString: String(cString: idString))!
        let latitude = sqlite3_column_double(statement, 3)
        let longitude = sqlite3_column_double(statement, 4)
        let timestamp = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
        
        self.init(
            name: String(cString: name),
            address: String(cString: address),
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            timestamp: timestamp
        )
    }
}

extension SafetyReport {
    init?(from statement: OpaquePointer?) {
        guard let statement = statement else { return nil }
        
        guard let idString = sqlite3_column_text(statement, 0),
              let typeString = sqlite3_column_text(statement, 1),
              let geohash = sqlite3_column_text(statement, 9) else { return nil }
        
        let id = UUID(uuidString: String(cString: idString))!
        let type = SafetyReportType(rawValue: String(cString: typeString))!
        let latitude = sqlite3_column_double(statement, 2)
        let longitude = sqlite3_column_double(statement, 3)
        let description = sqlite3_column_text(statement, 4).map { String(cString: $0) }
        let reporterId = sqlite3_column_text(statement, 5).map { UUID(uuidString: String(cString: $0)) }
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
        let expiresAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))
        let isActive = sqlite3_column_int(statement, 8) == 1
        
        self.init(
            id: id,
            type: type,
            coordinate: Coordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)),
            description: description,
            reporterId: reporterId as? UUID,
            createdAt: createdAt,
            expiresAt: expiresAt,
            isActive: isActive,
            geohash: String(cString: geohash)
        )
    }
}

extension TileMetadata {
    init?(from statement: OpaquePointer?) {
        guard let statement = statement else { return nil }
        
        guard let tileKey = sqlite3_column_text(statement, 0) else { return nil }
        
        let lastUpdated = Date(timeIntervalSince1970: sqlite3_column_double(statement, 1))
        let dataSize = Int(sqlite3_column_int(statement, 2))
        let isOfflineAvailable = sqlite3_column_int(statement, 3) == 1
        
        self.init(
            tileKey: String(cString: tileKey),
            lastUpdated: lastUpdated,
            dataSize: dataSize,
            isOfflineAvailable: isOfflineAvailable
        )
    }
}

// MARK: - Adventure Support

extension Persistence {
    /// Save an adventure plan
    func saveAdventure(_ adventure: AdventurePlan) async throws {
        let query = "INSERT OR REPLACE INTO adventures (id, title, tagline, theme, mood, duration_hours, is_group, notes, created_at, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, adventure.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, adventure.title, -1, nil)
            sqlite3_bind_text(statement, 3, adventure.tagline, -1, nil)
            sqlite3_bind_text(statement, 4, adventure.theme, -1, nil)
            sqlite3_bind_text(statement, 5, adventure.mood.rawValue, -1, nil)
            sqlite3_bind_int(statement, 6, Int32(adventure.durationHours))
            sqlite3_bind_int(statement, 7, adventure.isGroup ? 1 : 0)
            sqlite3_bind_text(statement, 8, adventure.notes, -1, nil)
            sqlite3_bind_double(statement, 9, adventure.createdAt.timeIntervalSince1970)
            sqlite3_bind_text(statement, 10, adventure.status.rawValue, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw PersistenceError.saveFailed
            }
        }
        
        sqlite3_finalize(statement)
        
        // Save adventure stops
        for stop in adventure.stops {
            try await saveAdventureStop(stop, adventureId: adventure.id)
        }
    }
    
    /// Save an adventure stop
    private func saveAdventureStop(_ stop: AdventureStop, adventureId: UUID) async throws {
        let query = "INSERT OR REPLACE INTO adventure_stops (adventure_id, stop_id, chapter, category, ideal_duration_min, narrative, open_late, budget, accessibility, outdoor, place_id, name, address, latitude, longitude, start_hint_ts, stay_minutes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, adventureId.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, stop.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 3, stop.chapter, -1, nil)
            sqlite3_bind_text(statement, 4, stop.category.rawValue, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(stop.idealDurationMin))
            sqlite3_bind_text(statement, 6, stop.narrative, -1, nil)
            sqlite3_bind_int(statement, 7, stop.constraints.openLate ? 1 : 0)
            sqlite3_bind_text(statement, 8, stop.constraints.budget.rawValue, -1, nil)
            sqlite3_bind_int(statement, 9, stop.constraints.accessibility ? 1 : 0)
            sqlite3_bind_int(statement, 10, stop.constraints.outdoor ? 1 : 0)
            sqlite3_bind_text(statement, 11, stop.placeId ?? "", -1, nil)
            sqlite3_bind_text(statement, 12, stop.name ?? "", -1, nil)
            sqlite3_bind_text(statement, 13, stop.address ?? "", -1, nil)
            sqlite3_bind_double(statement, 14, stop.coordinate?.latitude ?? 0.0)
            sqlite3_bind_double(statement, 15, stop.coordinate?.longitude ?? 0.0)
            sqlite3_bind_double(statement, 16, stop.startHintTimestamp?.timeIntervalSince1970 ?? 0.0)
            sqlite3_bind_int(statement, 17, Int32(stop.stayMinutes ?? 0))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw PersistenceError.saveFailed
            }
        }
        
        sqlite3_finalize(statement)
    }
}

// MARK: - Persistence Errors

enum PersistenceError: Error, LocalizedError {
    case saveFailed
    case loadFailed
    case databaseError
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .loadFailed:
            return "Failed to load data"
        case .databaseError:
            return "Database error occurred"
        }
    }
}
