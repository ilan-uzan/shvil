//
//  AdventureService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation

/// Service for managing AI-generated adventures and tour mode
@MainActor
public class AdventureService: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var currentAdventure: AdventurePlan?
    @Published public var adventureHistory: [AdventurePlan] = []
    @Published public var isGenerating = false
    @Published public var isTourModeActive = false
    @Published public var currentStopIndex = 0
    @Published public var tourProgress: Double = 0.0
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private let aiKit: AIKit
    private let mapEngine: MapEngine
    private let routingService: AsyncRoutingService
    private let locationManager: LocationManager
    private let offlineManager: OfflineManager
    private var cancellables = Set<AnyCancellable>()
    
    // Tour mode state
    private var tourTimer: Timer?
    private var tourStartTime: Date?
    private var tourStops: [AdventureStop] = []
    
    // MARK: - Initialization
    
    public init(
        aiKit: AIKit,
        mapEngine: MapEngine,
        routingService: AsyncRoutingService,
        locationManager: LocationManager,
        offlineManager: OfflineManager
    ) {
        self.aiKit = aiKit
        self.mapEngine = mapEngine
        self.routingService = routingService
        self.locationManager = locationManager
        self.offlineManager = offlineManager
        
        loadAdventureHistory()
    }
    
    // MARK: - Public Methods
    
    /// Generate a new adventure
    public func generateAdventure(input: AdventureGenerationInput) async throws -> AdventurePlan {
        isGenerating = true
        error = nil
        
        do {
            // Generate adventure plan using AI
            let plan = try await aiKit.generateAdventurePlan(input: input)
            
            // Validate and enhance stops with real locations
            let enhancedPlan = try await enhanceAdventureStops(plan)
            
            // Save to history
            adventureHistory.insert(enhancedPlan, at: 0)
            saveAdventureHistory()
            
            isGenerating = false
            return enhancedPlan
        } catch {
            isGenerating = false
            self.error = error
            throw error
        }
    }
    
    /// Start an adventure
    public func startAdventure(_ adventure: AdventurePlan) {
        currentAdventure = adventure
        tourStops = adventure.stops
        currentStopIndex = 0
        tourProgress = 0.0
        tourStartTime = Date()
        
        // Start tour mode
        startTourMode()
    }
    
    /// Start tour mode
    public func startTourMode() {
        guard !tourStops.isEmpty else { return }
        
        isTourModeActive = true
        startTourTimer()
        
        // Provide haptic feedback
        HapticFeedback.shared.impact(style: .medium)
    }
    
    /// Stop tour mode
    public func stopTourMode() {
        isTourModeActive = false
        stopTourTimer()
        
        // Provide haptic feedback
        HapticFeedback.shared.impact(style: .light)
    }
    
    /// Complete current adventure
    public func completeAdventure() {
        guard var adventure = currentAdventure else { return }
        
        // Update adventure status
        adventure = AdventurePlan(
            id: adventure.id,
            title: adventure.title,
            description: adventure.description,
            theme: adventure.theme,
            stops: adventure.stops,
            totalDuration: adventure.totalDuration,
            totalDistance: adventure.totalDistance,
            budgetLevel: adventure.budgetLevel,
            status: .completed,
            createdAt: adventure.createdAt,
            updatedAt: Date()
        )
        
        // Add to history
        adventureHistory.insert(adventure, at: 0)
        saveAdventureHistory()
        
        // Stop tour mode
        stopTourMode()
        currentAdventure = nil
        tourStops = []
        currentStopIndex = 0
        tourProgress = 0.0
    }
    
    /// Move to next stop in tour
    public func nextStop() {
        guard currentStopIndex < tourStops.count - 1 else { return }
        
        currentStopIndex += 1
        updateTourProgress()
        
        // Provide haptic feedback
        HapticFeedback.shared.impact(style: .light)
    }
    
    /// Move to previous stop in tour
    public func previousStop() {
        guard currentStopIndex > 0 else { return }
        
        currentStopIndex -= 1
        updateTourProgress()
        
        // Provide haptic feedback
        HapticFeedback.shared.impact(style: .light)
    }
    
    /// Get current stop
    public func getCurrentStop() -> AdventureStop? {
        guard currentStopIndex < tourStops.count else { return nil }
        return tourStops[currentStopIndex]
    }
    
    /// Get next stop
    public func getNextStop() -> AdventureStop? {
        guard currentStopIndex + 1 < tourStops.count else { return nil }
        return tourStops[currentStopIndex + 1]
    }
    
    /// Get previous stop
    public func getPreviousStop() -> AdventureStop? {
        guard currentStopIndex > 0 else { return nil }
        return tourStops[currentStopIndex - 1]
    }
    
    /// Generate alternatives for current stop
    public func generateStopAlternatives() async throws -> [AdventureStop] {
        guard let currentStop = getCurrentStop(),
              let adventure = currentAdventure else {
            throw AdventureError.noActiveAdventure
        }
        
        let timeFrame: TimeFrame = adventure.totalDuration <= 240 ? .halfDay : .fullDay // 4 hours = half day
        let companions: [CompanionType] = [] // This would come from user settings
        let budget: BudgetLevel = adventure.budgetLevel
        
        let input = AdventureGenerationInput(
            timeFrame: timeFrame,
            mood: adventure.theme,
            budget: budget,
            companions: companions,
            transportationMode: .walking, // Default
            origin: locationManager.currentLocation?.coordinate ?? CLLocationCoordinate2D(),
            preferences: UserPreferences(
                language: "en",
                theme: "light",
                notifications: NotificationSettings(),
                privacy: PrivacySettings(
                    privacyPolicy: true,
                    locationSharing: true,
                    friendsOnMap: true,
                    etaSharing: true,
                    analytics: true,
                    panicSwitch: false
                )
            )
        )
        
        return try await aiKit.generateStopAlternatives(stop: currentStop, input: input)
    }
    
    /// Replace current stop with alternative
    public func replaceCurrentStop(with alternative: AdventureStop) {
        guard currentStopIndex < tourStops.count else { return }
        
        tourStops[currentStopIndex] = alternative
        
        // Update current adventure
        if var adventure = currentAdventure {
            var updatedStops = adventure.stops
            updatedStops[currentStopIndex] = alternative
            
            adventure = AdventurePlan(
                id: adventure.id,
                title: adventure.title,
                description: adventure.description,
                theme: adventure.theme,
                stops: updatedStops,
                totalDuration: adventure.totalDuration,
                totalDistance: adventure.totalDistance,
                budgetLevel: adventure.budgetLevel,
                status: adventure.status,
                createdAt: adventure.createdAt,
                updatedAt: Date()
            )
            
            currentAdventure = adventure
        }
    }
    
    /// Get adventure recap
    public func getAdventureRecap() async throws -> String {
        guard let adventure = currentAdventure else {
            throw AdventureError.noActiveAdventure
        }
        
        return try await aiKit.generateAdventureRecap(adventure: adventure)
    }
    
    /// Save adventure to favorites
    public func saveAdventureToFavorites(_ adventure: AdventurePlan) {
        // This would typically save to a favorites list
        // For now, we'll just add to history
        adventureHistory.insert(adventure, at: 0)
        saveAdventureHistory()
    }
    
    /// Delete adventure from history
    public func deleteAdventure(_ adventure: AdventurePlan) {
        adventureHistory.removeAll { $0.id == adventure.id }
        saveAdventureHistory()
    }
    
    /// Get popular adventure themes
    public func getPopularThemes() -> [String] {
        return [
            "food_tour".localized,
            "historical_sites".localized,
            "nature_walk".localized,
            "art_gallery".localized,
            "nightlife".localized,
            "family_friendly".localized,
            "romantic_date".localized,
            "adventure_sports".localized
        ]
    }
    
    /// Get popular adventure moods
    public func getPopularMoods() -> [AdventureMood] {
        return AdventureMood.allCases
    }
    
    // MARK: - Private Methods
    
    private func enhanceAdventureStops(_ plan: AdventurePlan) async throws -> AdventurePlan {
        var enhancedStops: [AdventureStop] = []
        
        for stop in plan.stops {
            // Try to find real locations for this stop
            let searchResults = try await mapEngine.searchPlaces(query: stop.name)
            
            if let bestMatch = searchResults.first {
                let enhancedStop = AdventureStop(
                    id: stop.id,
                    name: bestMatch.name,
                    description: stop.description,
                    location: LocationData(
                        latitude: bestMatch.latitude,
                        longitude: bestMatch.longitude,
                        address: bestMatch.address
                    ),
                    category: stop.category,
                    estimatedDuration: stop.estimatedDuration
                )
                enhancedStops.append(enhancedStop)
            } else {
                // Keep original stop if no match found
                enhancedStops.append(stop)
            }
        }
        
        return AdventurePlan(
            id: plan.id,
            title: plan.title,
            description: plan.description,
            theme: plan.theme,
            stops: enhancedStops,
            totalDuration: plan.totalDuration,
            totalDistance: plan.totalDistance,
            budgetLevel: plan.budgetLevel,
            status: plan.status,
            createdAt: plan.createdAt,
            updatedAt: plan.updatedAt
        )
    }
    
    private func startTourTimer() {
        stopTourTimer()
        tourTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTourProgress()
        }
    }
    
    private func stopTourTimer() {
        tourTimer?.invalidate()
        tourTimer = nil
    }
    
    private func updateTourProgress() {
        guard !tourStops.isEmpty else { return }
        
        tourProgress = Double(currentStopIndex) / Double(tourStops.count - 1)
    }
    
    private func getCurrentTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "morning".localized
        case 12..<17:
            return "afternoon".localized
        case 17..<21:
            return "evening".localized
        default:
            return "night".localized
        }
    }
    
    private func getCurrentWeather() -> String {
        // This would typically get weather from a weather service
        return "sunny".localized
    }
    
    private func loadAdventureHistory() {
        if let data = UserDefaults.standard.data(forKey: "adventure_history"),
           let history = try? JSONDecoder().decode([AdventurePlan].self, from: data) {
            adventureHistory = history
        }
    }
    
    private func saveAdventureHistory() {
        if let data = try? JSONEncoder().encode(adventureHistory) {
            UserDefaults.standard.set(data, forKey: "adventure_history")
        }
    }
}

