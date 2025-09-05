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
                AppleColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppleSpacing.xl) {
                        // Header
                        headerSection
                        
                        // Form
                        formSection
                        
                        // Action Buttons
                        actionButtons
                        
                        // Toggle Sign Up/Sign In
                        toggleSection
                    }
                    .padding(.horizontal, AppleSpacing.lg)
                    .padding(.top, AppleSpacing.xl)
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
                    .foregroundColor(AppleColors.brandPrimary)
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
        VStack(spacing: AppleSpacing.lg) {
            // App Icon
            ZStack {
                Circle()
                    .fill(AppleColors.brandGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(AppleColors.glassInnerHighlight, lineWidth: 2)
                            .blendMode(.overlay)
                    )
                    .appleShadow(AppleShadows.glass)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: AppleSpacing.sm) {
                Text(isSignUp ? "Join Shvil" : "Welcome Back")
                    .font(AppleTypography.title1)
                    .foregroundColor(AppleColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(isSignUp ? "Create your account to start exploring" : "Sign in to continue your adventures")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, AppleSpacing.lg)
    }
    
    private var formSection: some View {
        VStack(spacing: AppleSpacing.lg) {
            // Email Field
            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                Text("Email")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(AppleTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                Text("Password")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(AppleTextFieldStyle())
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: AppleSpacing.md) {
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
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.brandPrimary)
            }
        }
    }
    
    private var toggleSection: some View {
        HStack(spacing: AppleSpacing.xs) {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textSecondary)
            
            Button(isSignUp ? "Sign In" : "Sign Up") {
                withAnimation(AppleAnimations.spring) {
                    isSignUp.toggle()
                    errorMessage = ""
                }
            }
            .font(AppleTypography.bodyEmphasized)
            .foregroundColor(AppleColors.brandPrimary)
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
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                            .fill(AppleColors.glassMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                    .stroke(AppleColors.glassLight, lineWidth: 1)
                            )
                    )
            )
            .appleShadow(AppleShadows.light)
    }
}

#Preview {
    LoginView()
}
