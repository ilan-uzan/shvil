//
//  ErrorToast.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Error toast component for displaying errors and notifications
public struct ErrorToast: View {
    let error: AppError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    @State private var isVisible = false
    @State private var dragOffset = CGSize.zero
    
    public init(
        error: AppError,
        onDismiss: @escaping () -> Void,
        onRetry: (() -> Void)? = nil
    ) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Error icon
            Image(systemName: error.severity.icon)
                .foregroundColor(error.severity.color)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            // Error content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(error.title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                    .lineLimit(1)
                
                Text(error.message)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: DesignTokens.Spacing.sm) {
                if error.canRetry, let onRetry = onRetry {
                    Button("Retry") {
                        onRetry()
                        onDismiss()
                    }
                    .font(DesignTokens.Typography.footnoteEmphasized)
                    .foregroundColor(DesignTokens.Brand.primary)
                }
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(DesignTokens.Text.tertiary)
                        .font(.title3)
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(backgroundView)
        .offset(y: isVisible ? 0 : -100)
        .offset(x: dragOffset.width)
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .animation(DesignTokens.Animation.spring, value: isVisible)
        .animation(DesignTokens.Animation.micro, value: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    if abs(value.translation.x) > 100 {
                        onDismiss()
                    } else {
                        dragOffset = .zero
                    }
                }
        )
        .onAppear {
            withAnimation {
                isVisible = true
            }
            
            // Auto-dismiss after duration based on severity
            let duration = autoDismissDuration
            if duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
            .fill(DesignTokens.Surface.primary)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(
                color: DesignTokens.Shadow.medium.color,
                radius: DesignTokens.Shadow.medium.radius,
                x: DesignTokens.Shadow.medium.x,
                y: DesignTokens.Shadow.medium.y
            )
    }
    
    private var strokeColor: Color {
        switch error.severity {
        case .info: return DesignTokens.Semantic.info.opacity(0.3)
        case .warning: return DesignTokens.Semantic.warning.opacity(0.3)
        case .error: return DesignTokens.Semantic.error.opacity(0.3)
        case .critical: return DesignTokens.Semantic.error.opacity(0.5)
        }
    }
    
    private var autoDismissDuration: TimeInterval {
        switch error.severity {
        case .info: return 3.0
        case .warning: return 5.0
        case .error: return 8.0
        case .critical: return 0 // Don't auto-dismiss critical errors
        }
    }
}

// MARK: - Error Toast Container

public struct ErrorToastContainer: View {
    @ObservedObject var errorService: ErrorHandlingService
    
    public init(errorService: ErrorHandlingService = .shared) {
        self.errorService = errorService
    }
    
    public var body: some View {
        VStack {
            if let error = errorService.currentError {
                ErrorToast(
                    error: error,
                    onDismiss: {
                        errorService.dismissError()
                    },
                    onRetry: error.canRetry ? error.retryAction : nil
                )
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.lg)
            }
            
            Spacer()
        }
        .animation(DesignTokens.Animation.spring, value: errorService.currentError?.id)
    }
}

// MARK: - Success Toast

public struct SuccessToast: View {
    let message: String
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    public init(message: String, onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(DesignTokens.Semantic.success)
                .font(.title2)
            
            Text(message)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(DesignTokens.Text.tertiary)
                    .font(.title3)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(DesignTokens.Semantic.success.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: DesignTokens.Shadow.medium.color,
            radius: DesignTokens.Shadow.medium.radius,
            x: DesignTokens.Shadow.medium.x,
            y: DesignTokens.Shadow.medium.y
        )
        .offset(y: isVisible ? 0 : -100)
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .animation(DesignTokens.Animation.spring, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Loading Toast

public struct LoadingToast: View {
    let message: String
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var rotationAngle: Double = 0
    
    public init(message: String, onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Brand.primary))
            
            Text(message)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Text.primary)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(DesignTokens.Text.tertiary)
                    .font(.title3)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Surface.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                        .stroke(DesignTokens.Brand.primary.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: DesignTokens.Shadow.medium.color,
            radius: DesignTokens.Shadow.medium.radius,
            x: DesignTokens.Shadow.medium.x,
            y: DesignTokens.Shadow.medium.y
        )
        .offset(y: isVisible ? 0 : -100)
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .animation(DesignTokens.Animation.spring, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}
