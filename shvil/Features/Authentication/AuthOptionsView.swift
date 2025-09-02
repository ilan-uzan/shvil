//
//  AuthOptionsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct AuthOptionsView: View {
    @State private var showSignIn = false
    @State private var showSignUp = false
    @State private var showGuestMode = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Choose Your Experience")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Sign in to sync your data across devices, or continue as a guest for a quick start.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Auth Options
                VStack(spacing: 16) {
                    // Sign In Button
                    Button(action: {
                        showSignIn = true
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Sign In")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        showSignUp = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Create Account")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Guest Mode Button
                    Button(action: {
                        showGuestMode = true
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                            Text("Continue as Guest")
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Privacy Note
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Privacy First")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Guest mode stores data locally on your device. Sign in to sync across devices.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .fullScreenCover(isPresented: $showGuestMode) {
            GuestModeView()
        }
    }
}

#Preview {
    AuthOptionsView()
}
