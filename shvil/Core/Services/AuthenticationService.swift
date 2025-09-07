//
//  AuthenticationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine
import Supabase

/// Centralized authentication service with session persistence
@MainActor
class AuthenticationService: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let supabaseClient: SupabaseClient
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private enum KeychainKeys {
        static let accessToken = "supabase_access_token"
        static let refreshToken = "supabase_refresh_token"
        static let userData = "user_data"
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize Supabase client
        if Configuration.isSupabaseConfigured {
            guard let url = URL(string: Configuration.supabaseURL) else {
                fatalError("Invalid Supabase URL: \(Configuration.supabaseURL)")
            }
            self.supabaseClient = SupabaseClient(supabaseURL: url, supabaseKey: Configuration.supabaseAnonKey)
            
            // Setup auth state listener
            Task {
                await setupAuthStateListener()
            }
            
            // Restore session on init
            Task {
                await restoreSession()
            }
        } else {
            // Create a mock client for demo mode
            guard let url = URL(string: "https://demo.supabase.co") else {
                fatalError("Invalid demo URL")
            }
            self.supabaseClient = SupabaseClient(supabaseURL: url, supabaseKey: "demo-key")
            
            // Set as not authenticated in demo mode
            isAuthenticated = false
            print("⚠️ WARNING: Supabase not configured. Running in demo mode.")
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        if !Configuration.isSupabaseConfigured {
            // Demo mode - simulate successful sign in
            print("Demo mode: Simulating sign in for \(email)")
            isAuthenticated = true
            isLoading = false
            return
        }
        
        do {
            let response = try await supabaseClient.auth.signIn(email: email, password: password)
            
            await handleSuccessfulAuth(user: response.user, session: response)
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Sign up with email and password
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabaseClient.auth.signUp(
                email: email,
                password: password,
                data: ["display_name": AnyJSON.string(displayName)]
            )
            
            if let session = response.session {
                await handleSuccessfulAuth(user: response.user, session: session)
            } else {
                errorMessage = "Sign up failed: No session received"
            }
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Sign out and clear session
    func signOut() async {
        isLoading = true
        
        do {
            try await supabaseClient.auth.signOut()
            await clearSession()
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Reset password
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseClient.auth.resetPasswordForEmail(email)
            errorMessage = "Password reset email sent"
        } catch {
            errorMessage = "Password reset failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func setupAuthStateListener() async {
        // Listen for auth state changes
        await supabaseClient.auth.onAuthStateChange { [weak self] event, session in
            Task { @MainActor in
                switch event {
                case .signedIn:
                    if let session = session {
                        await self?.handleSuccessfulAuth(user: session.user, session: session)
                    }
                case .signedOut:
                    await self?.clearSession()
                case .tokenRefreshed:
                    if let session = session {
                        await self?.saveSession(session)
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func handleSuccessfulAuth(user: Auth.User, session: Session) async {
        // Convert to our AuthUser model
        let userModel = AuthUser(
            id: UUID(uuidString: user.id.uuidString) ?? UUID(),
            email: user.email ?? "",
            displayName: extractString(from: user.userMetadata["display_name"]) ?? user.email ?? "",
            avatarURL: extractString(from: user.userMetadata["avatar_url"]),
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        )
        
        // Update state
        currentUser = userModel
        isAuthenticated = true
        
        // Save session
        await saveSession(session)
        
        // Clear any error messages
        errorMessage = nil
    }
    
    private func saveSession(_ session: Session) async {
        // Save tokens to UserDefaults (in production, use Keychain for security)
        userDefaults.set(session.accessToken, forKey: KeychainKeys.accessToken)
        userDefaults.set(session.refreshToken, forKey: KeychainKeys.refreshToken)
        
        // Save user data
        if let userData = try? JSONEncoder().encode(currentUser) {
            userDefaults.set(userData, forKey: KeychainKeys.userData)
        }
    }
    
    private func clearSession() async {
        // Clear UserDefaults
        userDefaults.removeObject(forKey: KeychainKeys.accessToken)
        userDefaults.removeObject(forKey: KeychainKeys.refreshToken)
        userDefaults.removeObject(forKey: KeychainKeys.userData)
        
        // Clear state
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    private func restoreSession() async {
        // Check if we have stored tokens
        guard let accessToken = userDefaults.string(forKey: KeychainKeys.accessToken),
              let refreshToken = userDefaults.string(forKey: KeychainKeys.refreshToken) else {
            return
        }
        
        // Try to restore session
        do {
            let session = try await supabaseClient.auth.setSession(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
            
            await handleSuccessfulAuth(user: session.user, session: session)
        } catch {
            // Session is invalid, clear it
            await clearSession()
        }
    }
    
    private func extractString(from anyJSON: AnyJSON?) -> String? {
        guard let anyJSON = anyJSON else { return nil }
        switch anyJSON {
        case .string(let value):
            return value
        case .double(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        default:
            return nil
        }
    }
}

// MARK: - AuthUser Model

struct AuthUser: Codable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Error Handling

extension AuthenticationService {
    func clearError() {
        errorMessage = nil
    }
}
