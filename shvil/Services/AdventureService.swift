//
//  AdventureService.swift
//  shvil
//
//  Adventure creation and management service
//

import Foundation
import Combine

/// Service for managing adventure creation and data
@MainActor
class AdventureService: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var createdAdventure: Adventure?
    @Published var isGenerating = false
    
    // MARK: - Adventure Creation
    
    /// Create a new adventure with the given parameters
    func createAdventure(
        mood: String,
        duration: String,
        transport: String,
        location: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        isGenerating = true
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Generate demo adventure
            let adventure = generateDemoAdventure(
                mood: mood,
                duration: duration,
                transport: transport,
                location: location ?? "Jerusalem, Israel"
            )
            
            createdAdventure = adventure
        } catch {
            errorMessage = "Failed to create adventure: \(error.localizedDescription)"
        }
        
        isLoading = false
        isGenerating = false
    }
    
    // MARK: - Private Methods
    
    private func generateDemoAdventure(
        mood: String,
        duration: String,
        transport: String,
        location: String
    ) -> Adventure {
        let title = "\(mood) Adventure in \(location)"
        let description = "A \(duration.lowercased()) \(mood.lowercased()) experience exploring \(location) by \(transport.lowercased())."
        
        // Generate demo route data
        let routeData = RouteData(
            origin: LocationData(
                latitude: 31.7683,
                longitude: 35.2137,
                address: "Jerusalem, Israel"
            ),
            destination: LocationData(
                latitude: 31.7683 + Double.random(in: -0.01...0.01),
                longitude: 35.2137 + Double.random(in: -0.01...0.01),
                address: "\(location) Destination"
            ),
            waypoints: [],
            distance: Double(calculateDistance(for: duration)),
            duration: calculateDuration(for: duration),
            transportMode: transport.lowercased(),
            estimatedArrival: Date().addingTimeInterval(calculateDuration(for: duration))
        )
        
        return Adventure(
            id: UUID(),
            userId: UUID(),
            title: title,
            description: description,
            routeData: routeData,
            stops: [],
            status: .draft,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    private func calculateDistance(for duration: String) -> Int {
        switch duration {
        case "1 hour": return 2000
        case "2 hours": return 4000
        case "Half day": return 8000
        case "Full day": return 15000
        default: return 3000
        }
    }
    
    private func calculateDuration(for duration: String) -> TimeInterval {
        switch duration {
        case "1 hour": return 3600
        case "2 hours": return 7200
        case "Half day": return 14400
        case "Full day": return 28800
        default: return 5400
        }
    }
}