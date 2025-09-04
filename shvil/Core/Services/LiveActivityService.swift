//
//  LiveActivityService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI
import WidgetKit

/// Service for managing Live Activities and Dynamic Island
@MainActor
public class LiveActivityService: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var isLiveActivityActive = false
    // Note: Activity type not available without ActivityKit framework
    // @Published public var currentActivity: Activity<NavigationActivityAttributes>?
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    // Note: ActivityCenter not available without ActivityKit framework
    // private let activityCenter = ActivityCenter.shared
    
    // MARK: - Public Methods
    
    /// Start Live Activity for navigation
    public func startNavigationActivity(
        route: Route,
        currentStep: RouteStep?,
        remainingTime: TimeInterval,
        remainingDistance: Double
    ) {
        // Note: ActivityKit not available, so we'll just set the state
        // guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        //     error = LiveActivityError.notAuthorized
        //     return
        // }
        
        // let attributes = NavigationActivityAttributes(
        //     routeName: route.name,
        //     destination: route.polyline.last?.description ?? "",
        //     startTime: Date()
        // )
        
        // let contentState = NavigationActivityAttributes.ContentState(
        //     currentStep: currentStep?.instruction ?? "",
        //     nextStep: route.steps.first?.instruction ?? "",
        //     remainingTime: remainingTime,
        //     remainingDistance: remainingDistance,
        //     isActive: true
        // )
        
        // let activityContent = ActivityContent(
        //     state: contentState,
        //     staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        // )
        
        // do {
        //     currentActivity = try activityCenter.request(
        //         attributes: attributes,
        //         content: activityContent,
        //         pushType: .token
        //     )
        //     isLiveActivityActive = true
        // } catch {
        //     self.error = error
        // }
        
        // For now, just set the state without ActivityKit
        isLiveActivityActive = true
    }
    
    /// Update Live Activity content
    public func updateNavigationActivity(
        currentStep: RouteStep?,
        nextStep: RouteStep?,
        remainingTime: TimeInterval,
        remainingDistance: Double
    ) {
        // Note: ActivityKit not available, so we'll just update the state
        // guard let activity = currentActivity else { return }
        
        // let contentState = NavigationActivityAttributes.ContentState(
        //     currentStep: currentStep?.instruction ?? "",
        //     nextStep: nextStep?.instruction ?? "",
        //     remainingTime: remainingTime,
        //     remainingDistance: remainingDistance,
        //     isActive: true
        // )
        
        // let activityContent = ActivityContent(
        //     state: contentState,
        //     staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        // )
        
        // Task {
        //     await activity.update(activityContent)
        // }
        
        // For now, just update the state without ActivityKit
        // No-op for now
    }
    
    /// End Live Activity
    public func endNavigationActivity() {
        // Note: ActivityKit not available, so we'll just update the state
        // guard let activity = currentActivity else { return }
        
        // let contentState = NavigationActivityAttributes.ContentState(
        //     currentStep: "guidance_complete".localized,
        //     nextStep: "",
        //     remainingTime: 0,
        //     remainingDistance: 0,
        //     isActive: false
        // )
        
        // let activityContent = ActivityContent(
        //     state: contentState,
        //     staleDate: Date()
        // )
        
        // Task {
        //     await activity.end(activityContent, dismissalPolicy: .immediate)
        // }
        
        // currentActivity = nil
        isLiveActivityActive = false
    }
    
    /// Check if Live Activities are available
    public func isLiveActivityAvailable() -> Bool {
        // Note: ActivityKit not available, so return false for now
        // return ActivityAuthorizationInfo().areActivitiesEnabled
        return false
    }
    
    /// Request Live Activity authorization
    public func requestAuthorization() async -> Bool {
        // Note: ActivityKit not available, so return false for now
        // return await activityCenter.requestAuthorization()
        return false
    }
}

// MARK: - Live Activity Attributes

// Note: ActivityAttributes not available without ActivityKit framework
// public struct NavigationActivityAttributes: ActivityAttributes {
public struct NavigationActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public let currentStep: String
        public let nextStep: String
        public let remainingTime: TimeInterval
        public let remainingDistance: Double
        public let isActive: Bool
        
        public init(
            currentStep: String,
            nextStep: String,
            remainingTime: TimeInterval,
            remainingDistance: Double,
            isActive: Bool
        ) {
            self.currentStep = currentStep
            self.nextStep = nextStep
            self.remainingTime = remainingTime
            self.remainingDistance = remainingDistance
            self.isActive = isActive
        }
    }
    
    public let routeName: String
    public let destination: String
    public let startTime: Date
    
    public init(routeName: String, destination: String, startTime: Date) {
        self.routeName = routeName
        self.destination = destination
        self.startTime = startTime
    }
}

