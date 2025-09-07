//
//  ErrorHandlingService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI

/// Centralized error handling service for the app
@MainActor
public class ErrorHandlingService: ObservableObject {
    public static let shared = ErrorHandlingService()
    
    // MARK: - Published Properties
    
    @Published public var currentError: AppError?
    @Published public var errorQueue: [AppError] = []
    @Published public var isShowingError = false
    
    // MARK: - Private Properties
    
    private let analytics: Analytics
    private let featureFlags: FeatureFlags
    
    // MARK: - Initialization
    
    private init() {
        self.analytics = Analytics.shared
        self.featureFlags = FeatureFlags.shared
    }
    
    // MARK: - Public Methods
    
    /// Handle an error with automatic categorization and user-friendly messaging
    public func handleError(_ error: Error, context: ErrorContext = .general) {
        let appError = AppError(from: error, context: context)
        
        // Log error for analytics
        if featureFlags.isEnabled(.analytics) {
            analytics.logError(appError)
        }
        
        // Add to error queue
        errorQueue.append(appError)
        
        // Show error if not already showing one
        if !isShowingError {
            showError(appError)
        }
    }
    
    /// Handle a specific app error
    public func handleAppError(_ appError: AppError) {
        // Log error for analytics
        if featureFlags.isEnabled(.analytics) {
            analytics.logError(appError)
        }
        
        // Add to error queue
        errorQueue.append(appError)
        
        // Show error if not already showing one
        if !isShowingError {
            showError(appError)
        }
    }
    
    /// Dismiss current error
    public func dismissError() {
        currentError = nil
        isShowingError = false
        
        // Show next error in queue if available
        if !errorQueue.isEmpty {
            let nextError = errorQueue.removeFirst()
            showError(nextError)
        }
    }
    
    /// Clear all errors
    public func clearAllErrors() {
        currentError = nil
        errorQueue.removeAll()
        isShowingError = false
    }
    
    /// Show a success message
    public func showSuccess(_ message: String, duration: TimeInterval = 3.0) {
        let successError = AppError(
            id: UUID(),
            type: .success,
            title: "Success",
            message: message,
            context: .general,
            severity: .info,
            canRetry: false,
            retryAction: nil
        )
        
        showError(successError, duration: duration)
    }
    
    /// Show a warning message
    public func showWarning(_ message: String, duration: TimeInterval = 5.0) {
        let warningError = AppError(
            id: UUID(),
            type: .warning,
            title: "Warning",
            message: message,
            context: .general,
            severity: .warning,
            canRetry: false,
            retryAction: nil
        )
        
        showError(warningError, duration: duration)
    }
    
    // MARK: - Private Methods
    
    private func showError(_ appError: AppError, duration: TimeInterval? = nil) {
        currentError = appError
        isShowingError = true
        
        // Auto-dismiss after duration if specified
        if let duration = duration {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                await MainActor.run {
                    self.dismissError()
                }
            }
        }
    }
}

// MARK: - App Error Model

public struct AppError: Identifiable, Equatable {
    public let id: UUID
    public let type: ErrorType
    public let title: String
    public let message: String
    public let context: ErrorContext
    public let severity: ErrorSeverity
    public let canRetry: Bool
    public let retryAction: (() -> Void)?
    public let timestamp: Date
    public let underlyingError: Error?
    
    public init(
        id: UUID = UUID(),
        type: ErrorType,
        title: String,
        message: String,
        context: ErrorContext,
        severity: ErrorSeverity,
        canRetry: Bool = false,
        retryAction: (() -> Void)? = nil,
        underlyingError: Error? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.context = context
        self.severity = severity
        self.canRetry = canRetry
        self.retryAction = retryAction
        self.timestamp = Date()
        self.underlyingError = underlyingError
    }
    
    public init(from error: Error, context: ErrorContext) {
        self.id = UUID()
        self.context = context
        self.timestamp = Date()
        self.underlyingError = error
        
        // Categorize error based on type
        if let networkError = error as? NetworkError {
            self.type = .network
            self.title = "Network Error"
            self.message = networkError.userFriendlyMessage
            self.severity = .error
            self.canRetry = true
            self.retryAction = nil
        } else if let authError = error as? AuthenticationError {
            self.type = .authentication
            self.title = "Authentication Error"
            self.message = authError.userFriendlyMessage
            self.severity = .error
            self.canRetry = true
            self.retryAction = nil
        } else if let navigationError = error as? NavigationError {
            self.type = .navigation
            self.title = "Navigation Error"
            self.message = navigationError.userFriendlyMessage
            self.severity = .warning
            self.canRetry = true
            self.retryAction = nil
        } else if let routingError = error as? RoutingError {
            self.type = .routing
            self.title = "Routing Error"
            self.message = routingError.userFriendlyMessage
            self.severity = .warning
            self.canRetry = true
            self.retryAction = nil
        } else {
            self.type = .unknown
            self.title = "Error"
            self.message = error.localizedDescription
            self.severity = .error
            self.canRetry = false
            self.retryAction = nil
        }
    }
    
    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Error Types

public enum ErrorType: String, CaseIterable {
    case network = "network"
    case authentication = "authentication"
    case navigation = "navigation"
    case routing = "routing"
    case location = "location"
    case database = "database"
    case validation = "validation"
    case permission = "permission"
    case feature = "feature"
    case success = "success"
    case warning = "warning"
    case unknown = "unknown"
}

public enum ErrorContext: String, CaseIterable {
    case general = "general"
    case authentication = "authentication"
    case navigation = "navigation"
    case adventure = "adventure"
    case social = "social"
    case settings = "settings"
    case offline = "offline"
    case network = "network"
}

public enum ErrorSeverity: String, CaseIterable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    public var color: Color {
        switch self {
        case .info: return DesignTokens.Semantic.info
        case .warning: return DesignTokens.Semantic.warning
        case .error: return DesignTokens.Semantic.error
        case .critical: return DesignTokens.Semantic.error
        }
    }
    
    public var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - Network Error

public enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case invalidResponse
    case decodingError
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error: \(code)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .unknown(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
    
    public var userFriendlyMessage: String {
        switch self {
        case .noConnection:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .serverError:
            return "There was a problem with the server. Please try again later."
        case .invalidResponse:
            return "The server returned an unexpected response. Please try again."
        case .decodingError:
            return "There was a problem processing the response. Please try again."
        case .unknown:
            return "A network error occurred. Please try again."
        }
    }
}

// MARK: - Error View Modifier

struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorService: ErrorHandlingService
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorService.currentError?.title ?? "Error",
                isPresented: $errorService.isShowingError
            ) {
                if let error = errorService.currentError {
                    if error.canRetry, let retryAction = error.retryAction {
                        Button("Retry") {
                            retryAction()
                            errorService.dismissError()
                        }
                    }
                    
                    Button("OK") {
                        errorService.dismissError()
                    }
                }
            } message: {
                if let error = errorService.currentError {
                    Text(error.message)
                }
            }
    }
}

extension View {
    /// Add error handling to any view
    public func errorHandling() -> some View {
        modifier(ErrorAlertModifier(errorService: ErrorHandlingService.shared))
    }
}

// MARK: - Error Toast View

struct ErrorToastView: View {
    let error: AppError
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: error.severity.icon)
                .foregroundColor(error.severity.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(error.title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary)
                
                Text(error.message)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Text.secondary)
            }
            
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
                        .stroke(error.severity.color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: DesignTokens.Shadow.medium.color,
            radius: DesignTokens.Shadow.medium.radius,
            x: DesignTokens.Shadow.medium.x,
            y: DesignTokens.Shadow.medium.y
        )
    }
}
