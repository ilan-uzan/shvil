//
//  SignInView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Sign in to sync your data across devices")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
                
                // Sign In Button
                Button(action: signIn) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        Text("Sign In")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidInput ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isValidInput || isLoading)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Footer
                VStack(spacing: 16) {
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            // Show sign up
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func signIn() {
        guard isValidInput else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Note: This will work once Supabase package is added
                // let response = try await supabaseManager.signIn(email: email, password: password)
                
                // Temporary: Simulate successful sign in
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(SupabaseManager.shared)
}
