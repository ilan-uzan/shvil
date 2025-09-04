//
//  AdventureSetupView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation

struct AdventureSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adventureKit = DependencyContainer.shared.adventureKit
    @StateObject private var locationService = DependencyContainer.shared.locationService
    
    @State private var selectedMood: AdventureMood = .fun
    @State private var selectedDuration: Int = 2
    @State private var selectedTransport: TransportationMode = .walking
    @State private var isGroupAdventure = false
    @State private var customPrompt = ""
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let durationOptions = [1, 2, 4, 6, 8, 12]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LiquidGlassColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Mood Selection
                        moodSection
                        
                        // Duration Selection
                        durationSection
                        
                        // Transportation
                        transportationSection
                        
                        // Group Toggle
                        groupSection
                        
                        // Custom Prompt
                        customPromptSection
                        
                        // Generate Button
                        generateButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Create Adventure")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassColors.primaryText)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(LiquidGlassGradients.primaryGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Let's Create Your Adventure")
                    .font(LiquidGlassTypography.titleXL)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Tell us what kind of experience you're looking for and we'll craft the perfect adventure for you.")
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Mood Section
    
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's your mood?")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(AdventureMood.allCases, id: \.self) { mood in
                    moodCard(for: mood)
                }
            }
        }
    }
    
    private func moodCard(for mood: AdventureMood) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(selectedMood == mood ? AnyShapeStyle(LiquidGlassGradients.primaryGradient) : AnyShapeStyle(LiquidGlassColors.glassSurface1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: moodIcon(for: mood))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(selectedMood == mood ? .white : LiquidGlassColors.secondaryText)
                }
                
                Text(mood.displayName)
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(selectedMood == mood ? LiquidGlassColors.primaryText : LiquidGlassColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedMood == mood ? LiquidGlassColors.glassSurface2 : LiquidGlassColors.glassSurface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedMood == mood ? LiquidGlassColors.accentDeepAqua : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func moodIcon(for mood: AdventureMood) -> String {
        switch mood {
        case .fun: return "face.smiling"
        case .relaxing: return "leaf"
        case .cultural: return "building.columns"
        case .romantic: return "heart"
        case .adventurous: return "mountain.2"
        }
    }
    
    // MARK: - Duration Section
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How long?")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            HStack(spacing: 12) {
                ForEach(durationOptions, id: \.self) { duration in
                    durationChip(for: duration)
                }
            }
        }
    }
    
    private func durationChip(for duration: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDuration = duration
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            Text("\(duration)h")
                .font(LiquidGlassTypography.bodyMedium)
                .foregroundColor(selectedDuration == duration ? .white : LiquidGlassColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedDuration == duration ? AnyShapeStyle(LiquidGlassGradients.primaryGradient) : AnyShapeStyle(LiquidGlassColors.glassSurface1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Transportation Section
    
    private var transportationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How will you get around?")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            HStack(spacing: 12) {
                ForEach(TransportationMode.allCases, id: \.self) { transport in
                    transportChip(for: transport)
                }
            }
        }
    }
    
    private func transportChip(for transport: TransportationMode) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTransport = transport
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            HStack(spacing: 8) {
                Image(systemName: transportIcon(for: transport))
                    .font(.system(size: 16, weight: .medium))
                
                Text(transport.displayName)
                    .font(LiquidGlassTypography.caption)
            }
            .foregroundColor(selectedTransport == transport ? .white : LiquidGlassColors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedTransport == transport ? AnyShapeStyle(LiquidGlassGradients.primaryGradient) : AnyShapeStyle(LiquidGlassColors.glassSurface1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func transportIcon(for transport: TransportationMode) -> String {
        switch transport {
        case .walking: return "figure.walk"
        case .driving: return "car"
        case .cycling: return "bicycle"
        case .publicTransport: return "bus"
        }
    }
    
    // MARK: - Group Section
    
    private var groupSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Group Adventure")
                    .font(LiquidGlassTypography.bodyMedium)
                    .foregroundColor(LiquidGlassColors.primaryText)
                
                Text("Include friends in your adventure")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: $isGroupAdventure)
                .toggleStyle(SwitchToggleStyle(tint: LiquidGlassColors.accentDeepAqua))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LiquidGlassColors.glassSurface1)
        )
    }
    
    // MARK: - Custom Prompt Section
    
    private var customPromptSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Anything specific? (Optional)")
                .font(LiquidGlassTypography.title)
                .foregroundColor(LiquidGlassColors.primaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $customPrompt)
                    .font(LiquidGlassTypography.body)
                    .foregroundColor(LiquidGlassColors.primaryText)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LiquidGlassColors.glassSurface1)
                    )
                    .frame(minHeight: 100)
                
                Text("Tell us about specific places, activities, or experiences you'd like to include.")
                    .font(LiquidGlassTypography.caption)
                    .foregroundColor(LiquidGlassColors.secondaryText)
            }
        }
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button(action: generateAdventure) {
            HStack(spacing: 12) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(isGenerating ? "Creating Adventure..." : "Create Adventure")
                    .font(LiquidGlassTypography.bodyMedium)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LiquidGlassGradients.primaryGradient)
            )
        }
        .disabled(isGenerating)
        .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    
    private func generateAdventure() {
        guard let currentLocation = locationService.currentLocation else {
            errorMessage = "Location access is required to create adventures."
            showError = true
            return
        }
        
        isGenerating = true
        
        let input = AdventureGenerationInput(
            theme: "exploration",
            durationHours: selectedDuration,
            mood: selectedMood,
            isGroup: isGroupAdventure,
            city: "Current Location",
            timeOfDay: "afternoon",
            weather: "clear",
            preferences: UserPreferences(),
            savedPlaces: [],
            recentPlaces: []
        )
        
        Task {
            do {
                let adventure = try await adventureKit.generateAdventure(input: input)
                isGenerating = false
                // Navigate to adventure sheet or details
                dismiss()
            } catch {
                isGenerating = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    AdventureSetupView()
}
