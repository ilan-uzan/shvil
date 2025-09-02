//
//  GuestModeView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct GuestModeView: View {
    @EnvironmentObject private var locationService: LocationService
    @State private var showPermissionAlert = false
    @State private var permissionDenied = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Guest Mode Header
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Welcome to Shvil!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("You're using Shvil in guest mode. Your data stays on this device.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Permission Status
                VStack(spacing: 16) {
                    if locationService.isLocationEnabled {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                            Text("Location Access: Enabled")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "location.slash")
                                    .foregroundColor(.orange)
                                Text("Location Access: Not Enabled")
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Enable location access for the best navigation experience.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Enable Location") {
                                locationService.requestLocationPermission()
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    NavigationLink(destination: ContentView()) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Start Navigating")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Show upgrade to account option
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Create Account Later")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .navigationTitle("Guest Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        // Show settings
                    }
                }
            }
        }
        .alert("Location Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Shvil needs location access to provide navigation. Please enable it in Settings.")
        }
        .onChange(of: locationService.authorizationStatus) { status in
            if status == .denied || status == .restricted {
                showPermissionAlert = true
            }
        }
    }
}

#Preview {
    GuestModeView()
        .environmentObject(LocationService.shared)
}
