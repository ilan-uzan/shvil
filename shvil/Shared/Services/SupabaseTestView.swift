//
//  SupabaseTestView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import Supabase

struct SupabaseTestView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var connectionStatus = "Testing connection..."
    @State private var isConnected = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Supabase Connection Test")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(connectionStatus)
                    .font(.body)
            }
            
            Button("Test Connection") {
                testConnection()
            }
            .buttonStyle(.borderedProminent)
            .disabled(connectionStatus == "Testing connection...")
        }
        .padding()
        .onAppear {
            testConnection()
        }
    }
    
    private func testConnection() {
        connectionStatus = "Testing connection..."
        isConnected = false
        
        Task {
            do {
                // Simple test query to check connection
                let response = try await supabaseManager.client
                    .from("_supabase_migrations")
                    .select("version")
                    .limit(1)
                    .execute()
                
                await MainActor.run {
                    connectionStatus = "✅ Connected successfully!"
                    isConnected = true
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "❌ Connection failed: \(error.localizedDescription)"
                    isConnected = false
                }
            }
        }
    }
}

#Preview {
    SupabaseTestView()
}
