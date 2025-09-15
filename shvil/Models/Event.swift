//
//  Event.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation

/// Event model for Supabase events table
struct Event: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    let eventName: String
    let properties: [String: String]
    let timestamp: Date
    let sessionId: String?
    let appVersion: String?
    let platform: String
    
    init(
        id: UUID = UUID(),
        userId: UUID? = nil,
        eventName: String,
        properties: [String: String] = [:],
        timestamp: Date = Date(),
        sessionId: String? = nil,
        appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        platform: String = "iOS"
    ) {
        self.id = id
        self.userId = userId
        self.eventName = eventName
        self.properties = properties
        self.timestamp = timestamp
        self.sessionId = sessionId
        self.appVersion = appVersion
        self.platform = platform
    }
}

/// Analytics event that can be sent to Supabase
struct SupabaseAnalyticsEvent: Codable {
    let eventName: String
    let properties: [String: String]
    let timestamp: Date
    let sessionId: String?
    let appVersion: String?
    let platform: String
    
    init(from analyticsEvent: AnalyticsEvent, userId: UUID? = nil, sessionId: String? = nil) {
        self.eventName = analyticsEvent.name
        self.properties = analyticsEvent.properties.compactMapValues { value in
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
        self.timestamp = analyticsEvent.timestamp
        self.sessionId = sessionId
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.platform = "iOS"
    }
}
