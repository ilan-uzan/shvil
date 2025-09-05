//
//  SocialPlansView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import MapKit
import SwiftUI

struct SocialPlansView: View {
    @State private var plans: [Plan] = []
    @State private var selectedFilter: PlanStatus = .all
    @State private var showCreatePlan = false
    @State private var showPlanDetails = false
    @State private var selectedPlan: Plan?

    // Sample data for demonstration
    @State private var samplePlans: [Plan] = [
        Plan(
            id: UUID(),
            title: "Weekend Brunch Adventure",
            description: "Let's explore the best brunch spots in the city!",
            hostId: UUID(),
            hostName: "Sarah Chen",
            hostAvatar: nil,
            status: .voting,
            createdAt: Date(),
            votingEndsAt: Calendar.current.date(byAdding: .hour, value: 24, to: Date())!,
            participants: [
                PlanParticipant(id: UUID(), userId: UUID(), name: "Sarah Chen", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "Mike Johnson", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "Emma Wilson", avatar: nil, joinedAt: Date()),
            ],
            options: [
                PlanOption(id: UUID(), name: "Blue Bottle Coffee", address: "123 Market St", votes: 3),
                PlanOption(id: UUID(), name: "Farmers Market", address: "456 Union St", votes: 2),
                PlanOption(id: UUID(), name: "Golden Gate Park", address: "789 Park Ave", votes: 1),
            ]
        ),
        Plan(
            id: UUID(),
            title: "Friday Night Out",
            description: "Dinner and drinks in the Mission",
            hostId: UUID(),
            hostName: "Alex Rodriguez",
            hostAvatar: nil,
            status: .locked,
            createdAt: Date(),
            votingEndsAt: Date(),
            participants: [
                PlanParticipant(id: UUID(), userId: UUID(), name: "Alex Rodriguez", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "Lisa Park", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "David Kim", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "Maria Garcia", avatar: nil, joinedAt: Date()),
            ],
            options: [
                PlanOption(id: UUID(), name: "Foreign Cinema", address: "2534 Mission St", votes: 4),
                PlanOption(id: UUID(), name: "Trick Dog", address: "3010 20th St", votes: 0),
                PlanOption(id: UUID(), name: "El Techo", address: "2516 Mission St", votes: 0),
            ]
        ),
        Plan(
            id: UUID(),
            title: "Saturday Hiking",
            description: "Morning hike at Lands End",
            hostId: UUID(),
            hostName: "Tom Anderson",
            hostAvatar: nil,
            status: .live,
            createdAt: Date(),
            votingEndsAt: Date(),
            participants: [
                PlanParticipant(id: UUID(), userId: UUID(), name: "Tom Anderson", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "Jenny Lee", avatar: nil, joinedAt: Date()),
                PlanParticipant(id: UUID(), userId: UUID(), name: "Chris Brown", avatar: nil, joinedAt: Date()),
            ],
            options: [
                PlanOption(id: UUID(), name: "Lands End", address: "680 Point Lobos Ave", votes: 3),
            ]
        ),
    ]

