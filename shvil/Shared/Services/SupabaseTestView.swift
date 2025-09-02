//
//  SupabaseTestView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SupabaseTestView: View {
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @State private var healthStatus = ""
    @State private var isTestingConnection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Connection Status
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: supabaseManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(supabaseManager.isConnected ? .green : .red)
                            .font(.title)
                        
                        VStack(alignment: .leading) {
                            Text("Supabase Connection")
                                .font(.headline)
                            Text(supabaseManager.isConnected ? "Connected" : "Disconnected")
                                .foregroundColor(supabaseManager.isConnected ? .green : .red)
                        }
                        
                        Spacer()
                    }
                    
                    // Test Connection Button
                    Button(action: {
                        isTestingConnection = true
                        Task {
                            await supabaseManager.testConnection()
                            isTestingConnection = false
                        }
                    }) {
                        HStack {
                            if isTestingConnection {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "link")
                                    .foregroundColor(.white)
                            }
                            Text(isTestingConnection ? "Testing..." : "Test Connection")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isTestingConnection)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Configuration Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configuration")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Project URL:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(Config.projectURL)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Anon Key:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Config.anonKey.prefix(20))...")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Health Status
                if !healthStatus.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Status")
                            .font(.headline)
                        
                        Text(healthStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Supabase Test")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    healthStatus = await supabaseManager.getHealthStatus()
                }
            }
        }
    }
}

#Preview {
    SupabaseTestView()
        .environmentObject(SupabaseManager.shared)
}