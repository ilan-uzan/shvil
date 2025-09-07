//
//  Configuration.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation

/// App configuration management
public enum Configuration {
    // MARK: - Supabase Configuration

    public static let supabaseURL: String = {
        // Try to get from environment variable first
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
            return url
        }

        // Fallback to a working demo URL for development
        return "https://demo.supabase.co"
    }()

    public static let supabaseAnonKey: String = {
        // Try to get from environment variable first
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            return key
        }

        // Fallback to demo key for development
        return "demo-key"
    }()

    // MARK: - OpenAI Configuration

    public static let openAIAPIKey: String = {
        // Try to get from environment variable first
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            // Validate the key format to ensure it's a real OpenAI key
            if isValidOpenAIKey(key) {
                return key
            } else {
                print("⚠️ WARNING: Invalid OpenAI API key format detected")
                return "invalid-key-format"
            }
        }

        // Fallback to placeholder for development
        return "your-openai-api-key-here"
    }()

    // MARK: - Key Validation

    private static func isValidOpenAIKey(_ key: String) -> Bool {
        // OpenAI API keys typically start with 'sk-' and are 51 characters long
        key.hasPrefix("sk-") && key.count == 51
    }

    // MARK: - Secure Key Access

    public static func getOpenAIKey() throws -> String {
        guard isOpenAIConfigured else {
            throw ConfigurationError.openAINotConfigured
        }

        let key = openAIAPIKey

        // Additional security check
        guard key != "invalid-key-format" else {
            throw ConfigurationError.missingAPIKey
        }

        return key
    }

    // MARK: - App Configuration

    public static let isDevelopment: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()

    public static let isProduction: Bool = !isDevelopment

    // MARK: - Validation

    public static var isSupabaseConfigured: Bool {
        supabaseURL != "https://demo.supabase.co" &&
            supabaseAnonKey != "demo-key" &&
            !supabaseURL.isEmpty &&
            !supabaseAnonKey.isEmpty
    }

    public static var isOpenAIConfigured: Bool {
        openAIAPIKey != "your-openai-api-key-here" && !openAIAPIKey.isEmpty
    }

    // MARK: - Database Configuration

    public static let databaseName = "shvil.db"
    public static let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    public static let maxRetryAttempts = 3
    public static let requestTimeout: TimeInterval = 30.0
}

// MARK: - Configuration Errors

enum ConfigurationError: LocalizedError {
    case supabaseNotConfigured
    case openAINotConfigured
    case invalidURL
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .supabaseNotConfigured:
            "Supabase is not properly configured. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables."
        case .openAINotConfigured:
            "OpenAI is not properly configured. Please set OPENAI_API_KEY environment variable."
        case .invalidURL:
            "Invalid URL configuration."
        case .missingAPIKey:
            "Missing required API key."
        }
    }
}
