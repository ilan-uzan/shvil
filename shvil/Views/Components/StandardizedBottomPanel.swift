//
//  StandardizedBottomPanel.swift
//  shvil
//
//  Standardized bottom glass panel with OS-aware styling
//

import SwiftUI

/// Standardized bottom glass panel component
/// Provides consistent styling across all views with OS-aware Liquid Glass/glassmorphism
struct StandardizedBottomPanel<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let showDragHandle: Bool
    
    init(
        cornerRadius: CGFloat = DesignTokens.CornerRadius.xl,
        padding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        showDragHandle: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.showDragHandle = showDragHandle
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showDragHandle {
                dragHandle
            }
            
            content
                .padding(padding)
        }
        .background(panelBackground)
    }
    
    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(DesignTokens.Text.secondary)
            .frame(width: 36, height: 4)
            .padding(.top, 12)
    }
    
    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(OSVersionDetection.preferredMaterialStyle)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        Color.white.opacity(OSVersionDetection.glassSurfaceStyle.strokeOpacity),
                        lineWidth: 1
                    )
            )
            .appleShadow(DesignTokens.Shadow.medium)
    }
}

/// Convenience modifier for standardized bottom panels
extension View {
    func standardizedBottomPanel<Content: View>(
        cornerRadius: CGFloat = DesignTokens.CornerRadius.xl,
        padding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        showDragHandle: Bool = true,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            self
            
            StandardizedBottomPanel(
                cornerRadius: cornerRadius,
                padding: padding,
                showDragHandle: showDragHandle,
                content: content
            )
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        StandardizedBottomPanel {
            VStack(spacing: 16) {
                Text("Sample Content")
                    .font(DesignTokens.Typography.title2)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text("This is a standardized bottom panel with OS-aware styling")
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Action Button") {
                    // Action
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.Brand.primary)
            }
        }
    }
    .background(DesignTokens.Surface.background)
    .ignoresSafeArea()
}
