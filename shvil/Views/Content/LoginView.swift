//
//  LoginView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authService = DependencyContainer.shared.authenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        // Header
                        headerSection
                        
                        // Form
                        formSection
                        
                        // Action Buttons
                        VStack(spacing: DesignTokens.Spacing.md) {
                            GlassButton(
                                isSignUp ? "Create Account" : "Sign In",
                                style: .primary,
                                size: .large,
                                isLoading: isLoading,
                                isDisabled: email.isEmpty || password.isEmpty
                            ) {
                                Task {
                                    await performAuth()
                                }
                            }
                            
                            if !isSignUp {
                                GlassButton(
                                    "Sign in with Apple",
                                    icon: "applelogo",
                                    style: .secondary,
                                    size: .large
                                ) {
                                    // TODO: Implement Apple Sign In
                                }
                            }
                        }
                        
                        // Toggle Sign Up/Sign In
                        toggleSection
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.xl)
                }
            }
            .appleNavigationBar()
            .navigationTitle(isSignUp ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Brand.primary)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // App Icon
            ZStack {
                Circle()
                    .fill(DesignTokens.Brand.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 2)
                            .blendMode(.overlay)
                    )
                    .appleShadow(DesignTokens.Shadow.glass)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(isSignUp ? "Join Shvil" : "Welcome Back")
                    .font(DesignTokens.Typography.title)
                    .foregroundColor(DesignTokens.Text.primary)
                    .multilineTextAlignment(.center)
                
                Text(isSignUp ? "Create your account to start exploring" : "Sign in to continue your adventures")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.lg)
    }
    
    private var formSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Email Field
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Email")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(AppleTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Password")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(AppleTextFieldStyle())
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            AppleButton(
                isSignUp ? "Create Account" : "Sign In",
                icon: isSignUp ? "person.badge.plus" : "person.circle",
                style: .primary,
                size: .large,
                isLoading: isLoading
            ) {
                Task {
                    await performAuth()
                }
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            
            if !isSignUp {
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Brand.primary)
            }
        }
    }
    
    private var toggleSection: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)
            
            Button(isSignUp ? "Sign In" : "Sign Up") {
                withAnimation(DesignTokens.Animation.spring) {
                    isSignUp.toggle()
                    errorMessage = ""
                }
            }
            .font(DesignTokens.Typography.bodyEmphasized)
            .foregroundColor(DesignTokens.Brand.primary)
        }
    }
    
    private func performAuth() async {
        isLoading = true
        errorMessage = ""
        
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password, displayName: email.components(separatedBy: "@").first ?? "User")
            } else {
                try await authService.signIn(email: email, password: password)
            }
            
            // Success - dismiss the view
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

// MARK: - Custom Text Field Style

struct AppleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(DesignTokens.Glass.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                    .stroke(DesignTokens.Glass.light, lineWidth: 1)
                            )
                    )
            )
            .appleShadow(DesignTokens.Shadow.light)
    }
}

#Preview {
    LoginView()
}
