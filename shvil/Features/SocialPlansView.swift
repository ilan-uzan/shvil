//
//  SocialPlansView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SocialPlansView: View {
    @State private var plans: [Plan] = []
    @State private var selectedFilter: PlanStatus = .all
    @State private var showCreatePlan = false
    @State private var showPlanDetails = false
    @State private var selectedPlan: Plan?
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter section
                PlanFilterView(
                    selectedFilter: $selectedFilter,
                    onFilterChange: { _ in }
                )
                .padding(.vertical, DesignTokens.Spacing.md)
                
                // Plans list
                if filteredPlans.isEmpty {
                    emptyState
                } else {
                    plansList
                }
            }
            .navigationTitle("Social Plans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePlan = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(DesignTokens.Brand.primary)
                    }
                }
            }
        }
        .onAppear {
            loadPlans()
        }
        .sheet(isPresented: $showCreatePlan) {
            CreatePlanView()
        }
        .sheet(isPresented: $showPlanDetails) {
            if let selectedPlan = selectedPlan {
                PlanDetailsView(plan: selectedPlan)
            }
        }
    }
    
    private var filteredPlans: [Plan] {
        if selectedFilter == .all {
            return plans
        }
        return plans.filter { $0.status == selectedFilter }
    }
    
    private var plansList: some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(filteredPlans) { plan in
                    SocialPlanCard(
                        plan: plan,
                        onTap: {
                            selectedPlan = plan
                            showPlanDetails = true
                        },
                        onJoin: {
                            joinPlan(plan)
                        },
                        onVote: { option in
                            voteForOption(option, in: plan)
                        }
                    )
                    .onAppear {
                        // Load more plans when reaching the end
                        if plan.id == filteredPlans.last?.id {
                            loadMorePlans()
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .performanceOptimized()
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(DesignTokens.Text.tertiary)
            
            Text("No plans yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Text.primary)
            
            Text("Create your first social plan or join an existing one!")
                .font(.body)
                .foregroundColor(DesignTokens.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.xl)
            
            Button(action: { showCreatePlan = true }) {
                Text("Create Plan")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.vertical, DesignTokens.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .fill(DesignTokens.Brand.primary)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadPlans() {
        // In a real app, this would load from a service
        // For now, initialize with empty array
        plans = []
    }
    
    private func joinPlan(_ plan: Plan) {
        // In a real app, this would call a service to join the plan
        print("Joining plan: \(plan.title)")
    }
    
    private func voteForOption(_ option: PlanOption, in plan: Plan) {
        // In a real app, this would call a service to vote
        print("Voting for option: \(option.name) in plan: \(plan.title)")
    }
    
    private func loadMorePlans() {
        // In a real app, this would load more plans from a service
        // For now, do nothing
    }
}

// MARK: - Create Plan View

struct CreatePlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedTags: [String] = []
    @State private var maxParticipants = 10
    @State private var isPublic = true
    
    private let availableTags = ["Food", "Adventure", "Social", "Outdoor", "Indoor", "Weekend", "Weekday", "Morning", "Evening"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Plan Details") {
                    TextField("Plan Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Settings") {
                    Stepper("Max Participants: \(maxParticipants)", value: $maxParticipants, in: 2...50)
                    Toggle("Public Plan", isOn: $isPublic)
                }
                
                Section("Tags") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: DesignTokens.Spacing.sm) {
                        ForEach(availableTags, id: \.self) { tag in
                            tagButton(tag)
                        }
                    }
                }
            }
            .navigationTitle("Create Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createPlan()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func tagButton(_ tag: String) -> some View {
        Button(action: {
            if selectedTags.contains(tag) {
                selectedTags.removeAll { $0 == tag }
            } else {
                selectedTags.append(tag)
            }
        }) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(selectedTags.contains(tag) ? .white : DesignTokens.Text.secondary)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                        .fill(selectedTags.contains(tag) ? DesignTokens.Brand.primary : DesignTokens.Surface.secondary)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func createPlan() {
        // In a real app, this would call a service to create the plan
        print("Creating plan: \(title)")
        dismiss()
    }
}

// MARK: - Plan Details View

struct PlanDetailsView: View {
    let plan: Plan
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(plan.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        Text("Hosted by \(plan.hostName)")
                            .font(.headline)
                            .foregroundColor(DesignTokens.Text.secondary)
                        
                        Text(plan.description)
                            .font(.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    
                    // Participants
                    participantsSection
                    
                    // Options (if voting)
                    if plan.status == .voting {
                        optionsSection
                    }
                    
                    // Tags
                    if !plan.tags.isEmpty {
                        tagsSection
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .navigationTitle("Plan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Participants (\(plan.participants.count))")
                .font(.headline)
                .foregroundColor(DesignTokens.Text.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: DesignTokens.Spacing.sm) {
                ForEach(plan.participants) { participant in
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Circle()
                            .fill(DesignTokens.Brand.primary)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(participant.name.prefix(1)))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                        
                        Text(participant.name)
                            .font(.caption)
                            .foregroundColor(DesignTokens.Text.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Vote for your preference")
                .font(.headline)
                .foregroundColor(DesignTokens.Text.primary)
            
            ForEach(plan.options) { option in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(option.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text(option.address)
                        .font(.caption)
                        .foregroundColor(DesignTokens.Text.secondary)
                    
                    HStack {
                        Text("\(option.votes) votes")
                            .font(.caption)
                            .foregroundColor(DesignTokens.Brand.primary)
                        
                        Spacer()
                        
                        Button("Vote") {
                            // Vote action
                        }
                        .font(.caption)
                        .foregroundColor(DesignTokens.Brand.primary)
                    }
                }
                .padding(DesignTokens.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                        .fill(DesignTokens.Surface.secondary)
                )
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(DesignTokens.Text.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: DesignTokens.Spacing.sm) {
                ForEach(plan.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignTokens.Brand.primary)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                                .fill(DesignTokens.Brand.primary.opacity(0.1))
                        )
                }
            }
        }
    }
}

#Preview {
    SocialPlansView()
}