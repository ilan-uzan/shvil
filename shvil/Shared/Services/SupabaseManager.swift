//
//  SupabaseManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Supabase

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastError: Error?
    
    enum ConnectionStatus {
        case connected
        case disconnected
        case connecting
        case error(String)
    }
    
    private init() {
        // Validate configuration before initializing
        if !Config.validateConfiguration() {
            print("⚠️ Supabase configuration validation failed")
        }
        
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.Supabase.projectURL)!,
            supabaseKey: Config.Supabase.anonKey
        )
        
        // Test connection on initialization
        Task {
            await testConnection()
        }
    }
    
    // MARK: - Connection Testing
    
    /// Test the Supabase connection
    func testConnection() async {
        connectionStatus = .connecting
        lastError = nil
        
        do {
            // Test connection by trying to fetch from a system table
            // This is a safe operation that doesn't require authentication
            let response = try await client
                .from("_supabase_migrations")
                .select("version")
                .limit(1)
                .execute()
            
            // If we get here without error, connection is working
            connectionStatus = .connected
            print("✅ Supabase connection successful")
            
        } catch {
            connectionStatus = .error(error.localizedDescription)
            lastError = error
            print("❌ Supabase connection failed: \(error.localizedDescription)")
        }
    }
    
    /// Get connection status as a human-readable string
    var connectionStatusText: String {
        switch connectionStatus {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    /// Check if connection is healthy
    var isConnected: Bool {
        if case .connected = connectionStatus {
            return true
        }
        return false
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up with email and password
    func signUp(email: String, password: String) async throws -> AuthResponse {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )
        return response
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let response = try await client.auth.signIn(
            email: email,
            password: password
        )
        return response
    }
    
    /// Sign out current user
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    /// Get current user session
    var currentUser: User? {
        return client.auth.currentUser
    }
    
    /// Check if user is signed in
    var isSignedIn: Bool {
        return currentUser != nil
    }
    
    // MARK: - Database Methods
    
    /// Generic method to fetch data from a table
    func fetch<T: Codable>(from table: String, type: T.Type) async throws -> [T] {
        let response: [T] = try await client
            .from(table)
            .select()
            .execute()
            .value
        return response
    }
    
    /// Generic method to insert data into a table
    func insert<T: Codable>(into table: String, data: T) async throws -> T {
        let response: T = try await client
            .from(table)
            .insert(data)
            .select()
            .single()
            .execute()
            .value
        return response
    }
    
    /// Generic method to update data in a table
    func update<T: Codable>(in table: String, id: UUID, data: T) async throws -> T {
        let response: T = try await client
            .from(table)
            .update(data)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
        return response
    }
    
    /// Generic method to delete data from a table
    func delete(from table: String, id: UUID) async throws {
        try await client
            .from(table)
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Health Check
    
    /// Perform a comprehensive health check
    func performHealthCheck() async -> HealthCheckResult {
        var results: [String: Bool] = [:]
        
        // Test basic connection
        await testConnection()
        results["Connection"] = isConnected
        
        // Test authentication service
        do {
            // This is a safe operation that tests auth service availability
            _ = try await client.auth.getSession()
            results["Authentication"] = true
        } catch {
            results["Authentication"] = false
        }
        
        // Test database access
        do {
            _ = try await client
                .from("_supabase_migrations")
                .select("version")
                .limit(1)
                .execute()
            results["Database"] = true
        } catch {
            results["Database"] = false
        }
        
        let allHealthy = results.values.allSatisfy { $0 }
        return HealthCheckResult(
            isHealthy: allHealthy,
            results: results,
            timestamp: Date()
        )
    }
}

// MARK: - Health Check Result
struct HealthCheckResult {
    let isHealthy: Bool
    let results: [String: Bool]
    let timestamp: Date
    
    var summary: String {
        let healthyCount = results.values.filter { $0 }.count
        let totalCount = results.count
        return "\(healthyCount)/\(totalCount) services healthy"
    }
}
