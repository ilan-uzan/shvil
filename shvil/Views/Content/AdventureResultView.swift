//
//  AdventureResultView.swift
//  shvil
//
//  View to display created adventure results
//

import SwiftUI

struct AdventureResultView: View {
    let adventure: Adventure
    @Environment(\.dismiss) private var dismiss
    @State private var showMap = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    // Header
                    VStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(DesignTokens.Brand.primary)
                        
                        Text("Adventure Created!")
                            .font(DesignTokens.Typography.largeTitle)
                            .foregroundColor(DesignTokens.Text.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Your personalized adventure is ready")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Text.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DesignTokens.Spacing.xl)
                    
                    // Adventure Details Card
                    GlassCard(style: .primary) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text(adventure.title)
                                .font(DesignTokens.Typography.title2)
                                .foregroundColor(DesignTokens.Text.primary)
                            
                            Text(adventure.description)
                                .font(DesignTokens.Typography.body)
                                .foregroundColor(DesignTokens.Text.secondary)
                            
                            Divider()
                            
                            // Route Information
                            VStack(spacing: DesignTokens.Spacing.sm) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(DesignTokens.Brand.primary)
                                    Text("Duration: \(formatDuration(adventure.routeData.duration))")
                                        .font(DesignTokens.Typography.callout)
                                        .foregroundColor(DesignTokens.Text.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(DesignTokens.Brand.primary)
                                    Text("Distance: \(formatDistance(adventure.routeData.distance))")
                                        .font(DesignTokens.Typography.callout)
                                        .foregroundColor(DesignTokens.Text.secondary)
                                }
                                
                                HStack {
                                    Image(systemName: "car")
                                        .foregroundColor(DesignTokens.Brand.primary)
                                    Text("Transport: \(adventure.routeData.transportMode.capitalized)")
                                        .font(DesignTokens.Typography.callout)
                                        .foregroundColor(DesignTokens.Text.secondary)
                                }
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: DesignTokens.Spacing.md) {
                        GlassButton(
                            "View on Map",
                            icon: "map",
                            style: .primary,
                            size: .large
                        ) {
                            showMap = true
                        }
                        
                        GlassButton(
                            "Start Adventure",
                            icon: "play.fill",
                            style: .secondary,
                            size: .large
                        ) {
                            // TODO: Start adventure navigation
                            dismiss()
                        }
                        
                        GlassButton(
                            "Save as Draft",
                            icon: "bookmark",
                            style: .ghost,
                            size: .medium
                        ) {
                            // TODO: Save adventure
                            dismiss()
                        }
                    }
                    
                    Spacer(minLength: DesignTokens.Spacing.xl)
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .background(DesignTokens.Surface.background)
            .navigationTitle("Adventure Created")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Brand.primary)
                }
            }
        }
        .sheet(isPresented: $showMap) {
            // TODO: Show map with adventure route
            Text("Map View Coming Soon")
                .padding()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDistance(_ distance: Int) -> String {
        if distance >= 1000 {
            return "\(String(format: "%.1f", Double(distance) / 1000)) km"
        } else {
            return "\(distance) m"
        }
    }
}

#Preview {
    AdventureResultView(adventure: Adventure(
        id: UUID(),
        userId: UUID(),
        title: "Exploration Adventure in Jerusalem",
        description: "A 2 hours exploration experience exploring Jerusalem, Israel by walking.",
        routeData: RouteData(
            origin: LocationData(latitude: 31.7683, longitude: 35.2137, address: "Jerusalem, Israel"),
            destination: LocationData(latitude: 31.7683, longitude: 35.2137, address: "Jerusalem Destination"),
            waypoints: [],
            distance: 4000,
            duration: 7200,
            transportMode: "walking",
            estimatedArrival: Date()
        ),
        stops: [],
        status: .draft,
        createdAt: Date(),
        updatedAt: Date()
    ))
}
