//
//  SmartStopCard.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import CoreLocation
import MapKit

/// Smart stop suggestion card component for navigation
struct SmartStopCard: View {
    let suggestion: SmartStopSuggestion
    let onAddStop: () -> Void
    let onDismiss: () -> Void
    let onSnooze: () -> Void
    
    @State private var isPressed = false
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card Content
            HStack(spacing: 12) {
                // Icon
                Image(systemName: suggestion.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(suggestion.color.color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(suggestion.color.color.opacity(0.2))
                            .overlay(
                                Circle()
                                    .stroke(suggestion.color.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(DesignTokens.Text.primary)
                        .lineLimit(1)
                    
                    Text(suggestion.subtitle)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                        .lineLimit(2)
                    
                    // Distance and Time
                    HStack(spacing: 8) {
                        Label(distanceText, systemImage: "location")
                            .font(AppleTypography.caption2)
                            .foregroundColor(DesignTokens.Brand.primary)
                        
                        Text("•")
                            .font(AppleTypography.caption2)
                            .foregroundColor(DesignTokens.Text.secondary)
                        
                        Label(timeText, systemImage: "clock")
                            .font(AppleTypography.caption2)
                            .foregroundColor(DesignTokens.Brand.primary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 8) {
                    // Add Stop Button
                    Button(action: {
                        withAnimation(AppleAnimations.microInteraction) {
                            onAddStop()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(DesignTokens.Brand.primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(DesignTokens.Surface.secondary)
                                    .overlay(
                                        Circle()
                                            .stroke(DesignTokens.Brand.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonAccessibility(
                        label: "Add stop",
                        hint: "Tap to add this stop to your route"
                    )
                    
                    // Dismiss Button
                    Button(action: {
                        withAnimation(AppleAnimations.microInteraction) {
                            onDismiss()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary)
                            .frame(width: 24, height: 24)
                    }
                    .buttonAccessibility(
                        label: "Dismiss",
                        hint: "Tap to dismiss this suggestion"
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Details Section (Expandable)
            if showDetails {
                VStack(spacing: 12) {
                    Divider()
                        .background(DesignTokens.Text.secondary.opacity(0.3))
                    
                    // Additional Actions
                    HStack(spacing: 16) {
                        // Snooze Button
                        Button(action: {
                            withAnimation(AppleAnimations.microInteraction) {
                                onSnooze()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Snooze")
                                    .font(DesignTokens.Typography.caption1Medium)
                            }
                            .foregroundColor(DesignTokens.Brand.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignTokens.Surface.secondary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(DesignTokens.Brand.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonAccessibility(
                            label: "Snooze suggestion",
                            hint: "Tap to snooze this suggestion for 5 minutes"
                        )
                        
                        Spacer()
                        
                        // Relevance Score Indicator
                        HStack(spacing: 4) {
                            Text("Relevance")
                                .font(AppleTypography.caption2)
                                .foregroundColor(DesignTokens.Text.secondary)
                            
                            RelevanceIndicator(score: suggestion.relevanceScore)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignTokens.Surface.tertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(suggestion.color.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppleAnimations.microInteraction, value: isPressed)
        .onTapGesture {
            withAnimation(DesignTokens.Animation.standard) {
                showDetails.toggle()
            }
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 50) { pressing in
            isPressed = pressing
        } perform: {
            // Long press action - could show more details
            withAnimation(DesignTokens.Animation.standard) {
                showDetails.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suggestion.title): \(suggestion.subtitle)")
        .accessibilityHint("Tap to expand details, double tap to add stop")
        .accessibilityAction(named: "Add Stop") {
            onAddStop()
        }
        .accessibilityAction(named: "Dismiss") {
            onDismiss()
        }
        .accessibilityAction(named: "Snooze") {
            onSnooze()
        }
    }
    
    // MARK: - Computed Properties
    private var distanceText: String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: suggestion.estimatedDistance)
    }
    
    private var timeText: String {
        let minutes = Int(suggestion.estimatedTime / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

// MARK: - Relevance Indicator
struct RelevanceIndicator: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < Int(score * 5) ? DesignTokens.Brand.primary : DesignTokens.Text.secondary.opacity(0.3))
                    .frame(width: 4, height: 4)
            }
        }
    }
}

// MARK: - Smart Stop Card Container
struct SmartStopCardContainer: View {
    let suggestions: [SmartStopSuggestion]
    let onAddStop: (SmartStopSuggestion) -> Void
    let onDismiss: (SmartStopSuggestion) -> Void
    let onSnooze: (SmartStopSuggestion) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(suggestions) { suggestion in
                SmartStopCard(
                    suggestion: suggestion,
                    onAddStop: { onAddStop(suggestion) },
                    onDismiss: { onDismiss(suggestion) },
                    onSnooze: { onSnooze(suggestion) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        SmartStopCard(
            suggestion: SmartStopSuggestion(
                type: .fuel,
                title: "Fuel Stop",
                subtitle: "Long route ahead - consider refueling",
                relevanceScore: 0.9,
                estimatedDistance: 5000,
                estimatedTime: 600,
                icon: "fuelpump.fill",
                color: .orange
            ),
            onAddStop: { },
            onDismiss: { },
            onSnooze: { }
        )
        
        SmartStopCard(
            suggestion: SmartStopSuggestion(
                type: .food,
                title: "Food Stop",
                subtitle: "Meal time - find restaurants nearby",
                relevanceScore: 0.8,
                estimatedDistance: 2000,
                estimatedTime: 300,
                icon: "fork.knife",
                color: .green
            ),
            onAddStop: { },
            onDismiss: { },
            onSnooze: { }
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
