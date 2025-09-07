//
//  SocializeView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SocializeView: View {
    @StateObject private var socialService = DependencyContainer.shared.socialService
    @State private var showCreateGroup = false
    @State private var showJoinGroup = false
    @State private var selectedGroup: SocialGroup?
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                
                if socialService.groups.isEmpty {
                    emptyState
                } else {
                    groupsList
                }
            }
            .navigationTitle("Socialize")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateGroup = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(DesignTokens.Brand.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView()
            }
            .sheet(isPresented: $showJoinGroup) {
                JoinGroupView()
            }
            .sheet(item: $selectedGroup) { group in
                GroupDetailView(group: group)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignTokens.Brand.primary)
            
            Text("Start Socializing")
                .font(DesignTokens.Typography.headline)
                .foregroundColor(DesignTokens.Text.primary)
            
            Text("Create or join a group to start exploring together")
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: DesignTokens.Spacing.md) {
                LiquidGlassButton(
                    "Create Group",
                    icon: "plus.circle.fill",
                    style: .primary,
                    action: { showCreateGroup = true }
                )
                
                LiquidGlassButton(
                    "Join Group",
                    icon: "qrcode",
                    style: .secondary,
                    action: { showJoinGroup = true }
                )
            }
        }
        .padding(DesignTokens.Spacing.xl)
    }
    
    private var groupsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(socialService.groups) { group in
                    GroupCard(group: group) {
                        selectedGroup = group
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
        }
    }
}

// MARK: - Group Card

struct GroupCard: View {
    let group: SocialGroup
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Group Avatar
                Circle()
                    .fill(DesignTokens.Brand.gradient)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(group.name.prefix(1).uppercased())
                            .font(DesignTokens.Typography.title2)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(group.name)
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text(group.description ?? "No description")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(group.memberCount) members")
                            .font(DesignTokens.Typography.caption1)
                    }
                    .foregroundColor(DesignTokens.Text.tertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignTokens.Text.tertiary)
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

// MARK: - Create Group View

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var socialService = DependencyContainer.shared.socialService
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Group Avatar
                Circle()
                    .fill(DesignTokens.Brand.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(groupName.prefix(1).uppercased())
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: DesignTokens.Spacing.md) {
                    TextField("Group Name", text: $groupName)
                        .textFieldStyle(LiquidGlassTextFieldStyle())
                    
                    TextField("Description (Optional)", text: $groupDescription, axis: .vertical)
                        .textFieldStyle(LiquidGlassTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Spacer()
                
                LiquidGlassButton(
                    "Create Group",
                    icon: "plus.circle.fill",
                    style: .primary,
                    isLoading: isCreating,
                    isDisabled: groupName.isEmpty,
                    action: createGroup
                )
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func createGroup() {
        isCreating = true
        Task {
            do {
                let group = SocialGroup(
                    name: groupName,
                    description: groupDescription.isEmpty ? nil : groupDescription,
                    createdBy: UUID(), // TODO: Get from auth
                    inviteCode: generateInviteCode(),
                    qrCode: generateQRCode(),
                    memberCount: 1,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                try await socialService.createGroup(group)
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
    
    private func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    private func generateQRCode() -> String {
        // TODO: Generate actual QR code
        return "QR_CODE_DATA"
    }
}

// MARK: - Join Group View

struct JoinGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var socialService = DependencyContainer.shared.socialService
    @State private var inviteCode = ""
    @State private var isJoining = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(DesignTokens.Brand.primary)
                
                Text("Join a Group")
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("Enter the invite code or scan a QR code")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Invite Code", text: $inviteCode)
                    .textFieldStyle(LiquidGlassTextFieldStyle())
                    .textCase(.uppercase)
                    .autocapitalization(.allCharacters)
                
                Spacer()
                
                VStack(spacing: DesignTokens.Spacing.md) {
                    LiquidGlassButton(
                        "Join Group",
                        icon: "person.badge.plus",
                        style: .primary,
                        isLoading: isJoining,
                        isDisabled: inviteCode.isEmpty,
                        action: joinGroup
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
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func joinGroup() {
        isJoining = true
        Task {
            do {
                try await socialService.joinGroup(inviteCode: inviteCode)
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

// MARK: - Group Detail View

struct GroupDetailView: View {
    let group: SocialGroup
    @Environment(\.dismiss) private var dismiss
    @State private var showInviteSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Group Header
                VStack(spacing: DesignTokens.Spacing.md) {
                    Circle()
                        .fill(DesignTokens.Brand.gradient)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(group.name.prefix(1).uppercased())
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                    
                    Text(group.name)
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    if let description = group.description {
                        Text(description)
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Group Stats
                HStack(spacing: DesignTokens.Spacing.xl) {
                    VStack {
                        Text("\(group.memberCount)")
                            .font(DesignTokens.Typography.title2)
                            .foregroundColor(DesignTokens.Brand.primary)
                        Text("Members")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                    
                    VStack {
                        Text("0")
                            .font(DesignTokens.Typography.title2)
                            .foregroundColor(DesignTokens.Brand.primary)
                        Text("Active Hunts")
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(DesignTokens.Text.secondary)
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: DesignTokens.Spacing.md) {
                    LiquidGlassButton(
                        "Invite Friends",
                        icon: "person.badge.plus",
                        style: .primary,
                        action: { showInviteSheet = true }
                    )
                    
                    LiquidGlassButton(
                        "Start Hunt",
                        icon: "flag.fill",
                        style: .secondary,
                        action: startHunt
                    )
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Group Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showInviteSheet) {
                InviteSheetView(group: group)
            }
        }
    }
    
    private func startHunt() {
        // TODO: Navigate to hunt creation
    }
}

// MARK: - Invite Sheet View

struct InviteSheetView: View {
    let group: SocialGroup
    @Environment(\.dismiss) private var dismiss
    @State private var showQRCode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                Text("Invite Friends to \(group.name)")
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                    .multilineTextAlignment(.center)
                
                // Invite Code
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("Invite Code")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                    
                    Text(group.inviteCode)
                        .font(DesignTokens.Typography.title)
                        .foregroundColor(DesignTokens.Brand.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                                .fill(DesignTokens.Surface.secondary)
                        )
                }
                
                // QR Code
                if showQRCode {
                    // TODO: Generate actual QR code
                    Rectangle()
                        .fill(DesignTokens.Surface.secondary)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text("QR Code")
                                .foregroundColor(DesignTokens.Text.secondary)
                        )
                }
                
                Spacer()
                
                VStack(spacing: DesignTokens.Spacing.md) {
                    LiquidGlassButton(
                        showQRCode ? "Hide QR Code" : "Show QR Code",
                        icon: "qrcode",
                        style: .secondary,
                        action: { showQRCode.toggle() }
                    )
                    
                    LiquidGlassButton(
                        "Share Invite",
                        icon: "square.and.arrow.up",
                        style: .primary,
                        action: shareInvite
                    )
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func shareInvite() {
        // TODO: Implement share functionality
    }
}

// MARK: - Preview

#Preview {
    SocializeView()
}
