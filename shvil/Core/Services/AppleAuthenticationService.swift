//
//  AppleAuthenticationService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

/// Apple Sign-in authentication service with fallback support
@MainActor
public class AppleAuthenticationService: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?
    @Published public var isLoading = false
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private let supabaseService: SupabaseService
    private let featureFlags: FeatureFlags
    private var currentNonce: String?
    
    // MARK: - Initialization
    
    public init(supabaseService: SupabaseService, featureFlags: FeatureFlags) {
        self.supabaseService = supabaseService
        self.featureFlags = featureFlags
        super.init()
        
        // Check if user is already authenticated
        checkAuthenticationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Sign in with Apple
    public func signInWithApple() async throws {
        guard featureFlags.isEnabled(.appleSignIn) else {
            throw AuthenticationError.appleSignInNotAvailable
        }
        
        isLoading = true
        error = nil
        
        do {
            let nonce = generateNonce()
            currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with email and password (fallback)
    public func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.signIn(email: email, password: password)
            
            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign up with email and password
    public func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.signUp(email: email, password: password)
            
            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with magic link
    public func signInWithMagicLink(email: String) async throws {
        guard featureFlags.isEnabled(.magicLink) else {
            throw AuthenticationError.magicLinkNotAvailable
        }
        
        isLoading = true
        error = nil
        
        do {
            // This would typically call a Supabase magic link function
            // For now, we'll simulate the process
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                self.isLoading = false
            }
            
            // In a real implementation, you'd handle the magic link callback
            // and verify the token with Supabase
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign out
    public func signOut() async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.signOut()
            
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Check if Apple Sign-in is available
    public var isAppleSignInAvailable: Bool {
        return featureFlags.isEnabled(.appleSignIn) // Apple Sign In is always available on iOS
    }
    
    /// Check if magic link is available
    public var isMagicLinkAvailable: Bool {
        return featureFlags.isEnabled(.magicLink)
    }
    
    // MARK: - Private Methods
    
    private func checkAuthenticationStatus() {
        // Check if user is already authenticated with Supabase
        // This would typically check the Supabase session
        Task {
            // Simulate checking authentication status
            await MainActor.run {
                self.isAuthenticated = false // Will be updated based on actual session
            }
        }
    }
    
    private func generateNonce() -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = 32
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func handleAppleSignInResult(_ result: ASAuthorization) async {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            await MainActor.run {
                self.error = AuthenticationError.invalidAppleCredential
                self.isLoading = false
            }
            return
        }
        
        guard let nonce = currentNonce else {
            await MainActor.run {
                self.error = AuthenticationError.missingNonce
                self.isLoading = false
            }
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            await MainActor.run {
                self.error = AuthenticationError.missingAppleIDToken
                self.isLoading = false
            }
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            await MainActor.run {
                self.error = AuthenticationError.invalidAppleIDToken
                self.isLoading = false
            }
            return
        }
        
        do {
            // In a real implementation, you'd verify the Apple ID token with Supabase
            // For now, we'll simulate a successful authentication
            
            let user = User(
                id: UUID(),
                email: appleIDCredential.email ?? "user@privaterelay.appleid.com",
                displayName: [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " "),
                avatarUrl: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = user
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthenticationService: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            await handleAppleSignInResult(authorization)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            self.error = error
            self.isLoading = false
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthenticationService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign-in presentation")
        }
        return window
    }
}


// MARK: - Authentication Errors

public enum AuthenticationError: LocalizedError {
    case appleSignInNotAvailable
    case magicLinkNotAvailable
    case invalidAppleCredential
    case missingNonce
    case missingAppleIDToken
    case invalidAppleIDToken
    case authenticationFailed
    case networkError
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .appleSignInNotAvailable:
            return "Apple Sign-in is not available. Please use email and password instead."
        case .magicLinkNotAvailable:
            return "Magic link authentication is not available."
        case .invalidAppleCredential:
            return "Invalid Apple credential received."
        case .missingNonce:
            return "Missing nonce for Apple Sign-in."
        case .missingAppleIDToken:
            return "Missing Apple ID token."
        case .invalidAppleIDToken:
            return "Invalid Apple ID token."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .networkError:
            return "Network error occurred. Please check your connection."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
