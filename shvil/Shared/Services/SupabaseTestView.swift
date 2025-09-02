//
//  SupabaseTestView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SupabaseTestView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var healthCheckResult: HealthCheckResult?
    @State private var isRunningHealthCheck = false
    @State private var showConfigurationAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Supabase Connection Test")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Verify database connectivity and services")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Connection Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: connectionStatusIcon)
                                .foregroundColor(connectionStatusColor)
                            Text("Connection Status")
                                .font(.headline)
                            Spacer()
                            Text(supabaseManager.connectionStatusText)
                                .font(.subheadline)
                                .foregroundColor(connectionStatusColor)
                        }
                        
                        if let error = supabaseManager.lastError {
                            Text("Error: \(error.localizedDescription)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await supabaseManager.testConnection()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Test Connection")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            Task {
                                isRunningHealthCheck = true
                                healthCheckResult = await supabaseManager.performHealthCheck()
                                isRunningHealthCheck = false
                            }
                        }) {
                            HStack {
                                if isRunningHealthCheck {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "heart.text.square")
                                }
                                Text(isRunningHealthCheck ? "Running Health Check..." : "Full Health Check")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isRunningHealthCheck)
                        
                        Button(action: {
                            showConfigurationAlert = true
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Configuration Info")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Health Check Results
                    if let result = healthCheckResult {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: result.isHealthy ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(result.isHealthy ? .green : .red)
                                Text("Health Check Results")
                                    .font(.headline)
                                Spacer()
                                Text(result.summary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(Array(result.results.keys.sorted()), id: \.self) { service in
                                HStack {
                                    Image(systemName: result.results[service] == true ? "checkmark.circle" : "xmark.circle")
                                        .foregroundColor(result.results[service] == true ? .green : .red)
                                    Text(service)
                                    Spacer()
                                    Text(result.results[service] == true ? "Healthy" : "Unhealthy")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text("Last checked: \(result.timestamp, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Configuration Warning
                    if !Config.validateConfiguration() {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Configuration Warning")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Using placeholder Supabase configuration. Please update Config.swift with your actual project URL and anon key.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Database Test")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Configuration Information", isPresented: $showConfigurationAlert) {
                Button("OK") { }
            } message: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project URL: \(Config.Supabase.projectURL)")
                    Text("Anon Key: \(Config.Supabase.anonKey.prefix(20))...")
                    Text("")
                    Text("To update configuration:")
                    Text("1. Get your keys from Supabase dashboard")
                    Text("2. Update Config.swift with actual values")
                    Text("3. Never commit real keys to version control")
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var connectionStatusIcon: String {
        switch supabaseManager.connectionStatus {
        case .connected:
            return "checkmark.circle.fill"
        case .disconnected:
            return "circle"
        case .connecting:
            return "arrow.clockwise.circle"
        case .error:
            return "xmark.circle.fill"
        }
    }
    
    private var connectionStatusColor: Color {
        switch supabaseManager.connectionStatus {
        case .connected:
            return .green
        case .disconnected:
            return .gray
        case .connecting:
            return .blue
        case .error:
            return .red
        }
    }
}

#Preview {
    SupabaseTestView()
}