// MARK: - Live Activity Widget

// Note: Widget not available without ActivityKit framework
// struct ShvilLiveActivityWidget: Widget {
//     var body: some WidgetConfiguration {
//         ActivityConfiguration(for: NavigationActivityAttributes.self) { context in
//             NavigationLiveActivityView(context: context)
//         } dynamicIsland: { context in
//             DynamicIsland {
//                 DynamicIslandExpandedRegion(.leading) {
//                     VStack(alignment: .leading, spacing: 4) {
//                         Text(context.attributes.routeName)
//                             .font(.caption)
//                             .foregroundColor(.secondary)
//                         
//                         Text(context.state.currentStep)
//                             .font(.caption2)
//                             .foregroundColor(.primary)
//                             .lineLimit(1)
//                     }
//                 }
//                 
//                 DynamicIslandExpandedRegion(.trailing) {
//                     VStack(alignment: .trailing, spacing: 4) {
//                         Text(formatTime(context.state.remainingTime))
//                             .font(.caption)
//                             .foregroundColor(.primary)
//                         
//                         Text(formatDistance(context.state.remainingDistance))
//                             .font(.caption2)
//                             .foregroundColor(.secondary)
//                     }
//                 }
//                 
//                 DynamicIslandExpandedRegion(.bottom) {
//                     if !context.state.nextStep.isEmpty {
//                         Text("next".localized + ": " + context.state.nextStep)
//                             .font(.caption2)
//                             .foregroundColor(.secondary)
//                             .lineLimit(1)
//                     }
//                 }
//             } compactLeading: {
//                 Image(systemName: "location.fill")
//                     .foregroundColor(.blue)
//             } compactTrailing: {
//                 Text(formatTime(context.state.remainingTime))
//                     .font(.caption2)
//                     .foregroundColor(.primary)
//             } minimal: {
//                 Image(systemName: "location.fill")
//                     .foregroundColor(.blue)
//             }
//         }
//     }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }

// MARK: - Live Activity View

struct NavigationLiveActivityView: View {
    // Note: ActivityViewContext not available without ActivityKit framework
    // let context: ActivityViewContext<NavigationActivityAttributes>
    let context: NavigationActivityAttributes.ContentState
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Navigation") // context.attributes.routeName
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Destination") // context.attributes.destination
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatTime(context.remainingTime))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(formatDistance(context.remainingDistance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Current step
            HStack {
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
                
                Text(context.currentStep)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
            }
            
            // Next step (if available)
            if !context.nextStep.isEmpty {
                HStack {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    
                    Text("next".localized + ": " + context.nextStep)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

// MARK: - Live Activity Errors

public enum LiveActivityError: LocalizedError {
    case notAuthorized
    case notAvailable
    case updateFailed
    case endFailed
    
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            "Live Activities not authorized"
        case .notAvailable:
            "Live Activities not available on this device"
        case .updateFailed:
            "Failed to update Live Activity"
        case .endFailed:
            "Failed to end Live Activity"
        }
    }
}

// MARK: - Dynamic Island Manager

public class DynamicIslandManager: ObservableObject {
    @Published public var isDynamicIslandActive = false
    @Published public var currentContent: DynamicIslandContent?
    
    public init() {}
    
    public func updateContent(_ content: DynamicIslandContent) {
        currentContent = content
        isDynamicIslandActive = true
    }
    
    public func clearContent() {
        currentContent = nil
        isDynamicIslandActive = false
    }
}

// MARK: - Dynamic Island Content

public struct DynamicIslandContent {
    public let leadingIcon: String
    public let leadingText: String
    public let trailingText: String
    public let bottomText: String?
    
    public init(
        leadingIcon: String,
        leadingText: String,
        trailingText: String,
        bottomText: String? = nil
    ) {
        self.leadingIcon = leadingIcon
        self.leadingText = leadingText
        self.trailingText = trailingText
        self.bottomText = bottomText
    }
}
