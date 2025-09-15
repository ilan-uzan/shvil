//
//  DownloadsView.swift
//  shvil
//
//  Downloads management view for offline content
//

import SwiftUI
import MapKit

struct DownloadsView: View {
    @StateObject private var offlineManager = DependencyContainer.shared.offlineManager
    @State private var showingDownloadSheet = false
    @State private var selectedRegion: DownloadRegion?
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Surface.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        // Storage Usage Card
                        GlassCard(style: .primary) {
                            VStack(spacing: DesignTokens.Spacing.md) {
                                HStack {
                                    Image(systemName: "internaldrive")
                                        .font(.system(size: 24))
                                        .foregroundColor(DesignTokens.Brand.primary)
                                    
                                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                        Text("Storage Used")
                                            .font(DesignTokens.Typography.headline)
                                            .foregroundColor(DesignTokens.Text.primary)
                                        
                                        Text(formatStorageSize(offlineManager.storageUsed))
                                            .font(DesignTokens.Typography.body)
                                            .foregroundColor(DesignTokens.Text.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("500 MB")
                                        .font(DesignTokens.Typography.caption1)
                                        .foregroundColor(DesignTokens.Text.tertiary)
                                }
                                
                                // Storage Progress Bar
                                ProgressView(value: Double(offlineManager.storageUsed), total: 500 * 1024 * 1024)
                                    .progressViewStyle(LinearProgressViewStyle(tint: DesignTokens.Brand.primary))
                                    .scaleEffect(y: 2)
                            }
                        }
                        
                        // Download New Region Button
                        GlassButton(
                            "Download New Region",
                            icon: "plus.circle",
                            style: .primary,
                            size: .large
                        ) {
                            showingDownloadSheet = true
                        }
                        
                        // Downloaded Regions List
                        if offlineManager.downloadedRegions.isEmpty {
                            GlassEmptyState(
                                icon: "map",
                                title: "No Downloads",
                                description: "Download regions to use the app offline",
                                actionTitle: "Download Region",
                                action: {
                                    showingDownloadSheet = true
                                }
                            )
                        } else {
                            LazyVStack(spacing: DesignTokens.Spacing.sm) {
                                ForEach(offlineManager.downloadedRegions) { region in
                                    DownloadRegionCard(region: region) {
                                        selectedRegion = region
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: DesignTokens.Spacing.xl)
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
            }
            .navigationTitle("Downloads")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        // TODO: Clear all downloads
                    }
                    .foregroundColor(DesignTokens.Semantic.error)
                }
            }
        }
        .sheet(isPresented: $showingDownloadSheet) {
            DownloadRegionSheet()
        }
        .sheet(item: $selectedRegion) { region in
            DownloadRegionDetailsView(region: region)
        }
    }
    
    private func formatStorageSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct DownloadRegionCard: View {
    let region: DownloadRegion
    let onTap: () -> Void
    
    var body: some View {
        GlassListRow(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Status Icon
                Image(systemName: statusIcon)
                    .font(.system(size: 20))
                    .foregroundColor(statusColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(statusColor.opacity(0.1))
                    )
                
                // Region Info
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(region.name)
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text("\(formatStorageSize(region.size)) • \(region.downloadedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                // Action Button
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignTokens.Text.tertiary)
            }
        }
    }
    
    private var statusIcon: String {
        switch region.status {
        case .pending: return "clock.circle"
        case .downloading: return "arrow.down.circle"
        case .completed: return "checkmark.circle"
        case .failed: return "xmark.circle"
        case .paused: return "pause.circle"
        }
    }
    
    private var statusColor: Color {
        switch region.status {
        case .pending: return DesignTokens.Text.tertiary
        case .downloading: return DesignTokens.Brand.primary
        case .completed: return DesignTokens.Semantic.success
        case .failed: return DesignTokens.Semantic.error
        case .paused: return DesignTokens.Semantic.warning
        }
    }
    
    private func formatStorageSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct DownloadRegionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var offlineManager = DependencyContainer.shared.offlineManager
    @State private var regionName = ""
    @State private var selectedRadius: Double = 5.0
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Region Name Input
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Region Name")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    TextField("Enter region name", text: $regionName)
                        .textFieldStyle(AppleTextFieldStyle())
                }
                
                // Radius Slider
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Radius: \(String(format: "%.1f", selectedRadius)) km")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Slider(value: $selectedRadius, in: 1...20, step: 0.5)
                        .tint(DesignTokens.Brand.primary)
                }
                
                // Location Info
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Location")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Text.primary)
                    
                    Text("Jerusalem, Israel")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
                
                Spacer()
                
                // Download Button
                GlassButton(
                    "Download Region",
                    icon: "arrow.down.circle",
                    style: .primary,
                    size: .large,
                    isDisabled: regionName.isEmpty
                ) {
                    offlineManager.downloadRegion(
                        center: selectedLocation,
                        radius: selectedRadius * 1000, // Convert to meters
                        name: regionName
                    ) { result in
                        switch result {
                        case .success:
                            dismiss()
                        case .failure(let error):
                            print("Download failed: \(error)")
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Download Region")
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
}

struct DownloadRegionDetailsView: View {
    let region: DownloadRegion
    @Environment(\.dismiss) private var dismiss
    @StateObject private var offlineManager = DependencyContainer.shared.offlineManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Region Info
                GlassCard(style: .primary) {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        HStack {
                            Image(systemName: "map")
                                .font(.system(size: 24))
                                .foregroundColor(DesignTokens.Brand.primary)
                            
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text(region.name)
                                    .font(DesignTokens.Typography.title2)
                                    .foregroundColor(DesignTokens.Text.primary)
                                
                                Text("Downloaded \(region.downloadedAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(DesignTokens.Typography.caption1)
                                    .foregroundColor(DesignTokens.Text.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Size")
                                    .font(DesignTokens.Typography.caption1)
                                    .foregroundColor(DesignTokens.Text.secondary)
                                Text(formatStorageSize(region.size))
                                    .font(DesignTokens.Typography.body)
                                    .foregroundColor(DesignTokens.Text.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Radius")
                                    .font(DesignTokens.Typography.caption1)
                                    .foregroundColor(DesignTokens.Text.secondary)
                                Text("\(String(format: "%.1f", region.radius / 1000)) km")
                                    .font(DesignTokens.Typography.body)
                                    .foregroundColor(DesignTokens.Text.primary)
                            }
                        }
                    }
                }
                
                // Actions
                VStack(spacing: DesignTokens.Spacing.md) {
                    GlassButton(
                        "Use Offline",
                        icon: "wifi.slash",
                        style: .primary,
                        size: .large
                    ) {
                        // TODO: Enable offline mode
                        dismiss()
                    }
                    
                    GlassButton(
                        "Delete Region",
                        icon: "trash",
                        style: .destructive,
                        size: .medium
                    ) {
                        // TODO: Delete region
                        dismiss()
                    }
                }
                
                Spacer()
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Region Details")
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
    
    private func formatStorageSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    DownloadsView()
}
