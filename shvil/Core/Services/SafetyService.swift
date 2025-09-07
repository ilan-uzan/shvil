//
//  SafetyService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Combine
import CoreLocation
import Foundation
import MessageUI
import UIKit

/// Manages safety features including SOS and emergency contacts
@MainActor
public class SafetyService: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published public var isSOSActive = false
    @Published public var emergencyContacts: [EmergencyContact] = []
    @Published public var safetyReports: [SafetyReport] = []
    @Published public var isSharingLocation = false
    @Published public var lastKnownLocation: CLLocation?
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var sosTimer: Timer?
    private var locationSharingTimer: Timer?
    
    // MARK: - Constants
    
    private let emergencyNumbers = [
        "police": "100",
        "medical": "101",
        "fire": "102"
    ]
    
    private let sosDuration: TimeInterval = 10.0 // 10 seconds to cancel SOS
    private let locationSharingInterval: TimeInterval = 30.0 // Share location every 30 seconds
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupLocationManager()
        loadEmergencyContacts()
        loadSafetyReports()
    }
    
    // MARK: - Public Methods
    
    /// Activate SOS mode
    public func activateSOS() {
        guard !isSOSActive else { return }
        
        isSOSActive = true
        
        // Provide haptic feedback
        HapticFeedback.shared.impact(style: .heavy)
        
        // Start SOS timer
        sosTimer = Timer.scheduledTimer(withTimeInterval: sosDuration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.executeSOS()
            }
        }
        
        // Start location sharing
        startLocationSharing()
        
        // Notify emergency contacts
        notifyEmergencyContacts()
    }
    
    /// Cancel SOS mode
    public func cancelSOS() {
        guard isSOSActive else { return }
        
        isSOSActive = false
        sosTimer?.invalidate()
        sosTimer = nil
        stopLocationSharing()
        
        // Provide confirmation haptic
        HapticFeedback.shared.impact(style: .light)
    }
    
    /// Add emergency contact
    public func addEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.append(contact)
        saveEmergencyContacts()
    }
    
    /// Remove emergency contact
    public func removeEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.removeAll { $0.id == contact.id }
        saveEmergencyContacts()
    }
    
    /// Update emergency contact
    public func updateEmergencyContact(_ contact: EmergencyContact) {
        if let index = emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
            emergencyContacts[index] = contact
            saveEmergencyContacts()
        }
    }
    
    /// Report safety incident
    public func reportSafetyIncident(_ report: SafetyReport) {
        safetyReports.append(report)
        saveSafetyReports()
        
        // Notify other users in the area (if connected to network)
        broadcastSafetyReport(report)
    }
    
    /// Get safety reports near location
    public func getSafetyReports(near location: CLLocation, radius: Double = 1000) -> [SafetyReport] {
        return safetyReports.filter { report in
            let reportLocation = CLLocation(latitude: report.latitude, longitude: report.longitude)
            return location.distance(from: reportLocation) <= radius
        }
    }
    
    /// Check if route is safe for night travel
    public func isRouteSafeForNight(_ route: Route) -> Bool {
        // Check for recent safety reports along the route
        let recentReports = safetyReports.filter { report in
            let reportAge = Date().timeIntervalSince(report.createdAt)
            return reportAge < 3600 // Reports from last hour
        }
        
        // Check if any reports are near the route
        for report in recentReports {
            let reportLocation = CLLocation(latitude: report.latitude, longitude: report.longitude)
            
            for coordinate in route.polyline {
                let routeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                if reportLocation.distance(from: routeLocation) < 200 { // Within 200 meters
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Get well-lit route suggestions for night travel
    public func getWellLitRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Route? {
        // This would typically integrate with a routing service that considers lighting
        // For now, return nil as this requires external data
        return nil
    }
    
    /// Share current location with emergency contacts
    public func shareLocationWithEmergencyContacts() {
        guard let location = lastKnownLocation else { return }
        
        let message = "Emergency: I need help. My location is: \(location.coordinate.latitude), \(location.coordinate.longitude). Time: \(Date())"
        
        for contact in emergencyContacts {
            sendLocationShareMessage(to: contact, message: message, location: location)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func executeSOS() {
        guard isSOSActive else { return }
        
        // Call emergency services
        callEmergencyServices()
        
        // Send location to emergency contacts
        shareLocationWithEmergencyContacts()
        
        // Provide strong haptic feedback
        HapticFeedback.shared.impact(style: .heavy)
        
        // Show SOS confirmation
        showSOSConfirmation()
    }
    
    private func callEmergencyServices() {
        // Call police (100 in Israel)
        if let policeNumber = emergencyNumbers["police"],
           let url = URL(string: "tel://\(policeNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func startLocationSharing() {
        guard isSOSActive else { return }
        
        locationSharingTimer = Timer.scheduledTimer(withTimeInterval: locationSharingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.shareLocationWithEmergencyContacts()
            }
        }
        
        isSharingLocation = true
    }
    
    private func stopLocationSharing() {
        locationSharingTimer?.invalidate()
        locationSharingTimer = nil
        isSharingLocation = false
    }
    
    private func notifyEmergencyContacts() {
        // Send initial notification to emergency contacts
        let message = "Emergency: SOS activated. Monitoring location for updates."
        
        for contact in emergencyContacts {
            sendNotification(to: contact, message: message)
        }
    }
    
    private func sendLocationShareMessage(to contact: EmergencyContact, message: String, location: CLLocation) {
        // Create SMS message with location
        let smsMessage = "\(message)\n\nLocation: https://maps.google.com/?q=\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        if MFMessageComposeViewController.canSendText() {
            let messageController = MFMessageComposeViewController()
            messageController.recipients = [contact.phoneNumber]
            messageController.body = smsMessage
            messageController.messageComposeDelegate = self
            
            // Present from the current view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(messageController, animated: true)
            }
        } else {
            // Fallback: open Messages app with pre-filled message
            let encodedMessage = smsMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "sms:\(contact.phoneNumber)&body=\(encodedMessage)") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func sendNotification(to contact: EmergencyContact, message: String) {
        // This would typically send a push notification
        // For now, we'll just log it
        print("Sending notification to \(contact.name): \(message)")
    }
    
    private func broadcastSafetyReport(_ report: SafetyReport) {
        // This would typically send the report to a server for distribution
        // For now, we'll just log it
        print("Broadcasting safety report: \(report.reportType) at \(report.latitude), \(report.longitude)")
    }
    
    private func showSOSConfirmation() {
        // Show alert confirming SOS was activated
        let alert = UIAlertController(
            title: "SOS Activated",
            message: "Emergency services have been contacted and your location is being shared with emergency contacts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func loadEmergencyContacts() {
        if let data = UserDefaults.standard.data(forKey: "emergency_contacts"),
           let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) {
            emergencyContacts = contacts
        }
    }
    
    private func saveEmergencyContacts() {
        if let data = try? JSONEncoder().encode(emergencyContacts) {
            UserDefaults.standard.set(data, forKey: "emergency_contacts")
        }
    }
    
    private func loadSafetyReports() {
        if let data = UserDefaults.standard.data(forKey: "safety_reports"),
           let reports = try? JSONDecoder().decode([SafetyReport].self, from: data) {
            safetyReports = reports
        }
    }
    
    private func saveSafetyReports() {
        if let data = try? JSONEncoder().encode(safetyReports) {
            UserDefaults.standard.set(data, forKey: "safety_reports")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension SafetyService: @preconcurrency CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            lastKnownLocation = location
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = error
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension SafetyService: MFMessageComposeViewControllerDelegate {
    nonisolated public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        Task { @MainActor in
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Emergency Contact Model

public struct EmergencyContact: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let phoneNumber: String
    public let relationship: String
    public let isPrimary: Bool
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        relationship: String,
        isPrimary: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.createdAt = createdAt
    }
}


// MARK: - Safety Report Type

public enum SafetyReportType: String, CaseIterable, Codable {
    case accident = "accident"
    case roadClosure = "road_closure"
    case construction = "construction"
    case hazard = "hazard"
    case police = "police"
    case emergency = "emergency"
    case weather = "weather"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .accident: "Accident"
        case .roadClosure: "Road Closure"
        case .construction: "Construction"
        case .hazard: "Hazard"
        case .police: "Police Activity"
        case .emergency: "Emergency"
        case .weather: "Weather"
        case .other: "Other"
        }
    }
    
    public var icon: String {
        switch self {
        case .accident: "exclamationmark.triangle.fill"
        case .roadClosure: "road.lanes"
        case .construction: "hammer.fill"
        case .hazard: "exclamationmark.octagon.fill"
        case .police: "shield.fill"
        case .emergency: "cross.fill"
        case .weather: "cloud.rain.fill"
        case .other: "questionmark.circle.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .accident: "red"
        case .roadClosure: "orange"
        case .construction: "yellow"
        case .hazard: "red"
        case .police: "blue"
        case .emergency: "red"
        case .weather: "blue"
        case .other: "gray"
        }
    }
}

// MARK: - Safety Severity

public enum SafetySeverity: String, CaseIterable, Codable {
    case low
    case medium
    case high
    case critical
    
    public var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .critical: "Critical"
        }
    }
    
    public var color: String {
        switch self {
        case .low: "green"
        case .medium: "yellow"
        case .high: "orange"
        case .critical: "red"
        }
    }
}
