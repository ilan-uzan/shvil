//
//  SafetyKit.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import MapKit

/// Safety reports and crowd-sourced data management
public class SafetyKit: ObservableObject {
    // MARK: - Published Properties

    @Published var safetyReports: [SafetyReport] = []
    @Published var isSafetyLayerEnabled = false
    @Published var nearbyReports: [SafetyReport] = []

    // MARK: - Private Properties

    private let persistence: Persistence
    private let socialKit: SocialKit
    private var cancellables = Set<AnyCancellable>()
    private var reportCache: [String: SafetyReport] = [:]

    // MARK: - Constants

    private let reportTTL: TimeInterval = 45 * 60 // 45 minutes
    private let geohashPrecision = 6 // ~1.2km precision
    private let maxCacheSize = 1000

    // MARK: - Initialization

    init(persistence: Persistence = Persistence(), socialKit: SocialKit = SocialKit()) {
        self.persistence = persistence
        self.socialKit = socialKit

        loadCachedReports()
        startReportCleanup()
    }

    // MARK: - Public Methods

    func enableSafetyLayer() {
        isSafetyLayerEnabled = true
        loadNearbyReports()
    }

    func disableSafetyLayer() {
        isSafetyLayerEnabled = false
        nearbyReports.removeAll()
    }

    func submitReport(type: SafetyReportType, coordinate: CLLocationCoordinate2D, description: String? = nil) async throws {
        let report = SafetyReport(
            id: UUID(),
            userId: UUID(), // TODO: Use actual user ID
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            reportType: type.rawValue,
            description: description ?? "",
            severity: 2, // Default severity (medium)
            isResolved: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        // Check for duplicates
        if isDuplicateReport(report) {
            return
        }

        // Add to local cache
        addToCache(report)

        // Submit to server
        try await submitToServer(report)

        // Update nearby reports if safety layer is enabled
        if isSafetyLayerEnabled {
            updateNearbyReports()
        }
    }

    func loadNearbyReports(center: CLLocationCoordinate2D? = nil) {
        guard isSafetyLayerEnabled else { return }

        let centerCoordinate = center ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let nearby = safetyReports.filter { report in
            let distance = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                .distance(from: CLLocation(latitude: report.latitude, longitude: report.longitude))
            return distance < 10000 // Within 10km
        }

        nearbyReports = nearby
    }

    func getReportsForRoute(_ route: MKRoute) -> [SafetyReport] {
        let routeCoordinates = route.polyline.coordinates
        return safetyReports.filter { report in
            isReportNearRoute(report, routeCoordinates: routeCoordinates)
        }
    }

    func generateSafetyAlert(for report: SafetyReport) -> SafetyAlert? {
        guard isSafetyLayerEnabled else { return nil }

        return SafetyAlert(
            type: SafetyReportType(rawValue: report.reportType) ?? .other,
            message: alertMessage(for: SafetyReportType(rawValue: report.reportType) ?? .other),
            coordinate: CLLocationCoordinate2D(latitude: report.latitude, longitude: report.longitude),
            severity: severityForReport(report)
        )
    }

    // MARK: - Private Methods

    private func loadCachedReports() {
        Task {
            let cached = await persistence.loadSafetyReports()
            safetyReports = cached
        }
    }

    private func addToCache(_ report: SafetyReport) {
        reportCache[report.id.uuidString] = report
        safetyReports.append(report)

        // Maintain cache size
        if reportCache.count > maxCacheSize {
            let oldestReports = safetyReports.sorted { $0.createdAt < $1.createdAt }
            let toRemove = oldestReports.prefix(reportCache.count - maxCacheSize)
            for report in toRemove {
                reportCache.removeValue(forKey: report.id.uuidString)
                safetyReports.removeAll { $0.id == report.id }
            }
        }
    }

    private func isDuplicateReport(_ report: SafetyReport) -> Bool {
        let sameType = safetyReports.filter { $0.reportType == report.reportType }
        let recent = sameType.filter {
            abs($0.createdAt.timeIntervalSince(report.createdAt)) < 300 // 5 minutes
        }

        return !recent.isEmpty
    }

    private func submitToServer(_ report: SafetyReport) async throws {
        // Submit to Supabase
        try await socialKit.client
            .from("safety_reports")
            .insert(report)
            .execute()
    }

    private func updateNearbyReports() {
        // Implementation for updating nearby reports
        // This would typically be called when the map region changes
    }

    private func isReportNearRoute(_ report: SafetyReport, routeCoordinates: [CLLocationCoordinate2D]) -> Bool {
        let reportLocation = CLLocation(latitude: report.latitude, longitude: report.longitude)

        for coordinate in routeCoordinates {
            let routeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = reportLocation.distance(from: routeLocation)

            if distance < 500 { // Within 500m of route
                return true
            }
        }

        return false
    }

    private func alertMessage(for type: SafetyReportType) -> String {
        switch type {
        case .police:
            "Police ahead"
        case .accident:
            "Accident reported ahead"
        case .roadClosure:
            "Road closure ahead"
        case .construction:
            "Construction ahead"
        case .hazard:
            "Hazard reported ahead"
        case .emergency:
            "Emergency ahead"
        case .weather:
            "Weather warning"
        case .other:
            "Incident reported ahead"
        }
    }

    private func severityForReport(_ report: SafetyReport) -> SafetyAlertSeverity {
        let age = Date().timeIntervalSince(report.createdAt)

        switch SafetyReportType(rawValue: report.reportType) ?? .other {
        case .accident:
            return age < 15 * 60 ? .high : .medium
        case .police:
            return age < 30 * 60 ? .high : .low
        case .roadClosure:
            return age < 60 * 60 ? .high : .medium
        case .construction:
            return .medium
        case .hazard:
            return age < 30 * 60 ? .high : .medium
        case .emergency:
            return .high
        case .weather:
            return .medium
        case .other:
            return .low
        }
    }

    private func startReportCleanup() {
        Timer.publish(every: 60, on: .main, in: .common) // Every minute
            .autoconnect()
            .sink { [weak self] _ in
                self?.cleanupExpiredReports()
            }
            .store(in: &cancellables)
    }

    private func cleanupExpiredReports() {
        // Clean up old reports (older than 1 hour)
        let oneHourAgo = Date().addingTimeInterval(-3600)
        safetyReports.removeAll { $0.createdAt < oneHourAgo }
        nearbyReports.removeAll { $0.createdAt < oneHourAgo }

        // Clean up cache
        let expiredIds = reportCache.compactMap { key, report in
            report.createdAt < oneHourAgo ? key : nil
        }

        for id in expiredIds {
            reportCache.removeValue(forKey: id)
        }
    }
}

// MARK: - Supporting Types

struct SafetyAlert {
    let type: SafetyReportType
    let message: String
    let coordinate: CLLocationCoordinate2D
    let severity: SafetyAlertSeverity
}

enum SafetyAlertSeverity {
    case low
    case medium
    case high
}

// MARK: - Extensions

extension CLLocationCoordinate2D {
    func geohash(precision: Int) -> String {
        // Simple geohash implementation
        // In production, use a proper geohash library
        let lat = (latitude + 90) / 180
        let lon = (longitude + 180) / 360

        var geohash = ""
        var latVal = lat
        var lonVal = lon

        for _ in 0 ..< precision {
            let latBit = latVal >= 0.5 ? "1" : "0"
            let lonBit = lonVal >= 0.5 ? "1" : "0"
            geohash += latBit + lonBit

            latVal = (latVal - 0.5) * 2
            lonVal = (lonVal - 0.5) * 2
        }

        return geohash
    }

    /// Get safety reports near a location
    public func getSafetyReports(near _: CLLocationCoordinate2D, radius _: Double) async throws -> [SafetyReport] {
        // For now, return empty array - this would typically query a database
        // In a real implementation, this would query the safety reports database
        // and filter by location and radius
        []
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        let pointCount = pointCount

        for i in 0 ..< pointCount {
            var coord = CLLocationCoordinate2D()
            getCoordinates(&coord, range: NSRange(location: i, length: 1))
            coords.append(coord)
        }

        return coords
    }
}
