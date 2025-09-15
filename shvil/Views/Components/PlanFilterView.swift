//
//  PlanFilterView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct PlanFilterView: View {
    @Binding var selectedFilter: PlanStatus
    let onFilterChange: (PlanStatus) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(PlanStatus.allCases, id: \.self) { status in
                    filterButton(for: status)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }
    
    private func filterButton(for status: PlanStatus) -> some View {
        Button(action: {
            selectedFilter = status
            onFilterChange(status)
        }) {
            Text(status.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(selectedFilter == status ? .white : DesignTokens.Text.secondary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .fill(selectedFilter == status ? DesignTokens.Brand.primary : DesignTokens.Surface.secondary)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlanFilterView(
        selectedFilter: .constant(.all),
        onFilterChange: { _ in }
    )
}