    var filteredPlans: [Plan] {
        if selectedFilter == .all {
            samplePlans
        } else {
            samplePlans.filter { $0.status == selectedFilter }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Filter Chips
                VStack(spacing: 16) {
                    HStack {
                        Text("Social Plans")
                            .font(AppleTypography.largeTitle)
                            .foregroundColor(AppleColors.textPrimary)

                        Spacer()

                        Button(action: {
                            showCreatePlan = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppleColors.brandPrimary)
                        }
                        .accessibilityLabel("Create New Plan")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(PlanStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.displayName,
                                    isSelected: selectedFilter == status,
                                    count: samplePlans.filter { $0.status == status }.count
                                ) {
                                    selectedFilter = status
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Plans List
                if filteredPlans.isEmpty {
                    EmptyPlansView {
                        showCreatePlan = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPlans) { plan in
                                PlanCard(plan: plan) {
                                    selectedPlan = plan
                                    showPlanDetails = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }

                Spacer()
            }
            .background(AppleColors.background)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreatePlan) {
            CreatePlanView { plan in
                samplePlans.append(plan)
            }
        }
        .sheet(isPresented: $showPlanDetails) {
            if let plan = selectedPlan {
                PlanDetailsView(plan: plan) {
                    showPlanDetails = false
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .font(AppleTypography.caption1)
                    .foregroundColor(isSelected ? .white : AppleColors.textPrimary)

                if count > 0 {
                    Text("\(count)")
                        .font(AppleTypography.caption1)
                        .foregroundColor(isSelected ? .white : AppleColors.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.white.opacity(0.3) : AppleColors.surfaceSecondary)
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AnyShapeStyle(AppleColors.brandGradient) : AnyShapeStyle(AppleColors.surfaceTertiary))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: Plan
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(AppleTypography.title3)
                            .foregroundColor(AppleColors.textPrimary)
                            .lineLimit(1)

                        Text(plan.description)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    // Status Badge
                    StatusBadge(status: plan.status)
                }

                // Host Info
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppleColors.brandGradient)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(plan.hostName.prefix(1))
                                .font(AppleTypography.caption1)
                                .foregroundColor(.white)
                        )

                    Text("Hosted by \(plan.hostName)")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)

                    Spacer()

                    Text("\(plan.participants.count) participants")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }

                // Plan-specific content based on status
                switch plan.status {
                case .voting:
                    VotingContent(plan: plan)
                case .locked:
                    LockedContent(plan: plan)
                case .live:
                    LiveContent(plan: plan)
                case .all:
                    EmptyView()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppleColors.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: PlanStatus

    var body: some View {
        Text(status.displayName)
            .font(AppleTypography.caption1)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor)
            )
    }

    private var statusColor: Color {
        switch status {
        case .voting: .orange
        case .locked: .green
        case .live: .blue
        case .all: .gray
        }
    }
}

// MARK: - Voting Content

struct VotingContent: View {
    let plan: Plan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vote for your favorite option:")
                .font(AppleTypography.bodySemibold)
                .foregroundColor(AppleColors.textPrimary)

            LazyVStack(spacing: 8) {
                ForEach(plan.options.prefix(3)) { option in
                    VotingOptionRow(option: option) {
                        print("Voted for \(option.name)")
                    }
                }
            }

            if plan.options.count > 3 {
                Text("+ \(plan.options.count - 3) more options")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)
            }

            HStack {
                Text("Voting ends in \(timeRemaining)")
                    .font(AppleTypography.caption1)
                    .foregroundColor(AppleColors.textSecondary)

                Spacer()

                Button("Vote Now") {
                    print("Open voting interface")
                }
                .font(AppleTypography.caption1)
                .foregroundColor(AppleColors.brandPrimary)
            }
        }
    }

    private var timeRemaining: String {
        let timeInterval = plan.votingEndsAt.timeIntervalSinceNow
        if timeInterval > 0 {
            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) % 3600 / 60
            return "\(hours)h \(minutes)m"
        } else {
            return "Ended"
        }
    }
}

// MARK: - Voting Option Row

struct VotingOptionRow: View {
    let option: PlanOption
    let onVote: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onVote) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.name)
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)
                        .lineLimit(1)

                    Text(option.address)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("\(option.votes)")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.brandPrimary)

                    Text("votes")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppleColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Locked Content

struct LockedContent: View {
    let plan: Plan

    var winningOption: PlanOption? {
        plan.options.max { $0.votes < $1.votes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)

                Text("Decision Made!")
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)
            }

            if let winner = winningOption {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Winner: \(winner.name)")
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.textPrimary)

                    Text(winner.address)
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppleColors.surfaceSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
            }

            HStack(spacing: 12) {
                Button("Start Group Trip") {
                    print("Start group trip")
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppleColors.brandGradient)
                .cornerRadius(20)

                Button("Share ETA") {
                    print("Share ETA")
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(AppleColors.brandPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppleColors.brandPrimary, lineWidth: 2)
                )
            }
        }
    }
}

// MARK: - Live Content

struct LiveContent: View {
    let plan: Plan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)

                Text("Live Now")
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)
            }

            // Participants with presence indicators
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(plan.participants) { participant in
                    ParticipantAvatar(participant: participant, isOnline: true)
                }
            }

            HStack(spacing: 12) {
                Button("View Live") {
                    print("View live plan")
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppleColors.brandGradient)
                .cornerRadius(20)

                Button("Join") {
                    print("Join live plan")
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(AppleColors.brandPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppleColors.brandPrimary, lineWidth: 2)
                )
            }
        }
    }
}

