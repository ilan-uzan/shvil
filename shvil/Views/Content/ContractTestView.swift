//
//  ContractTestView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct ContractTestView: View {
    @StateObject private var contractTestingService = ContractTestingService.shared
    @State private var showDetails = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // Header
                headerSection
                
                // Overall Status
                overallStatusSection
                
                // Test Results
                testResultsSection
                
                Spacer()
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle("Contract Tests")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: runTests) {
                        Image(systemName: "play.fill")
                            .foregroundColor(DesignTokens.Brand.primary)
                    }
                    .disabled(contractTestingService.isRunningTests)
                }
            }
        }
        .onAppear {
            if contractTestingService.testResults.isEmpty {
                runTests()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Text("API Contract Testing")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignTokens.Text.primary)
            
            Text("Verify frontend-backend compatibility")
                .font(.body)
                .foregroundColor(DesignTokens.Text.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var overallStatusSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Overall Status")
                    .font(.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Spacer()
                
                statusBadge(contractTestingService.overallStatus)
            }
            
            if contractTestingService.isRunningTests {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("Running tests...")
                        .font(.caption)
                        .foregroundColor(DesignTokens.Text.secondary)
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(DesignTokens.Stroke.light, lineWidth: 1)
                )
        )
    }
    
    private var testResultsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text("Test Results")
                    .font(.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Spacer()
                
                Button(action: { showDetails.toggle() }) {
                    Text(showDetails ? "Hide Details" : "Show Details")
                        .font(.caption)
                        .foregroundColor(DesignTokens.Brand.primary)
                }
            }
            
            if contractTestingService.testResults.isEmpty && !contractTestingService.isRunningTests {
                Text("No tests run yet. Tap the play button to start testing.")
                    .font(.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(DesignTokens.Spacing.lg)
            } else {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(contractTestingService.testResults) { result in
                        testResultRow(result)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(DesignTokens.Stroke.light, lineWidth: 1)
                )
        )
    }
    
    private func testResultRow(_ result: ContractTestResult) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text(result.testName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Spacer()
                
                statusBadge(result.status)
            }
            
            HStack {
                Text("\(result.passed)/\(result.total) tests passed")
                    .font(.caption)
                    .foregroundColor(DesignTokens.Text.secondary)
                
                Spacer()
                
                Text("\(Int(result.successRate * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(result.status == .passed ? DesignTokens.Semantic.success : DesignTokens.Semantic.error)
            }
            
            if showDetails && !result.errors.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    ForEach(result.errors, id: \.self) { error in
                        Text("• \(error)")
                            .font(.caption)
                            .foregroundColor(DesignTokens.Semantic.error)
                    }
                }
                .padding(.top, DesignTokens.Spacing.xs)
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                .fill(DesignTokens.Surface.secondary)
        )
    }
    
    private func statusBadge(_ status: ContractTestStatus) -> some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                    .fill(statusColor(status))
            )
    }
    
    private func statusColor(_ status: ContractTestStatus) -> Color {
        switch status {
        case .notRun: return DesignTokens.Text.tertiary
        case .running: return DesignTokens.Brand.primary
        case .passed: return DesignTokens.Semantic.success
        case .partial: return DesignTokens.Semantic.warning
        case .failed: return DesignTokens.Semantic.error
        }
    }
    
    private func runTests() {
        Task {
            await contractTestingService.runAllTests()
        }
    }
}

#Preview {
    ContractTestView()
}