// MARK: - Adventure Errors

public enum AdventureError: LocalizedError {
    case noActiveAdventure
    case generationFailed
    case invalidInput
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .noActiveAdventure:
            "No active adventure"
        case .generationFailed:
            "Failed to generate adventure"
        case .invalidInput:
            "Invalid input provided"
        case .networkError:
            "Network error occurred"
        }
    }
}

// MARK: - Adventure Tour Manager

public class AdventureTourManager: ObservableObject {
    @Published public var isTourActive = false
    @Published public var currentStop: AdventureStop?
    @Published public var tourProgress: Double = 0.0
    @Published public var tourDuration: TimeInterval = 0.0
    
    private var tourStartTime: Date?
    private var tourTimer: Timer?
    
    public func startTour(with stops: [AdventureStop]) {
        isTourActive = true
        tourStartTime = Date()
        tourDuration = 0.0
        
        startTourTimer()
    }
    
    public func stopTour() {
        isTourActive = false
        stopTourTimer()
        tourStartTime = nil
    }
    
    private func startTourTimer() {
        tourTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTourDuration()
        }
    }
    
    private func stopTourTimer() {
        tourTimer?.invalidate()
        tourTimer = nil
    }
    
    private func updateTourDuration() {
        guard let startTime = tourStartTime else { return }
        tourDuration = Date().timeIntervalSince(startTime)
    }
}
