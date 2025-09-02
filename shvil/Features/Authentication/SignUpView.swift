//
//  SignUpView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Join Shvil to sync your data across devices")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your name", text: $displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
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
                        
                        SecureField("Create a password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
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
                
                // Sign Up Button
                Button(action: signUp) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "person.badge.plus")
                        }
                        Text("Create Account")
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
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign In") {
                            // Show sign in
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                    
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Account Created!", isPresented: $showSuccess) {
            Button("Continue") {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully. You can now sync your data across devices.")
        }
    }
    
    private var isValidInput: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        email.contains("@") &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUp() {
        guard isValidInput else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Note: This will work once Supabase package is added
                // let response = try await supabaseManager.signUp(email: email, password: password)
                
                // Temporary: Simulate successful sign up
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
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
    SignUpView()
        .environmentObject(SupabaseManager.shared)
}