// MARK: - Participant Avatar

struct ParticipantAvatar: View {
    let participant: PlanParticipant
    let isOnline: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(AppleColors.brandGradient)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(participant.name.prefix(1))
                            .font(AppleTypography.caption1)
                            .foregroundColor(.white)
                    )

                if isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                        .offset(x: 12, y: 12)
                }
            }

            Text(participant.name)
                .font(AppleTypography.caption1)
                .foregroundColor(AppleColors.textPrimary)
                .lineLimit(1)
        }
    }
}

// MARK: - Empty Plans View

struct EmptyPlansView: View {
    let onCreatePlan: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppleColors.brandPrimary.opacity(0.6))

            VStack(spacing: 12) {
                Text("No Plans Yet")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                Text("Create your first plan to start planning with friends")
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onCreatePlan) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Your First Plan")
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppleColors.brandGradient)
                .cornerRadius(25)
            }
        }
        .padding(40)
    }
}

// MARK: - Create Plan View

struct CreatePlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    @State private var planTitle = ""
    @State private var planDescription = ""
    @State private var selectedOptions: [String] = []
    @State private var newOption = ""

    let onSave: (Plan) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(1 ... 3, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep ? AppleColors.brandPrimary : AppleColors.surfaceSecondary)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 20)

                // Step Content
                switch currentStep {
                case 1:
                    Step1Content(title: $planTitle, description: $planDescription)
                case 2:
                    Step2Content(selectedOptions: $selectedOptions, newOption: $newOption)
                case 3:
                    Step3Content(planTitle: planTitle, planDescription: planDescription, selectedOptions: selectedOptions)
                default:
                    EmptyView()
                }

                Spacer()

                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentStep > 1 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .font(AppleTypography.bodySemibold)
                        .foregroundColor(AppleColors.brandPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppleColors.brandPrimary, lineWidth: 2)
                        )
                    }

                    Spacer()

                    Button(currentStep == 3 ? "Create Plan" : "Next") {
                        if currentStep == 3 {
                            createPlan()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppleColors.brandGradient)
                    .cornerRadius(20)
                    .disabled(currentStep == 1 && (planTitle.isEmpty || planDescription.isEmpty))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Create Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createPlan() {
        let plan = Plan(
            id: UUID(),
            title: planTitle,
            description: planDescription,
            hostId: UUID(), // Current user ID
            hostName: "You", // Current user name
            hostAvatar: nil,
            status: .voting,
            createdAt: Date(),
            votingEndsAt: Calendar.current.date(byAdding: .hour, value: 24, to: Date())!,
            participants: [
                PlanParticipant(id: UUID(), userId: UUID(), name: "You", avatar: nil, joinedAt: Date()),
            ],
            options: selectedOptions.enumerated().map { index, option in
                PlanOption(id: UUID(), name: option, address: "Address \(index + 1)", votes: 0)
            }
        )

        onSave(plan)
        dismiss()
    }
}

// MARK: - Step 1 Content

