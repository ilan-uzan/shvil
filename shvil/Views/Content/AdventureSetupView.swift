//
//  AdventureSetupView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct AdventureSetupView: View {
    @State private var selectedMood = "Exploration"
    @State private var selectedDuration = "2 hours"
    @State private var selectedTransport = "Walking"
    @State private var showLocationPicker = false
    
    private let moods = ["Exploration", "Adventure", "Relaxation", "Culture", "Nature"]
    private let durations = ["1 hour", "2 hours", "Half day", "Full day"]
    private let transports = ["Walking", "Cycling", "Driving", "Public Transport"]
    
    var body: some View {
        ZStack {
            // Background
            DesignTokens.Surface.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Create Adventure")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Text("Design your perfect adventure experience")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Mood Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's your mood?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignTokens.Spacing.sm) {
                            ForEach(moods, id: \.self) { mood in
                                GlassCard(style: .secondary, isInteractive: true) {
                                    VStack(spacing: DesignTokens.Spacing.sm) {
                                        Text(mood)
                                            .font(DesignTokens.Typography.headline)
                                            .foregroundColor(selectedMood == mood ? DesignTokens.Brand.primary : DesignTokens.Text.primary)
                                        
                                        Image(systemName: moodIcon(for: mood))
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedMood == mood ? DesignTokens.Brand.primary : DesignTokens.Text.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(DesignTokens.Spacing.md)
                                }
                                .onTapGesture {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Duration Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How long?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(durations, id: \.self) { duration in
                                DurationCard(
                                    title: duration,
                                    isSelected: selectedDuration == duration
                                ) {
                                    selectedDuration = duration
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Transport Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Transportation?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(transports, id: \.self) { transport in
                                TransportCard(
                                    title: transport,
                                    isSelected: selectedTransport == transport
                                ) {
                                    selectedTransport = transport
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Create Adventure Button
                    Button(action: {
                        // Create adventure action
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                            Text("Create My Adventure")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .fill(DesignTokens.Brand.gradient)
                                .appleShadow(DesignTokens.Shadow.medium)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct MoodCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: moodIcon(for: title))
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : DesignTokens.Brand.primary)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : DesignTokens.Text.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(isSelected ? DesignTokens.Brand.primary : DesignTokens.Surface.primary)
                    .appleShadow(DesignTokens.Shadow.light)
            )
        }
    }
    
    private func moodIcon(for mood: String) -> String {
        switch mood {
        case "Exploration": return "binoculars.fill"
        case "Adventure": return "mountain.2.fill"
        case "Relaxation": return "leaf.fill"
        case "Culture": return "building.2.fill"
        case "Nature": return "tree.fill"
        default: return "star.fill"
        }
    }
}

struct DurationCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : DesignTokens.Text.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(isSelected ? DesignTokens.Brand.primary : DesignTokens.Surface.primary)
                        .appleShadow(DesignTokens.Shadow.light)
                )
        }
    }
}

struct TransportCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: transportIcon(for: title))
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : DesignTokens.Text.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(isSelected ? DesignTokens.Brand.primary : DesignTokens.Surface.primary)
                    .appleShadow(DesignTokens.Shadow.light)
            )
        }
    }
    
    private func transportIcon(for transport: String) -> String {
        switch transport {
        case "Walking": return "figure.walk"
        case "Cycling": return "bicycle"
        case "Driving": return "car.fill"
        case "Public Transport": return "bus.fill"
        default: return "location.fill"
        }
    }
    
    private func moodIcon(for mood: String) -> String {
        switch mood {
        case "Exploration": return "location.fill"
        case "Adventure": return "sparkles"
        case "Relaxation": return "leaf.fill"
        case "Culture": return "building.2.fill"
        case "Nature": return "tree.fill"
        default: return "star.fill"
        }
    }
}

#Preview {
    AdventureSetupView()
}