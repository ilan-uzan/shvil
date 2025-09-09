//
//  GuidanceService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import AVFoundation
import Combine
import CoreLocation
import Foundation
import UIKit

/// Advanced turn-by-turn guidance service with voice and haptic feedback
@MainActor
public class GuidanceService: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published public var isGuidanceActive = false
    @Published public var currentStep: RouteStep?
    @Published public var nextStep: RouteStep?
    @Published public var remainingTime: TimeInterval = 0
    @Published public var remainingDistance: Double = 0
    @Published public var currentSpeed: Double = 0
    @Published public var isVoiceEnabled = true
    @Published public var isHapticEnabled = true
    @Published public var voiceVolume: Float = 0.8
    @Published public var guidanceMode: GuidanceMode = .standard
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private var speechSynthesizer: AVSpeechSynthesizer?
    private let locationManager = CLLocationManager()
    private var guidanceTimer: Timer?
    private var speedTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Guidance state
    private var currentRoute: Route?
    private var currentStepIndex = 0
    private var lastAnnouncedStep: RouteStep?
    private var isApproachingStep = false
    private var lastLocation: CLLocation?
    private var guidanceStartTime: Date?
    
    // Voice settings
    private var voiceSettings = VoiceSettings()
    private var pendingAnnouncements: [String] = []
    private var isSpeaking = false
    private var voiceServiceAvailable = false
    
    // Haptic settings
    private let hapticSettings = HapticSettings()
    
    // MARK: - Constants
    
    private let stepApproachDistance: Double = 100 // meters
    private let stepAnnouncementDistance: Double = 50 // meters
    private let speedUpdateInterval: TimeInterval = 1.0
    private let guidanceUpdateInterval: TimeInterval = 2.0
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupLocationManager()
        setupSpeechSynthesizer()
        setupHapticFeedback()
    }
    
    private func setupSpeechSynthesizer() {
        // Check if voice services are available before initializing
        guard !ProcessInfo.processInfo.isLowPowerModeEnabled else {
            print("🔇 Voice services disabled: Low power mode enabled")
            self.speechSynthesizer = nil
            self.voiceServiceAvailable = false
            self.isVoiceEnabled = false
            return
        }
        
        // Try to initialize speech synthesizer safely
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        self.speechSynthesizer = synthesizer
        self.voiceServiceAvailable = true
    }
    
    // MARK: - Public Methods
    
    /// Start guidance for a route
    public func startGuidance(for route: Route) {
        currentRoute = route
        currentStepIndex = 0
        isGuidanceActive = true
        guidanceStartTime = Date()
        
        updateCurrentStep()
        startGuidanceTimer()
        startSpeedTimer()
        
        // Provide start haptic feedback
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .heavy)
        }
        
        // Announce start of guidance
        announceGuidanceStart()
    }
    
    /// Stop guidance
    public func stopGuidance() {
        isGuidanceActive = false
        currentRoute = nil
        currentStep = nil
        nextStep = nil
        remainingTime = 0
        remainingDistance = 0
        currentSpeed = 0
        
        stopGuidanceTimer()
        stopSpeedTimer()
        
        // Stop any ongoing speech
        speechSynthesizer?.stopSpeaking(at: .immediate)
        
        // Provide stop haptic feedback
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .light)
        }
    }
    
    /// Pause guidance
    public func pauseGuidance() {
        isGuidanceActive = false
        stopGuidanceTimer()
        stopSpeedTimer()
        
        // Announce pause
        announceMessage("guidance_paused".localized)
    }
    
    /// Resume guidance
    public func resumeGuidance() {
        guard currentRoute != nil else { return }
        
        isGuidanceActive = true
        startGuidanceTimer()
        startSpeedTimer()
        
        // Announce resume
        announceMessage("guidance_resumed".localized)
    }
    
    /// Skip current step
    public func skipCurrentStep() {
        guard let route = currentRoute,
              currentStepIndex < route.steps.count - 1 else { return }
        
        currentStepIndex += 1
        updateCurrentStep()
        
        // Provide skip haptic feedback
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .medium)
        }
        
        // Announce next step
        announceCurrentStep()
    }
    
    /// Toggle voice guidance
    public func toggleVoiceGuidance() {
        guard voiceServiceAvailable else {
            print("⚠️ Voice guidance not available")
            return
        }
        
        isVoiceEnabled.toggle()
        
        if isVoiceEnabled {
            announceMessage("voice_guidance_enabled".localized)
        } else {
            speechSynthesizer?.stopSpeaking(at: .immediate)
            announceMessage("voice_guidance_disabled".localized)
        }
    }
    
    /// Toggle haptic feedback
    public func toggleHapticFeedback() {
        isHapticEnabled.toggle()
        
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .light)
        }
    }
    
    /// Set guidance mode
    public func setGuidanceMode(_ mode: GuidanceMode) {
        guidanceMode = mode
        
        // Adjust voice settings based on mode
        switch mode {
        case .standard:
            voiceSettings.rate = 0.5
            voiceSettings.volume = 0.8
        case .detailed:
            voiceSettings.rate = 0.4
            voiceSettings.volume = 0.9
        case .minimal:
            voiceSettings.rate = 0.6
            voiceSettings.volume = 0.7
        }
    }
    
    /// Set voice volume
    public func setVoiceVolume(_ volume: Float) {
        voiceVolume = max(0.0, min(1.0, volume))
        voiceSettings.volume = voiceVolume
    }
    
    /// Update location for guidance
    public func updateLocation(_ location: CLLocation) {
        lastLocation = location
        currentSpeed = location.speed >= 0 ? location.speed : 0
        
        guard isGuidanceActive,
              let route = currentRoute,
              let currentStep = currentStep else { return }
        
        // Check if approaching current step
        let stepEnd = currentStep.polyline.last
        if let stepEnd = stepEnd {
            let stepEndLocation = CLLocation(latitude: stepEnd.latitude, longitude: stepEnd.longitude)
            let distance = location.distance(from: stepEndLocation)
            
            if distance <= stepApproachDistance && !isApproachingStep {
                isApproachingStep = true
                announceApproachingStep()
            }
            
            if distance <= stepAnnouncementDistance && lastAnnouncedStep?.id != currentStep.id {
                lastAnnouncedStep = currentStep
                announceCurrentStep()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    
    private func setupHapticFeedback() {
        // Haptic feedback is handled by the HapticFeedback service
    }
    
    private func startGuidanceTimer() {
        stopGuidanceTimer()
        guidanceTimer = Timer.scheduledTimer(withTimeInterval: guidanceUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateGuidance()
            }
        }
    }
    
    private func stopGuidanceTimer() {
        guidanceTimer?.invalidate()
        guidanceTimer = nil
    }
    
    private func startSpeedTimer() {
        stopSpeedTimer()
        speedTimer = Timer.scheduledTimer(withTimeInterval: speedUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateSpeed()
            }
        }
    }
    
    private func stopSpeedTimer() {
        speedTimer?.invalidate()
        speedTimer = nil
    }
    
    private func updateGuidance() {
        guard let route = currentRoute else { return }
        
        // Update remaining time and distance
        let remainingSteps = Array(route.steps.suffix(from: currentStepIndex))
        remainingTime = remainingSteps.reduce(0) { $0 + $1.expectedTravelTime }
        remainingDistance = remainingSteps.reduce(0) { $0 + $1.distance }
        
        // Check if guidance is complete
        if currentStepIndex >= route.steps.count {
            completeGuidance()
        }
    }
    
    private func updateSpeed() {
        // Update current speed from location
        if let location = lastLocation {
            currentSpeed = location.speed >= 0 ? location.speed : 0
        }
    }
    
    private func updateCurrentStep() {
        guard let route = currentRoute else { return }
        
        if currentStepIndex < route.steps.count {
            currentStep = route.steps[currentStepIndex]
            nextStep = currentStepIndex + 1 < route.steps.count ? route.steps[currentStepIndex + 1] : nil
        } else {
            currentStep = nil
            nextStep = nil
        }
    }
    
    private func announceGuidanceStart() {
        guard let route = currentRoute else { return }
        
        let message = "guidance_started".localized(arguments: route.name)
        announceMessage(message)
    }
    
    private func announceCurrentStep() {
        guard let step = currentStep else { return }
        
        let message = formatStepInstruction(step)
        announceMessage(message)
        
        // Provide haptic feedback for step
        if isHapticEnabled {
            provideStepHapticFeedback(for: step)
        }
    }
    
    private func announceApproachingStep() {
        guard let step = currentStep else { return }
        
        let message = "approaching_step".localized(arguments: formatStepInstruction(step))
        announceMessage(message)
    }
    
    private func announceMessage(_ message: String) {
        guard isVoiceEnabled && voiceServiceAvailable else { 
            print("🔇 Voice announcement skipped: \(message)")
            return 
        }
        
        guard let synthesizer = speechSynthesizer else { return }
        
        // Stop any ongoing speech
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = voiceSettings.voice
        utterance.rate = voiceSettings.rate
        utterance.volume = voiceSettings.volume
        utterance.pitchMultiplier = voiceSettings.pitch
        
        synthesizer.speak(utterance)
    }
    
    private func formatStepInstruction(_ step: RouteStep) -> String {
        var instruction = step.instruction
        
        // Add distance information
        if step.distance > 0 {
            let distanceText = formatDistance(step.distance)
            instruction = "\(distanceText) \(instruction)"
        }
        
        // Add lane guidance if available
        if let laneGuidance = step.laneGuidance {
            instruction += " \(formatLaneGuidance(laneGuidance))"
        }
        
        return instruction
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    private func formatLaneGuidance(_ guidance: LaneGuidance) -> String {
        let activeLanes = guidance.activeLanes.map { String($0) }.joined(separator: ", ")
        return "lanes".localized(arguments: activeLanes)
    }
    
    private func provideStepHapticFeedback(for step: RouteStep) {
        switch step.maneuverType {
        case .turnLeft, .turnRight:
            HapticFeedback.shared.impact(style: .medium)
        case .uTurn:
            HapticFeedback.shared.impact(style: .heavy)
        case .merge, .exit:
            HapticFeedback.shared.impact(style: .light)
        case .toll:
            HapticFeedback.shared.impact(style: .light)
        default:
            HapticFeedback.shared.impact(style: .light)
        }
    }
    
    private func completeGuidance() {
        stopGuidance()
        
        // Announce completion
        announceMessage("guidance_complete".localized)
        
        // Provide completion haptic feedback
        if isHapticEnabled {
            HapticFeedback.shared.impact(style: .heavy)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension GuidanceService: @preconcurrency CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            updateLocation(location)
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = error
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension GuidanceService: AVSpeechSynthesizerDelegate {
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = true
        }
    }
    
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
    
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}

// MARK: - Guidance Mode

public enum GuidanceMode: String, CaseIterable, Codable {
    case standard
    case detailed
    case minimal
    
    public var displayName: String {
        switch self {
        case .standard: "Standard"
        case .detailed: "Detailed"
        case .minimal: "Minimal"
        }
    }
    
    public var description: String {
        switch self {
        case .standard: "Balanced voice guidance with key instructions"
        case .detailed: "Comprehensive voice guidance with all details"
        case .minimal: "Essential voice guidance only"
        }
    }
}

// MARK: - Voice Settings

private struct VoiceSettings {
    var voice: AVSpeechSynthesisVoice {
        AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice()
    }
    
    var rate: Float = 0.5
    var volume: Float = 0.8
    var pitch: Float = 1.0
}

// MARK: - Haptic Settings

private struct HapticSettings {
    var stepImpactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    var warningImpactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .heavy
    var successImpactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
}
