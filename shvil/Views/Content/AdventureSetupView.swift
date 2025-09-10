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
    @StateObject private var locationManager = DependencyContainer.shared.locationManager

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
                // Background with Landmarks-style extension
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                    .backgroundExtensionEffect()

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        // Header with readability overlay
                        headerSection
                            .overlay(
                                ReadabilityOverlay(
                                    cornerRadius: DesignTokens.CornerRadius.xl,
                                    gradientColors: [.black.opacity(0.3), .clear],
                                    startPoint: .bottom,
                                    endPoint: .center
                                )
                            )

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
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.md)
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
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack {
                    AppleGlassStatusIndicator(status: .error)
                    Text("Something went wrong")
                        .font(DesignTokens.Typography.bodyEmphasized)
                        .foregroundColor(DesignTokens.Text.primary)
                }
                Text(errorMessage)
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
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
        VStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(DesignTokens.Brand.primary)
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: DesignTokens.Shadow.medium.color,
                        radius: DesignTokens.Shadow.medium.radius,
                        x: DesignTokens.Shadow.medium.x,
                        y: DesignTokens.Shadow.medium.y
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("Let's Create Your Adventure")
                    .font(DesignTokens.Typography.title)
                    .foregroundColor(DesignTokens.Text.primary)
                    .multilineTextAlignment(.center)

                Text("Tell us what kind of experience you're looking for and we'll craft the perfect adventure for you.")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xl)
    }

    // MARK: - Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("What's your mood?")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignTokens.Spacing.sm) {
                ForEach(AdventureMood.allCases, id: \.self) { mood in
                    moodCard(for: mood)
                }
            }
        }
    }

    private func moodCard(for mood: AdventureMood) -> some View {
        Button(action: {
            withAnimation(DesignTokens.Animation.spring) {
                selectedMood = mood
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                moodIconView(for: mood)
                moodTitleView(for: mood)
            }
            .padding(.vertical, DesignTokens.Spacing.md)
            .padding(.horizontal, DesignTokens.Spacing.sm)
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
                .fill(selectedMood == mood ? DesignTokens.Brand.primary : DesignTokens.Surface.secondary)
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                        .blendMode(.overlay)
                )
                .shadow(
                    color: selectedMood == mood ? DesignTokens.Shadow.medium.color : DesignTokens.Shadow.light.color,
                    radius: selectedMood == mood ? DesignTokens.Shadow.medium.radius : DesignTokens.Shadow.light.radius,
                    x: selectedMood == mood ? DesignTokens.Shadow.medium.x : DesignTokens.Shadow.light.x,
                    y: selectedMood == mood ? DesignTokens.Shadow.medium.y : DesignTokens.Shadow.light.y
                )

            Image(systemName: moodIcon(for: mood))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(selectedMood == mood ? .white : DesignTokens.Text.secondary)
        }
    }
    
    private func moodTitleView(for mood: AdventureMood) -> some View {
        Text(mood.displayName)
            .font(DesignTokens.Typography.caption1)
            .foregroundColor(selectedMood == mood ? DesignTokens.Text.primary : DesignTokens.Text.secondary)
            .multilineTextAlignment(.center)
    }
    
    private func moodCardBackground(for mood: AdventureMood) -> some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
            .fill(DesignTokens.Glass.light)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(selectedMood == mood ? DesignTokens.Glass.medium : DesignTokens.Surface.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .stroke(selectedMood == mood ? DesignTokens.Brand.primary : DesignTokens.Glass.light, lineWidth: 1)
                    )
            )
            .shadow(
                color: DesignTokens.Shadow.light.color,
                radius: DesignTokens.Shadow.light.radius,
                x: DesignTokens.Shadow.light.x,
                y: DesignTokens.Shadow.light.y
            )
    }

    private func moodIcon(for mood: AdventureMood) -> String {
        switch mood {
        case .fun: "face.smiling"
        case .relaxing: "leaf"
        case .cultural: "building.columns"
        case .adventurous: "heart"
        case .adventurous: "mountain.2"
        }
    }

    // MARK: - Duration Section

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("How long?")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(durationOptions, id: \.self) { duration in
                    durationChip(for: duration)
                }
            }
        }
    }

    private func durationChip(for duration: Int) -> some View {
        Button(action: {
            withAnimation(DesignTokens.Animation.spring) {
                selectedDuration = duration
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            Text("\(duration)h")
                .font(DesignTokens.Typography.bodyEmphasized)
                .foregroundColor(selectedDuration == duration ? .white : DesignTokens.Text.primary)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(selectedDuration == duration ? DesignTokens.Brand.primary : DesignTokens.Surface.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                .stroke(selectedDuration == duration ? Color.clear : DesignTokens.Glass.light, lineWidth: 1)
                        )
                        .appleShadow(selectedDuration == duration ? DesignTokens.Shadow.medium : DesignTokens.Shadow.light)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Duration: \(duration) hours")
        .accessibilityHint(selectedDuration == duration ? "Currently selected" : "Double tap to select this duration")
        .accessibilityAddTraits(selectedDuration == duration ? .isSelected : [])
    }

    // MARK: - Transportation Section

    private var transportationSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("How will you get around?")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(TransportationMode.allCases, id: \.self) { transport in
                    transportChip(for: transport)
                }
            }
        }
    }

    private func transportChip(for transport: TransportationMode) -> some View {
        Button(action: {
            withAnimation(DesignTokens.Animation.spring) {
                selectedTransport = transport
            }
            HapticFeedback.shared.impact(style: .light)
        }) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: transportIcon(for: transport))
                    .font(.system(size: 20, weight: .medium))

                Text(transport.displayName)
                    .font(DesignTokens.Typography.caption1)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(selectedTransport == transport ? .white : DesignTokens.Text.primary)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(selectedTransport == transport ? DesignTokens.Brand.primary : DesignTokens.Surface.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .stroke(selectedTransport == transport ? Color.clear : DesignTokens.Glass.light, lineWidth: 1)
                    )
                    .appleShadow(selectedTransport == transport ? DesignTokens.Shadow.medium : DesignTokens.Shadow.light)
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
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Group Adventure")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)

                Text("Include friends in your adventure")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }

            Spacer()

            Toggle("", isOn: $isGroupAdventure)
                .toggleStyle(SwitchToggleStyle(tint: DesignTokens.Brand.primary))
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                        .fill(DesignTokens.Glass.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                                .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                .blendMode(.overlay)
                        )
                )
        )
        .appleShadow(DesignTokens.Shadow.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Group Adventure toggle")
        .accessibilityHint(isGroupAdventure ? "Group adventure is enabled" : "Group adventure is disabled")
    }

    // MARK: - Custom Prompt Section

    private var customPromptSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Anything specific? (Optional)")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.primary)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TextEditor(text: $customPrompt)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.primary)
                    .padding(DesignTokens.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                    .fill(DesignTokens.Glass.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                                            .stroke(DesignTokens.Glass.innerHighlight, lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                            )
                            .appleShadow(DesignTokens.Shadow.light)
                    )
                    .frame(minHeight: 120)

                Text("Tell us about specific places, activities, or experiences you'd like to include.")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Custom prompt section")
        .accessibilityHint("Optional field to specify additional requirements for your adventure")
    }

    // MARK: - Validation Errors View
    
    private var validationErrorsView: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(DesignTokens.Semantic.warning)
                Text("Please fix the following issues:")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Text.primary)
            }
            
            ForEach(validationErrors, id: \.self) { error in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Text("•")
                        .foregroundColor(DesignTokens.Semantic.warning)
                    Text(error)
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Semantic.warning.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(DesignTokens.Semantic.warning.opacity(0.3), lineWidth: 1)
                )
        )
        .appleShadow(DesignTokens.Shadow.light)
        .padding(.horizontal, DesignTokens.Spacing.md)
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
        .padding(.bottom, DesignTokens.Spacing.xl)
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
        if locationManager.currentLocation == nil {
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
        guard locationManager.currentLocation != nil else {
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
            origin: locationManager.currentLocation!.coordinate,
            preferences: UserPreferences(
                language: "en",
                theme: "light",
                notifications: NotificationSettings(),
                privacy: PrivacySettings(
                    privacyPolicy: true,
                    locationSharing: true,
                    friendsOnMap: true,
                    etaSharing: true,
                    analytics: true,
                    panicSwitch: true
                )
            )
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