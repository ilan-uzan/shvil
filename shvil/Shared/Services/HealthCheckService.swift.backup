//
//  HealthCheckService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Supabase

/// Service for monitoring database and API health
@MainActor
class HealthCheckService: ObservableObject {
    static let shared = HealthCheckService()
    
    @Published var isHealthy = false
    @Published var lastCheckTime: Date?
    @Published var lastError: Error?
    @Published var services: [String: Bool] = [:]
    @Published var systemMetrics: SystemMetrics?
    
    private let supabaseService: SupabaseService
    
    private init() {
        self.supabaseService = SupabaseService.shared
    }
    
    /// Perform basic health check
    func checkHealth() async {
        do {
            let response: HealthCheckResponse = try await supabaseService.client
                .rpc("health_check")
                .execute()
                .value
            
            isHealthy = response.status == "healthy"
            lastCheckTime = response.timestamp
            lastError = nil
            
            // Update services status
            services = [
                "database": response.services.database,
                "realtime": response.services.realtime
            ]
            
            print("Health check completed: \(response.status)")
        } catch {
            isHealthy = false
            lastError = error
            print("Health check failed: \(error)")
        }
    }
    
    /// Perform detailed health check with system metrics
    func checkDetailedHealth() async {
        do {
            let response: DetailedHealthCheckResponse = try await supabaseService.client
                .rpc("health_check_detailed")
                .execute()
                .value
            
            isHealthy = response.status == "healthy"
            lastCheckTime = response.timestamp
            lastError = nil
            
            // Update services status
            services = [
                "database": response.services.database,
                "realtime": response.services.realtime,
                "auth": response.services.auth,
                "storage": response.services.storage
            ]
            
            print("Detailed health check completed: \(response.status)")
        } catch {
            isHealthy = false
            lastError = error
            print("Detailed health check failed: \(error)")
        }
    }
    
    /// Get system metrics
    func getSystemMetrics() async {
        do {
            let response: SystemMetrics = try await supabaseService.client
                .rpc("get_system_metrics")
                .execute()
                .value
            
            systemMetrics = response
            print("System metrics updated: \(response.databaseSize)")
        } catch {
            print("Failed to get system metrics: \(error)")
        }
    }
    
    /// Start periodic health monitoring
    func startMonitoring(interval: TimeInterval = 300) { // 5 minutes default
        Task {
            while true {
                await checkHealth()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
}

// MARK: - Response Models

struct HealthCheckResponse: Codable {
    let status: String
    let timestamp: Date
    let services: ServicesStatus
    let version: String
    let error: String?
}

struct DetailedHealthCheckResponse: Codable {
    let status: String
    let timestamp: Date
    let services: DetailedServicesStatus
    let version: String
    let environment: String?
    let tableCounts: [String: Int]
    let errors: [String]
}

struct ServicesStatus: Codable {
    let database: Bool
    let realtime: Bool
}

struct DetailedServicesStatus: Codable {
    let database: Bool
    let realtime: Bool
    let auth: Bool
    let storage: Bool
}

struct SystemMetrics: Codable {
    let databaseSize: String
    let activeConnections: Int
    let maxConnections: Int
    let timestamp: Date
}

// MARK: - Health Status View

import SwiftUI

struct ServiceStatusRow: View {
    let service: String
    let isHealthy: Bool
    
    var body: some View {
        HStack {
            Text(service.capitalized)
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textPrimary)
            
            Spacer()
            
            Image(systemName: isHealthy ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isHealthy ? .green : .red)
        }
    }
}

struct HealthStatusView: View {
    @StateObject private var healthService = HealthCheckService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("System Health")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
                
                Spacer()
                
                Circle()
                    .fill(healthService.isHealthy ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
            }
            
            if let lastCheck = healthService.lastCheckTime {
                Text("Last checked: \(lastCheck, formatter: timeFormatter)")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }
            
            // Services status
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(healthService.services.keys.sorted()), id: \.self) { service in
                    ServiceStatusRow(service: service, isHealthy: healthService.services[service] ?? false)
                }
            }
            
            // System metrics
            if let metrics = healthService.systemMetrics {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Metrics")
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)
                    
                    Text("Database: \(metrics.databaseSize)")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                    
                    Text("Connections: \(metrics.activeConnections)/\(metrics.maxConnections)")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
            }
            
            // Error display
            if let error = healthService.lastError {
                Text("Error: \(error.localizedDescription)")
                    .font(AppleTypography.caption1)
                    .foregroundColor(.red)
            }
            
            // Refresh button
            Button("Refresh") {
                Task {
                    await healthService.checkDetailedHealth()
                    await healthService.getSystemMetrics()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppleColors.surfaceTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            Task {
                await healthService.checkDetailedHealth()
                await healthService.getSystemMetrics()
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    HealthStatusView()
        .preferredColorScheme(.dark)
}
