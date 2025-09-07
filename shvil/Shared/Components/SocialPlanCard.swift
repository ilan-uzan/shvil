//
//  SocialPlanCard.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SocialPlanCard: View {
    let plan: Plan
    let onTap: () -> Void
    let onJoin: () -> Void
    let onVote: (PlanOption) -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                // Header
                planHeader
                
                // Description
                planDescription
                
                // Participants
                participantsSection
                
                // Options (if voting)
                if plan.status == .voting {
                    optionsSection
                }
                
                // Status and Actions
                statusSection
            }
            .padding(DesignTokens.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(DesignTokens.Surface.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                            .stroke(DesignTokens.Stroke.light, lineWidth: 1)
                    )
            )
            .shadow(color: DesignTokens.Shadows.light.color, radius: DesignTokens.Shadows.light.radius, x: DesignTokens.Shadows.light.x, y: DesignTokens.Shadows.light.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var planHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(plan.title)
                    .font(.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("Hosted by \(plan.hostName)")
                    .font(.caption)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
            
            Spacer()
            
            // Status badge
            statusBadge
        }
    }
    
    private var planDescription: some View {
        Text(plan.description)
            .font(.body)
            .foregroundColor(DesignTokens.Text.secondary)
            .lineLimit(2)
    }
    
    private var participantsSection: some View {
        HStack {
            // Participant avatars
            HStack(spacing: -DesignTokens.Spacing.sm) {
                ForEach(Array(plan.participants.prefix(3).enumerated()), id: \.element.id) { index, participant in
                    Circle()
                        .fill(DesignTokens.Brand.primary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(participant.name.prefix(1)))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                        .zIndex(Double(3 - index))
                }
                
                if plan.participants.count > 3 {
                    Circle()
                        .fill(DesignTokens.Surface.secondary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("+\(plan.participants.count - 3)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignTokens.Text.secondary)
                        )
                        .zIndex(0)
                }
            }
            
            Spacer()
            
            Text("\(plan.participants.count) participants")
                .font(.caption)
                .foregroundColor(DesignTokens.Text.tertiary)
        }
    }
    
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Vote for your preference:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Text.secondary)
            
            ForEach(plan.options) { option in
                optionRow(option)
            }
        }
    }
    
    private func optionRow(_ option: PlanOption) -> some View {
        Button(action: { onVote(option) }) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(option.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text(option.address)
                        .font(.caption)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                // Vote count
                Text("\(option.votes)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Brand.primary)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .fill(DesignTokens.Brand.primary.opacity(0.1))
                    )
            }
            .padding(DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(DesignTokens.Surface.secondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusSection: some View {
        HStack {
            // Time remaining
            if let votingEndsAt = plan.votingEndsAt, plan.status == .voting {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    Text(timeRemaining(from: votingEndsAt))
                        .font(.caption)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }
            
            Spacer()
            
            // Action button
            actionButton
        }
    }
    
    private var statusBadge: some View {
        Text(plan.status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(statusColor)
            )
    }
    
    private var actionButton: some View {
        Button(action: onJoin) {
            Text(buttonText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Brand.primary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                        .stroke(DesignTokens.Brand.primary, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch plan.status {
        case .voting: return DesignTokens.Semantic.warning
        case .locked: return DesignTokens.Semantic.success
        case .active: return DesignTokens.Brand.primary
        case .completed: return DesignTokens.Text.tertiary
        case .cancelled: return DesignTokens.Semantic.error
        case .all: return DesignTokens.Brand.primary
        }
    }
    
    private var buttonText: String {
        switch plan.status {
        case .voting: return "Vote"
        case .locked: return "Join"
        case .active: return "View"
        case .completed: return "Recap"
        case .cancelled: return "Closed"
        case .all: return "View"
        }
    }
    
    private func timeRemaining(from date: Date) -> String {
        let timeInterval = date.timeIntervalSinceNow
        if timeInterval <= 0 {
            return "Voting ended"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m left"
        } else {
            return "\(minutes)m left"
        }
    }
}

#Preview {
    SocialPlanCard(
        plan: Plan(
            title: "Weekend Brunch Adventure",
            description: "Let's explore the best brunch spots in the city!",
            hostId: UUID(),
            hostName: "Sarah Chen",
            status: .voting,
            participants: [
                PlanParticipant(userId: UUID(), name: "Sarah Chen"),
                PlanParticipant(userId: UUID(), name: "Mike Johnson"),
                PlanParticipant(userId: UUID(), name: "Emma Wilson")
            ],
            options: [
                PlanOption(name: "Blue Bottle Coffee", address: "123 Market St", votes: 3),
                PlanOption(name: "Farmers Market", address: "456 Union St", votes: 2)
            ]
        ),
        onTap: {},
        onJoin: {},
        onVote: { _ in }
    )
    .padding()
}
