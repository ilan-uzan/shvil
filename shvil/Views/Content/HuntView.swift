//
//  HuntView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct HuntView: View {
    @StateObject private var huntService = DependencyContainer.shared.huntService
    @State private var showCreateHunt = false
    @State private var showJoinHunt = false
    @State private var selectedHunt: ScavengerHunt?
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                
                if huntService.hunts.isEmpty {
                    emptyState
                } else {
                    huntsList
                }
            }
            .navigationTitle("Scavenger Hunts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateHunt = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(DesignTokens.Brand.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateHunt) {
                CreateHuntView()
            }
            .sheet(isPresented: $showJoinHunt) {
                JoinHuntView()
            }
            .sheet(item: $selectedHunt) { hunt in
                HuntDetailView(hunt: hunt)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: "flag.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignTokens.Brand.primary)
            
            Text("Start Hunting")
                .font(DesignTokens.Typography.headline)
                .foregroundColor(DesignTokens.Text.primary)
            
            Text("Create or join a scavenger hunt to start exploring")
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: DesignTokens.Spacing.md) {
                LiquidGlassButton(
                    "Create Hunt",
                    icon: "plus.circle.fill",
                    style: .primary,
                    action: { showCreateHunt = true }
                )
                
                LiquidGlassButton(
                    "Join Hunt",
                    icon: "qrcode",
                    style: .secondary,
                    action: { showJoinHunt = true }
                )
            }
        }
        .padding(DesignTokens.Spacing.xl)
    }
    
    private var huntsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(huntService.hunts) { hunt in
                    HuntCard(hunt: hunt) {
                        selectedHunt = hunt
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
        }
    }
}

// MARK: - Hunt Card

struct HuntCard: View {
    let hunt: ScavengerHunt
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(hunt.title)
                            .font(DesignTokens.Typography.headline)
                            .foregroundColor(DesignTokens.Text.primary)
                        
