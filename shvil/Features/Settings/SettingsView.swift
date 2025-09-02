//
//  SettingsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var locationService: LocationService
    @State private var showSignOutAlert = false
    
    var body: some View {
        List {
            // User Section
            Section {
                HStack {
                    Image(systemName: authManager.isGuest ? "person.crop.circle.fill" : "person.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading) {
                        Text(authManager.userDisplayName)
                            .font(.headline)
                        Text(authManager.isGuest ? "Guest Mode" : "Signed In")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if authManager.isGuest {
                        Button("Sign In") {
                            // Show sign in
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Account")
            }
            
            // Location Section
            Section {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(locationService.isLocationEnabled ? .green : .orange)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading) {
                        Text("Location Access")
                            .font(.headline)
                        Text(locationService.isLocationEnabled ? "Enabled" : "Not Enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !locationService.isLocationEnabled {
                        Button("Enable") {
                            locationService.requestLocationPermission()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Permissions")
            }
            
            // Privacy Section
            Section {
                NavigationLink(destination: PrivacySettingsView()) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text("Privacy & Data")
                    }
                }
                
                NavigationLink(destination: DataManagementView()) {
                    HStack {
                        Image(systemName: "externaldrive.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Data Management")
                    }
                }
            } header: {
                Text("Privacy")
            }
            
            // App Section
            Section {
                NavigationLink(destination: AboutView()) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("About Shvil")
                    }
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .frame(width: 30)
                    Text("Rate Shvil")
                }
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Contact Support")
                }
            } header: {
                Text("App")
            }
            
            // Sign Out Section
            if authManager.isAuthenticated {
                Section {
                    Button(action: {
                        showSignOutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out? Your data will remain on this device.")
        }
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                    Text("Location Data")
                    Spacer()
                    Text("Local Only")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.orange)
                    Text("Community Reports")
                    Spacer()
                    Text("Anonymous")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "externaldrive.fill")
                        .foregroundColor(.blue)
                    Text("Saved Places")
                    Spacer()
                    Text("Local Storage")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Data Collection")
            } footer: {
                Text("Shvil collects minimal data and stores it locally on your device. Community reports are anonymous and expire automatically.")
            }
        }
        .navigationTitle("Privacy & Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @State private var showClearDataAlert = false
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    showClearDataAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Clear All Data")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("This will clear all saved places, recent searches, and other local data. This action cannot be undone.")
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Data", isPresented: $showClearDataAlert) {
            Button("Clear Data", role: .destructive) {
                // Clear data
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all your local data. Are you sure?")
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Shvil")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Text("Shvil is a lightweight, iOS-first navigation app that combines the clean polish of Apple Maps with the community feedback of Waze.")
                    .font(.body)
            } header: {
                Text("About")
            }
            
            Section {
                Text("Built with ❤️ using SwiftUI and MapKit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("About Shvil")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
    .environmentObject(AuthenticationManager.shared)
    .environmentObject(LocationService.shared)
}
