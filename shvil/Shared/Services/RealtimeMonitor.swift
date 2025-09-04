//
//  RealtimeMonitor.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Supabase

/// Service for monitoring realtime events and debugging
@MainActor
class RealtimeMonitor: ObservableObject {
    static let shared = RealtimeMonitor()
    
    @Published var isMonitoring = false
    @Published var events: [RealtimeEvent] = []
    @Published var activeChannels: Set<String> = []
    
    private let supabaseService: SupabaseService
    private var channels: [String: RealtimeChannelV2] = [:]
    
    private init() {
        self.supabaseService = SupabaseService.shared
    }
    
    /// Start monitoring all realtime channels
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        events.removeAll()
        
        // Subscribe to common channels
        subscribeToChannel("eta:*", channelName: "eta_updates")
        subscribeToChannel("trip:*", channelName: "trip_updates")
        subscribeToChannel("plan:*", channelName: "plan_updates")
        subscribeToChannel("adventure:*", channelName: "adventure_updates")
        subscribeToChannel("safety:reports", channelName: "safety_reports")
        
        print("Realtime monitoring started")
    }
    
    /// Stop monitoring all channels
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        
        // Unsubscribe from all channels
        for (_, channel) in channels {
            Task {
                await channel.unsubscribe()
            }
        }
        
        channels.removeAll()
        activeChannels.removeAll()
        
        print("Realtime monitoring stopped")
    }
    
    /// Subscribe to a specific channel pattern
    func subscribeToChannel(_ pattern: String, channelName: String) {
        Task {
            do {
                let channel = supabaseService.client.realtimeV2.channel(channelName)
                
                // Listen to all events on this channel
                channel.onBroadcast(event: "*") { [weak self] payload in
                    Task { @MainActor in
                        await self?.handleEvent(
                            channel: channelName,
                            event: "broadcast",
                            payload: payload
                        )
                    }
                }
                
                await channel.subscribe()
                channels[channelName] = channel
                activeChannels.insert(channelName)
                
                print("Subscribed to channel: \(channelName) with pattern: \(pattern)")
            } catch {
                print("Failed to subscribe to channel \(channelName): \(error)")
            }
        }
    }
    
    /// Unsubscribe from a specific channel
    func unsubscribeFromChannel(_ channelName: String) {
        guard let channel = channels[channelName] else { return }
        
        Task {
            await channel.unsubscribe()
            channels.removeValue(forKey: channelName)
            activeChannels.remove(channelName)
            print("Unsubscribed from channel: \(channelName)")
        }
    }
    
    /// Convert AnyJSON to Any
    private func convertAnyJSON(_ anyJSON: AnyJSON) -> Any {
        switch anyJSON {
        case .string(let value):
            return value
        case .double(let value):
            return value
        case .integer(let value):
            return value
        case .bool(let value):
            return value
        case .array(let value):
            return value.map { convertAnyJSON($0) }
        case .object(let value):
            return value.mapValues { convertAnyJSON($0) }
        case .null:
            return NSNull()
        }
    }
    
    /// Handle incoming realtime events
    private func handleEvent(channel: String, event: String, payload: [String: AnyJSON]) {
        // Convert AnyJSON to Any for our internal representation
        let convertedPayload = payload.mapValues { convertAnyJSON($0) }
        
        let realtimeEvent = RealtimeEvent(
            id: UUID(),
            timestamp: Date(),
            channel: channel,
            event: event,
            payload: convertedPayload
        )
        
        events.insert(realtimeEvent, at: 0) // Add to beginning for newest first
        
        // Keep only last 100 events to prevent memory issues
        if events.count > 100 {
            events = Array(events.prefix(100))
        }
        
        print("Realtime event: \(channel).\(event) - \(convertedPayload)")
    }
    
    /// Clear all events
    func clearEvents() {
        events.removeAll()
    }
    
    /// Get events for a specific channel
    func events(forChannel channel: String) -> [RealtimeEvent] {
        return events.filter { $0.channel == channel }
    }
    
    /// Get events for a specific event type
    func events(forEvent event: String) -> [RealtimeEvent] {
        return events.filter { $0.event == event }
    }
}

// MARK: - Realtime Event Model

struct RealtimeEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let channel: String
    let event: String
    let payload: [String: Any]
    
    init(id: UUID = UUID(), timestamp: Date, channel: String, event: String, payload: [String: Any]) {
        self.id = id
        self.timestamp = timestamp
        self.channel = channel
        self.event = event
        self.payload = payload
    }
    
    // Custom coding keys for JSON encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, timestamp, channel, event, payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        channel = try container.decode(String.self, forKey: .channel)
        event = try container.decode(String.self, forKey: .event)
        
        // Handle payload as [String: Any]
        let payloadData = try container.decode([String: AnyCodable].self, forKey: .payload)
        payload = payloadData.mapValues { $0.value }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(channel, forKey: .channel)
        try container.encode(event, forKey: .event)
        
        // Convert [String: Any] to [String: AnyCodable]
        let anyCodablePayload = payload.mapValues { AnyCodable($0) }
        try container.encode(anyCodablePayload, forKey: .payload)
    }
}

// MARK: - AnyCodable Helper

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let array = value as? [Any] {
            try container.encode(array.map { AnyCodable($0) })
        } else if let dict = value as? [String: Any] {
            try container.encode(dict.mapValues { AnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

// MARK: - Realtime Monitor View

import SwiftUI

struct RealtimeMonitorView: View {
    @StateObject private var monitor = RealtimeMonitor.shared
    @State private var selectedChannel: String = "All"
    
    private var channels: [String] {
        let allChannels = Set(monitor.events.map { $0.channel })
        return ["All"] + Array(allChannels).sorted()
    }
    
    private var filteredEvents: [RealtimeEvent] {
        if selectedChannel == "All" {
            return monitor.events
        } else {
            return monitor.events.filter { $0.channel == selectedChannel }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Realtime Monitor")
                    .font(LiquidGlassTypography.title)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Button(monitor.isMonitoring ? "Stop" : "Start") {
                    if monitor.isMonitoring {
                        monitor.stopMonitoring()
                    } else {
                        monitor.startMonitoring()
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(monitor.isMonitoring ? .red : .green)
            }
            .padding()
            
            // Channel filter
            Picker("Channel", selection: $selectedChannel) {
                ForEach(channels, id: \.self) { channel in
                    Text(channel).tag(channel)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Active channels
            if !monitor.activeChannels.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(monitor.activeChannels).sorted(), id: \.self) { channel in
                            Text(channel)
                                .font(LiquidGlassTypography.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LiquidGlassColors.glassSurface2)
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            // Events list
            List(filteredEvents) { event in
                RealtimeEventRow(event: event)
            }
            .listStyle(.plain)
        }
        .background(LiquidGlassColors.background)
        .onAppear {
            if !monitor.isMonitoring {
                monitor.startMonitoring()
            }
        }
    }
}

struct RealtimeEventRow: View {
    let event: RealtimeEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(event.channel).\(event.event)")
                    .font(LiquidGlassTypography.bodySemibold)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Spacer()
                
                Text(event.timestamp, formatter: timeFormatter)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            
            if !event.payload.isEmpty {
                Text(prettyPrint(event.payload))
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    private func prettyPrint(_ dict: [String: Any]) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "Invalid JSON"
        } catch {
            return "Error formatting: \(error)"
        }
    }
}

#Preview {
    RealtimeMonitorView()
        .preferredColorScheme(.dark)
}
