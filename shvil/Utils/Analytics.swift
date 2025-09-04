//
//  Analytics.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

/// Simple analytics and logging (no PII, no precise coordinates)
class Analytics: ObservableObject {
    static let shared = Analytics()
    
    @Published var isEnabled = false
    @Published var eventCount = 0
    
    private var events: [AnalyticsEvent] = []
    private let maxEvents = 1000
    
    init() {
        loadSettings()
    }
    
    func enable() {
        isEnabled = true
        saveSettings()
    }
    
    func disable() {
        isEnabled = false
        events.removeAll()
        saveSettings()
    }
    
    func logEvent(_ event: AnalyticsEvent) {
        guard isEnabled else { return }
        
        events.append(event)
        eventCount += 1
        
        // Maintain event limit
        if events.count > maxEvents {
            events.removeFirst(events.count - maxEvents)
        }
        
        // Save to local storage
        saveEvents()
    }
    
    func logScreenView(_ screen: String) {
        let event = AnalyticsEvent(
            name: "screen_view",
            properties: ["screen": screen],
            timestamp: Date()
        )
        logEvent(event)
    }
    
    func logFeatureUsage(_ feature: String) {
        let event = AnalyticsEvent(
            name: "feature_usage",
            properties: ["feature": feature],
            timestamp: Date()
        )
        logEvent(event)
    }
    
    func logNavigationStart(transportType: String) {
        let event = AnalyticsEvent(
            name: "navigation_start",
            properties: ["transport_type": transportType],
            timestamp: Date()
        )
        logEvent(event)
    }
    
    func logNavigationEnd(duration: TimeInterval, distance: Double) {
        let event = AnalyticsEvent(
            name: "navigation_end",
            properties: [
                "duration_minutes": Int(duration / 60),
                "distance_km": Int(distance / 1000)
            ],
            timestamp: Date()
        )
        logEvent(event)
    }
    
    func logSearchQuery(_ query: String) {
        // Only log query length and type, not the actual query
        let event = AnalyticsEvent(
            name: "search_query",
            properties: [
                "query_length": query.count,
                "query_type": determineQueryType(query)
            ],
            timestamp: Date()
        )
        logEvent(event)
    }
    
    func logError(_ error: String, context: String? = nil) {
        let event = AnalyticsEvent(
            name: "error",
            properties: [
                "error": error,
                "context": context ?? "unknown"
            ],
            timestamp: Date()
        )
        logEvent(event)
    }
    
    func getAnalyticsData() -> [AnalyticsEvent] {
        return events
    }
    
    func clearData() {
        events.removeAll()
        eventCount = 0
        saveEvents()
    }
    
    // MARK: - Private Methods
    private func determineQueryType(_ query: String) -> String {
        if query.contains("restaurant") || query.contains("food") {
            return "food"
        } else if query.contains("gas") || query.contains("fuel") {
            return "fuel"
        } else if query.contains("hotel") || query.contains("lodging") {
            return "lodging"
        } else {
            return "general"
        }
    }
    
    private func loadSettings() {
        // Load from UserDefaults
        isEnabled = UserDefaults.standard.bool(forKey: "analytics_enabled")
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(isEnabled, forKey: "analytics_enabled")
    }
    
    private func saveEvents() {
        // Save events to local storage
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "analytics_events")
        }
    }
}

struct AnalyticsEvent: Codable, Identifiable {
    let id = UUID()
    let name: String
    let properties: [String: Any]
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case name, properties, timestamp
    }
    
    init(name: String, properties: [String: Any], timestamp: Date) {
        self.name = name
        self.properties = properties
        self.timestamp = timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        // Decode properties as [String: String] for simplicity
        let propertiesDict = try container.decode([String: String].self, forKey: .properties)
        properties = propertiesDict
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(timestamp, forKey: .timestamp)
        
        // Encode properties as [String: String] for simplicity
        let propertiesDict = properties.compactMapValues { value in
            if let stringValue = value as? String {
                return stringValue
            } else if let intValue = value as? Int {
                return String(intValue)
            } else if let doubleValue = value as? Double {
                return String(doubleValue)
            } else {
                return String(describing: value)
            }
        }
        try container.encode(propertiesDict, forKey: .properties)
    }
}
