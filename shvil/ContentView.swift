//
//  ContentView.swift
//  shvil
//
//  Created by Ilan Uzan on 31/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var supabaseManager: SupabaseManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "map")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 60))
                
                Text("Welcome to Shvil!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your Apple-grade maps & navigation app")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    NavigationLink(destination: SupabaseTestView()) {
                        HStack {
                            Image(systemName: "link")
                            Text("Test Supabase Connection")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if locationService.isLocationEnabled {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                            Text("Location: Enabled")
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.orange)
                            Text("Location: Not enabled")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Shvil")
        }
    }
}

#Preview {
    ContentView()
}
