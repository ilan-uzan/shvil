//
//  AdventureSetupView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import SwiftUI

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
    @State private var validationErrors: [String] = []
    @State private var showSuccess = false

    private let durationOptions = [1, 2, 4, 6, 8, 12]
    
    private var isFormValid: Bool {
        validationErrors.isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppleColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppleSpacing.xl) {
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

                        // Validation Errors
                        if !validationErrors.isEmpty {
                            validationErrorsView
                        }
                        
                        // Generate Button
                        generateButton
                    }
                    .padding(.horizontal, AppleSpacing.md)
                    .padding(.top, AppleSpacing.md)
                }
            }
            .navigationTitle("Create Adventure")
            .appleNavigationBar()
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AppleButton("Cancel", style: .ghost, size: .small) {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
                errorMessage = ""
            }
        } message: {
            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                HStack {
                    AppleGlassStatusIndicator(status: .error)
                    Text("Something went wrong")
                        .font(AppleTypography.bodyEmphasized)
                        .foregroundColor(AppleColors.textPrimary)
                }
                Text(errorMessage)
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your adventure has been created successfully!")
        }
        .onChange(of: customPrompt) { _ in
            validateForm()
        }
        .onChange(of: selectedMood) { _ in
            validateForm()
        }
        .onChange(of: selectedDuration) { _ in
            validateForm()
        }
        .onChange(of: selectedTransport) { _ in
            validateForm()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppleSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppleColors.brandPrimary)
                    .frame(width: 80, height: 80)
                    .appleShadow(AppleShadows.medium)

                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: AppleSpacing.sm) {
                Text("Let's Create Your Adventure")
                    .font(AppleTypography.title1)
                    .foregroundColor(AppleColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Tell us what kind of experience you're looking for and we'll craft the perfect adventure for you.")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, AppleSpacing.xl)
    }

    // MARK: - Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            Text("What's your mood?")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppleSpacing.sm) {
                ForEach(AdventureMood.allCases, id: \.self) { mood in
                    moodCard(for: mood)
                }
            }
        }
    }

    private func moodCard(for mood: AdventureMood) -> some View {
        Button(action: {
            withAnimation(AppleAnimations.spring) {
                selectedMood = mood
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            VStack(spacing: AppleSpacing.sm) {
                moodIconView(for: mood)
                moodTitleView(for: mood)
            }
            .padding(.vertical, AppleSpacing.md)
            .padding(.horizontal, AppleSpacing.sm)
            .background(moodCardBackground(for: mood))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Mood: \(mood.displayName)")
        .accessibilityHint(selectedMood == mood ? "Currently selected" : "Double tap to select this mood")
        .accessibilityAddTraits(selectedMood == mood ? .isSelected : [])
    }
    
    private func moodIconView(for mood: AdventureMood) -> some View {
        ZStack {
            Circle()
                .fill(selectedMood == mood ? AppleColors.brandPrimary : AppleColors.surfaceSecondary)
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                        .blendMode(.overlay)
                )
                .appleShadow(selectedMood == mood ? AppleShadows.medium : AppleShadows.light)

            Image(systemName: moodIcon(for: mood))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(selectedMood == mood ? .white : AppleColors.textSecondary)
        }
    }
    
    private func moodTitleView(for mood: AdventureMood) -> some View {
        Text(mood.displayName)
            .font(AppleTypography.caption1)
            .foregroundColor(selectedMood == mood ? AppleColors.textPrimary : AppleColors.textSecondary)
            .multilineTextAlignment(.center)
    }
    
    private func moodCardBackground(for mood: AdventureMood) -> some View {
        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                    .fill(selectedMood == mood ? AppleColors.glassMedium : AppleColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                            .stroke(selectedMood == mood ? AppleColors.brandPrimary : AppleColors.glassLight, lineWidth: 1)
                    )
            )
            .appleShadow(AppleShadows.light)
    }

    private func moodIcon(for mood: AdventureMood) -> String {
        switch mood {
        case .fun: "face.smiling"
        case .relaxing: "leaf"
        case .cultural: "building.columns"
        case .romantic: "heart"
        case .adventurous: "mountain.2"
        }
    }

    // MARK: - Duration Section

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            Text("How long?")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            HStack(spacing: AppleSpacing.sm) {
                ForEach(durationOptions, id: \.self) { duration in
                    durationChip(for: duration)
                }
            }
        }
    }

    private func durationChip(for duration: Int) -> some View {
        Button(action: {
            withAnimation(AppleAnimations.spring) {
                selectedDuration = duration
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            Text("\(duration)h")
                .font(AppleTypography.bodyEmphasized)
                .foregroundColor(selectedDuration == duration ? .white : AppleColors.textPrimary)
                .padding(.horizontal, AppleSpacing.lg)
                .padding(.vertical, AppleSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .fill(selectedDuration == duration ? AppleColors.brandPrimary : AppleColors.surfaceSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                .stroke(selectedDuration == duration ? Color.clear : AppleColors.glassLight, lineWidth: 1)
                        )
                        .appleShadow(selectedDuration == duration ? AppleShadows.medium : AppleShadows.light)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Duration: \(duration) hours")
        .accessibilityHint(selectedDuration == duration ? "Currently selected" : "Double tap to select this duration")
        .accessibilityAddTraits(selectedDuration == duration ? .isSelected : [])
    }

    // MARK: - Transportation Section

    private var transportationSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            Text("How will you get around?")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            HStack(spacing: AppleSpacing.sm) {
                ForEach(TransportationMode.allCases, id: \.self) { transport in
                    transportChip(for: transport)
                }
            }
        }
    }

    private func transportChip(for transport: TransportationMode) -> some View {
        Button(action: {
            withAnimation(AppleAnimations.spring) {
                selectedTransport = transport
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            VStack(spacing: AppleSpacing.xs) {
                Image(systemName: transportIcon(for: transport))
                    .font(.system(size: 20, weight: .medium))

                Text(transport.displayName)
                    .font(AppleTypography.caption1)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(selectedTransport == transport ? .white : AppleColors.textPrimary)
            .padding(.horizontal, AppleSpacing.md)
            .padding(.vertical, AppleSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                    .fill(selectedTransport == transport ? AppleColors.brandPrimary : AppleColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                            .stroke(selectedTransport == transport ? Color.clear : AppleColors.glassLight, lineWidth: 1)
                    )
                    .appleShadow(selectedTransport == transport ? AppleShadows.medium : AppleShadows.light)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Transportation: \(transport.displayName)")
        .accessibilityHint(selectedTransport == transport ? "Currently selected" : "Double tap to select this transportation mode")
        .accessibilityAddTraits(selectedTransport == transport ? .isSelected : [])
    }

    private func transportIcon(for transport: TransportationMode) -> String {
        switch transport {
        case .walking: "figure.walk"
        case .driving: "car"
        case .cycling: "bicycle"
        case .publicTransport: "bus"
        case .mixed: "arrow.triangle.2.circlepath"
        }
    }

    // MARK: - Group Section

    private var groupSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppleSpacing.xs) {
                Text("Group Adventure")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)

                Text("Include friends in your adventure")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isGroupAdventure)
                .toggleStyle(SwitchToggleStyle(tint: AppleColors.brandPrimary))
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.vertical, AppleSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                        .fill(AppleColors.glassMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppleCornerRadius.xl)
                                .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(AppleShadows.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Group Adventure toggle")
        .accessibilityHint(isGroupAdventure ? "Group adventure is enabled" : "Group adventure is disabled")
    }

    // MARK: - Custom Prompt Section

    private var customPromptSection: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.md) {
            Text("Anything specific? (Optional)")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(alignment: .leading, spacing: AppleSpacing.sm) {
                TextEditor(text: $customPrompt)
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textPrimary)
                    .padding(AppleSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                    .fill(AppleColors.glassMedium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                                            .stroke(AppleColors.glassInnerHighlight, lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                            )
                            .appleShadow(AppleShadows.light)
                    )
                    .frame(minHeight: 120)

                Text("Tell us about specific places, activities, or experiences you'd like to include.")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Custom prompt section")
        .accessibilityHint("Optional field to specify additional requirements for your adventure")
    }

    // MARK: - Validation Errors View
    
    private var validationErrorsView: some View {
        VStack(alignment: .leading, spacing: AppleSpacing.sm) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppleColors.warning)
                Text("Please fix the following issues:")
                    .font(AppleTypography.bodyEmphasized)
                    .foregroundColor(AppleColors.textPrimary)
            }
            
            ForEach(validationErrors, id: \.self) { error in
                HStack(alignment: .top, spacing: AppleSpacing.sm) {
                    Text("•")
                        .foregroundColor(AppleColors.warning)
                    Text(error)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppleSpacing.lg)
        .padding(.vertical, AppleSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                .fill(AppleColors.warning.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppleCornerRadius.lg)
                        .stroke(AppleColors.warning.opacity(0.3), lineWidth: 1)
                )
        )
        .appleShadow(AppleShadows.light)
        .padding(.horizontal, AppleSpacing.md)
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        AppleButton(
            isGenerating ? "Creating Adventure..." : "Create Adventure",
            icon: isGenerating ? nil : "sparkles",
            style: .primary,
            size: .large
        ) {
            validateAndGenerateAdventure()
        }
        .disabled(isGenerating || !isFormValid)
        .overlay(
            Group {
                if isGenerating {
                    AppleGlassLoadingIndicator()
                        .offset(x: -60)
                }
            }
        )
        .scaleEffect(isGenerating ? 0.98 : 1.0)
        .animation(AppleAnimations.micro, value: isGenerating)
        .padding(.bottom, AppleSpacing.xl)
    }

    // MARK: - Actions
    
    private func validateAndGenerateAdventure() {
        validateForm()
        if isFormValid {
            generateAdventure()
        }
    }
    
    private func validateForm() {
        validationErrors.removeAll()
        
        // Check if location is available
        if locationService.currentLocation == nil {
            validationErrors.append("Location access is required to create an adventure")
        }
        
        // Check if custom prompt is too long
        if customPrompt.count > 500 {
            validationErrors.append("Custom prompt must be less than 500 characters")
        }
        
        // Check if custom prompt contains inappropriate content (basic check)
        let inappropriateWords = ["spam", "advertisement", "promotion"]
        let lowercasedPrompt = customPrompt.lowercased()
        for word in inappropriateWords {
            if lowercasedPrompt.contains(word) {
                validationErrors.append("Custom prompt contains inappropriate content")
                break
            }
        }
    }

    private func generateAdventure() {
        guard locationService.currentLocation != nil else {
            errorMessage = "Location access is required to create adventures."
            showError = true
            return
        }

        isGenerating = true

        let timeFrame: TimeFrame = selectedDuration <= 4 ? .halfDay : .fullDay
        let companions: [CompanionType] = isGroupAdventure ? [.friends] : [.solo]
        let budget: BudgetLevel = .medium
        
        let input = AdventureGenerationInput(
            timeFrame: timeFrame,
            mood: selectedMood,
            budget: budget,
            companions: companions,
            transportationMode: selectedTransport,
            origin: locationService.currentLocation!.coordinate,
            preferences: UserPreferences()
        )

        Task {
            do {
                _ = try await adventureKit.generateAdventure(input: input)
                await MainActor.run {
                    isGenerating = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    AdventureSetupView()
}