//
//  MapView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Jerusalem
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var selectedMapLayer: MapLayer = .standard
    
    var body: some View {
        ZStack {
            // Map Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            // Map
            Map(coordinateRegion: $region, interactionModes: .all)
                .ignoresSafeArea()
            
            // Top Search Bar
            VStack {
                HStack {
                    // Search Pill
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignTokens.Text.secondary)
                        
                        TextField("Search places...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onTapGesture {
                                isSearchFocused = true
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(DesignTokens.Text.tertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                            .fill(DesignTokens.Surface.primary)
                            .shadow(DesignTokens.Shadow.light)
                    )
                    
                    // Map Layers Button
                    Button(action: {
                        // Toggle map layers
                    }) {
                        Image(systemName: "layers.fill")
                            .foregroundColor(DesignTokens.Text.primary)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Surface.primary)
                                    .shadow(DesignTokens.Shadow.light)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            }
            
            // Bottom Action Buttons
            VStack {
                Spacer()
                
                HStack {
                    // Locate Me Button
                    Button(action: {
                        // Center on user location
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .padding(16)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Brand.gradient)
                                    .shadow(DesignTokens.Shadow.medium)
                            )
                    }
                    
                    Spacer()
                    
                    // Focus Mode Button
                    Button(action: {
                        // Toggle focus mode
                    }) {
                        Image(systemName: "target")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .padding(16)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Brand.gradient)
                                    .shadow(DesignTokens.Shadow.medium)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Account for tab bar
            }
        }
    }
}

enum MapLayer: String, CaseIterable {
    case standard = "Standard"
    case satellite = "Satellite"
    case hybrid = "Hybrid"
}

#Preview {
    MapView()
}