struct Step1Content: View {
    @Binding var title: String
    @Binding var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Plan Details")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                Text("Plan Title")
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                TextField("Enter plan title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(AppleTypography.body)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                TextField("Describe your plan", text: $description, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(AppleTypography.body)
                    .lineLimit(3 ... 6)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Step 2 Content

struct Step2Content: View {
    @Binding var selectedOptions: [String]
    @Binding var newOption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Options")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            Text("Add places or activities for your friends to vote on")
                .font(AppleTypography.body)
                .foregroundColor(AppleColors.textSecondary)

            // Add new option
            HStack {
                TextField("Add option", text: $newOption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(AppleTypography.body)

                Button("Add") {
                    if !newOption.isEmpty {
                        selectedOptions.append(newOption)
                        newOption = ""
                    }
                }
                .font(AppleTypography.bodySemibold)
                .foregroundColor(AppleColors.brandPrimary)
                .disabled(newOption.isEmpty)
            }

            // Selected options
            LazyVStack(spacing: 8) {
                ForEach(selectedOptions, id: \.self) { option in
                    HStack {
                        Text(option)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textPrimary)

                        Spacer()

                        Button("Remove") {
                            selectedOptions.removeAll { $0 == option }
                        }
                        .font(AppleTypography.caption1)
                        .foregroundColor(.red)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppleColors.surfaceSecondary)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Step 3 Content

struct Step3Content: View {
    let planTitle: String
    let planDescription: String
    let selectedOptions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review Plan")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                Text(planTitle)
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)

                Text(planDescription)
                    .font(AppleTypography.body)
                    .foregroundColor(AppleColors.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppleColors.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Options (\(selectedOptions.count))")
                    .font(AppleTypography.bodySemibold)
                    .foregroundColor(AppleColors.textPrimary)

                LazyVStack(spacing: 8) {
                    ForEach(selectedOptions, id: \.self) { option in
                        HStack {
                            Text(option)
                                .font(AppleTypography.body)
                                .foregroundColor(AppleColors.textPrimary)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppleColors.surfaceSecondary)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Plan Details View

struct PlanDetailsView: View {
    let plan: Plan
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Plan Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(plan.title)
                            .font(AppleTypography.largeTitle)
                            .foregroundColor(AppleColors.textPrimary)

                        Text(plan.description)
                            .font(AppleTypography.body)
                            .foregroundColor(AppleColors.textSecondary)

                        HStack {
                            StatusBadge(status: plan.status)

                            Spacer()

                            Text("Hosted by \(plan.hostName)")
                                .font(AppleTypography.caption1)
                                .foregroundColor(AppleColors.textSecondary)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppleColors.surfaceTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                    )

                    // Plan-specific content
                    switch plan.status {
                    case .voting:
                        VotingDetailsContent(plan: plan)
                    case .locked:
                        LockedDetailsContent(plan: plan)
                    case .live:
                        LiveDetailsContent(plan: plan)
                    case .all:
                        EmptyView()
                    }
                }
                .padding(16)
            }
            .navigationTitle("Plan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Voting Details Content

struct VotingDetailsContent: View {
    let plan: Plan

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vote for your favorite option")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            LazyVStack(spacing: 12) {
                ForEach(plan.options) { option in
                    VotingOptionRow(option: option) {
                        print("Voted for \(option.name)")
                    }
                }
            }
        }
    }
}

// MARK: - Locked Details Content

struct LockedDetailsContent: View {
    let plan: Plan

    var winningOption: PlanOption? {
        plan.options.max { $0.votes < $1.votes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Decision Made!")
                .font(AppleTypography.title3)
                .foregroundColor(AppleColors.textPrimary)

            if let winner = winningOption {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Winner: \(winner.name)")
                        .font(AppleTypography.title3)
                        .foregroundColor(AppleColors.textPrimary)

                    Text(winner.address)
                        .font(AppleTypography.body)
                        .foregroundColor(AppleColors.textSecondary)

                    Text("\(winner.votes) votes")
                        .font(AppleTypography.caption1)
                        .foregroundColor(AppleColors.textSecondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppleColors.surfaceTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        )
                )
            }
        }
    }
}

// MARK: - Live Details Content

struct LiveDetailsContent: View {
    let plan: Plan

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)

                Text("Live Now")
                    .font(AppleTypography.title3)
                    .foregroundColor(AppleColors.textPrimary)
            }

            Text("Participants (\(plan.participants.count))")
                .font(AppleTypography.bodySemibold)
                .foregroundColor(AppleColors.textPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(plan.participants) { participant in
                    ParticipantAvatar(participant: participant, isOnline: true)
                }
            }
        }
    }
}

// MARK: - Data Models

struct Plan: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let hostId: UUID
    let hostName: String
    let hostAvatar: String?
    let status: PlanStatus
    let createdAt: Date
    let votingEndsAt: Date
    let participants: [PlanParticipant]
    let options: [PlanOption]
}

struct PlanParticipant: Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let avatar: String?
    let joinedAt: Date
}

struct PlanOption: Identifiable {
    let id: UUID
    let name: String
    let address: String
    let votes: Int
}

enum PlanStatus: String, CaseIterable {
    case all
    case voting
    case locked
    case live

    var displayName: String {
        switch self {
        case .all: "All"
        case .voting: "Voting"
        case .locked: "Locked"
        case .live: "Live"
        }
    }
}

// MARK: - Preview

#Preview {
    SocialPlansView()
        .background(Color.black)
}