                        if let description = hunt.description {
                            Text(description)
                                .font(DesignTokens.Typography.body)
                                .foregroundColor(DesignTokens.Text.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    HuntStatusBadge(status: hunt.status)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(hunt.participantCount) participants")
                            .font(DesignTokens.Typography.caption1)
                    }
                    .foregroundColor(DesignTokens.Text.tertiary)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                        Text("\(hunt.checkpointCount) checkpoints")
                            .font(DesignTokens.Typography.caption1)
                    }
                    .foregroundColor(DesignTokens.Text.tertiary)
                }
                
                if hunt.status == .active {
                    ProgressView(value: hunt.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: DesignTokens.Brand.primary))
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(DesignTokens.Surface.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                            .stroke(DesignTokens.Glass.light, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Hunt Status Badge

struct HuntStatusBadge: View {
    let status: HuntStatus
    
    var body: some View {
        Text(status.displayName)
            .font(DesignTokens.Typography.caption1)
            .fontWeight(.semibold)
            .foregroundColor(statusTextColor)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(statusBackgroundColor)
            )
    }
    
    private var statusTextColor: Color {
        switch status {
        case .draft:
            return DesignTokens.Text.tertiary
        case .active:
            return DesignTokens.Semantic.success
        case .completed:
            return DesignTokens.Text.primary
        case .cancelled:
            return DesignTokens.Semantic.error
        }
    }
    
    private var statusBackgroundColor: Color {
        switch status {
        case .draft:
            return DesignTokens.Surface.tertiary
        case .active:
            return DesignTokens.Semantic.success.opacity(0.1)
        case .completed:
            return DesignTokens.Surface.secondary
        case .cancelled:
            return DesignTokens.Semantic.error.opacity(0.1)
        }
    }
}

// MARK: - Create Hunt View

struct CreateHuntView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var huntService = DependencyContainer.shared.huntService
    @State private var huntTitle = ""
    @State private var huntDescription = ""
    @State private var selectedGroup: SocialGroup?
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    TextField("Hunt Title", text: $huntTitle)
                        .textFieldStyle(LiquidGlassTextFieldStyle())
                    
                    TextField("Description (Optional)", text: $huntDescription, axis: .vertical)
                        .textFieldStyle(LiquidGlassTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                // Group Selection
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Select Group")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                    
                    Button(action: selectGroup) {
                        HStack {
                            Text(selectedGroup?.name ?? "Choose Group")
                                .foregroundColor(selectedGroup == nil ? DesignTokens.Text.tertiary : DesignTokens.Text.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(DesignTokens.Text.tertiary)
                        }
                        .padding(DesignTokens.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                                .fill(DesignTokens.Surface.secondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                                        .stroke(DesignTokens.Glass.light, lineWidth: 1)
                                )
                        )
                    }
                }
                
                Spacer()
                
                LiquidGlassButton(
                    "Create Hunt",
                    icon: "plus.circle.fill",
                    style: .primary,
                    isLoading: isCreating,
                    isDisabled: huntTitle.isEmpty || selectedGroup == nil,
                    action: createHunt
                )
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Create Hunt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func selectGroup() {
        // TODO: Show group selection sheet
    }
    
    private func createHunt() {
        isCreating = true
        Task {
            do {
                let hunt = ScavengerHunt(
                    title: huntTitle,
                    description: huntDescription.isEmpty ? nil : huntDescription,
                    createdBy: UUID(), // TODO: Get from auth
                    groupId: selectedGroup?.id,
                    status: .draft,
                    startTime: nil,
                    endTime: nil,
                    participantCount: 0,
                    checkpointCount: 0,
                    progress: 0.0,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                try await huntService.createHunt(hunt)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                // Handle error
                await MainActor.run {
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Join Hunt View

struct JoinHuntView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var huntService = DependencyContainer.shared.huntService
    @State private var huntCode = ""
    @State private var isJoining = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 60))
                    .foregroundColor(DesignTokens.Brand.primary)
                
                Text("Join a Hunt")
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("Enter the hunt code or scan a QR code")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Hunt Code", text: $huntCode)
                    .textFieldStyle(LiquidGlassTextFieldStyle())
                    .textCase(.uppercase)
                    .autocapitalization(.allCharacters)
                
                Spacer()
                
                VStack(spacing: DesignTokens.Spacing.md) {
                    LiquidGlassButton(
                        "Join Hunt",
                        icon: "person.badge.plus",
                        style: .primary,
                        isLoading: isJoining,
                        isDisabled: huntCode.isEmpty,
                        action: joinHunt
                    )
                    
                    LiquidGlassButton(
                        "Scan QR Code",
                        icon: "qrcode.viewfinder",
                        style: .secondary,
                        action: scanQRCode
                    )
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Join Hunt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func joinHunt() {
        isJoining = true
        Task {
            do {
                try await huntService.joinHunt(huntCode: huntCode)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                // Handle error
                await MainActor.run {
                    isJoining = false
                }
            }
        }
    }
    
    private func scanQRCode() {
        // TODO: Implement QR code scanning
    }
}

// MARK: - Hunt Detail View

struct HuntDetailView: View {
    let hunt: ScavengerHunt
    @Environment(\.dismiss) private var dismiss
    @State private var showLeaderboard = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Hunt Header
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text(hunt.title)
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                        .multilineTextAlignment(.center)
                    
                    if let description = hunt.description {
                        Text(description)
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    HuntStatusBadge(status: hunt.status)
                }
                
                // Hunt Stats
                HStack(spacing: DesignTokens.Spacing.xl) {
                    VStack {
                        Text("\(hunt.participantCount)")
                            .font(DesignTokens.Typography.title2)
                            .foregroundColor(DesignTokens.Brand.primary)
                        Text("Participants")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    
                    VStack {
                        Text("\(hunt.checkpointCount)")
                            .font(DesignTokens.Typography.title2)
                            .foregroundColor(DesignTokens.Brand.primary)
                        Text("Checkpoints")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                }
                
                if hunt.status == .active {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Progress")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                        
                        ProgressView(value: hunt.progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: DesignTokens.Brand.primary))
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: DesignTokens.Spacing.md) {
                    if hunt.status == .active {
                        LiquidGlassButton(
                            "Continue Hunt",
                            icon: "play.fill",
                            style: .primary,
                            action: continueHunt
                        )
                    } else if hunt.status == .draft {
                        LiquidGlassButton(
                            "Start Hunt",
                            icon: "play.fill",
                            style: .primary,
                            action: startHunt
                        )
                    }
                    
                    LiquidGlassButton(
                        "View Leaderboard",
                        icon: "trophy.fill",
                        style: .secondary,
                        action: { showLeaderboard = true }
                    )
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Hunt Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView(hunt: hunt)
            }
        }
    }
    
    private func continueHunt() {
        // TODO: Navigate to hunt gameplay
    }
    
    private func startHunt() {
        // TODO: Start the hunt
    }
}

// MARK: - Leaderboard View

struct LeaderboardView: View {
    let hunt: ScavengerHunt
    @Environment(\.dismiss) private var dismiss
    @StateObject private var huntService = DependencyContainer.shared.huntService
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Leaderboard")
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                if huntService.leaderboard.isEmpty {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "trophy")
                            .font(.system(size: 40))
                            .foregroundColor(DesignTokens.Text.tertiary)
                        
                        Text("No participants yet")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    .padding(DesignTokens.Spacing.xl)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(Array(huntService.leaderboard.enumerated()), id: \.element.id) { index, participant in
                                LeaderboardRow(
                                    rank: index + 1,
                                    participant: participant
                                )
                            }
                        }
                        .padding(DesignTokens.Spacing.md)
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let rank: Int
    let participant: LeaderboardParticipant
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Rank
            Text("\(rank)")
                .font(DesignTokens.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(rank <= 3 ? DesignTokens.Brand.primary : DesignTokens.Text.primary)
                .frame(width: 30)
            
            // Avatar
            Circle()
                .fill(DesignTokens.Brand.gradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(participant.name.prefix(1).uppercased())
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(.white)
                )
            
            // Name and Score
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(participant.name)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("\(participant.score) points")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
            
            Spacer()
            
            // Trophy icon for top 3
            if rank <= 3 {
                Image(systemName: "trophy.fill")
                    .font(.title3)
                    .foregroundColor(rank == 1 ? .yellow : rank == 2 ? .gray : .orange)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                .fill(rank <= 3 ? DesignTokens.Brand.primary.opacity(0.1) : DesignTokens.Surface.primary)
        )
    }
}

// MARK: - #Preview

#Preview {
    HuntView()
}
