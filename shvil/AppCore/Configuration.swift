//
//  Configuration.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation

/// App configuration management
public struct Configuration {
    // MARK: - Supabase Configuration
    public static let supabaseURL: String = {
        // Try to get from environment variable first
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
            return url
        }
        
        // Fallback to placeholder for development
        return "https://placeholder.supabase.co"
    }()
    
    public static let supabaseAnonKey: String = {
        // Try to get from environment variable first
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            return key
        }
        
        // Fallback to placeholder for development
        return "placeholder-key"
    }()
    
    // MARK: - OpenAI Configuration
    public static let openAIAPIKey: String = {
        // Try to get from environment variable first
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return key
        }
        
        // Fallback to placeholder for development
        return "your-openai-api-key-here"
    }()
    
    // MARK: - App Configuration
    public static let isDevelopment: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    public static let isProduction: Bool = {
        return !isDevelopment
    }()
    
    // MARK: - Validation
    public static var isSupabaseConfigured: Bool {
        return supabaseURL != "https://placeholder.supabase.co" && 
               supabaseAnonKey != "placeholder-key" &&
               !supabaseURL.isEmpty && 
               !supabaseAnonKey.isEmpty
    }
    
    public static var isOpenAIConfigured: Bool {
        return openAIAPIKey != "your-openai-api-key-here" && !openAIAPIKey.isEmpty
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
            return "Supabase is not properly configured. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables."
        case .openAINotConfigured:
            return "OpenAI is not properly configured. Please set OPENAI_API_KEY environment variable."
        case .invalidURL:
            return "Invalid URL configuration."
        case .missingAPIKey:
            return "Missing required API key."
        }
    }
}
