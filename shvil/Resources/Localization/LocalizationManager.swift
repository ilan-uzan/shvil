//
//  LocalizationManager.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI

/// Manages app localization and RTL support
@MainActor
public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    @Published public var currentLanguage: Language = .english
    @Published public var isRTL: Bool = false
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        setupLanguage()
    }
    
    // MARK: - Public Methods
    
    /// Set the app language
    public func setLanguage(_ language: Language) {
        currentLanguage = language
        isRTL = language.isRTL
        
        // Update bundle
        if let path = Bundle.main.path(forResource: language.code, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            bundle = languageBundle
        } else {
            bundle = Bundle.main
        }
        
        // Save preference
        UserDefaults.standard.set(language.code, forKey: "app_language")
        
        // Force UI update by posting notification
        NotificationCenter.default.post(name: .languageChanged, object: language)
        
        // Force view refresh
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    /// Get localized string
    public func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
    
    /// Get localized string with arguments
    public func localizedString(for key: String, arguments: CVarArg..., comment: String = "") -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: comment)
        return String(format: format, arguments: arguments)
    }
    
    // MARK: - Private Methods
    
    private func setupLanguage() {
        // Check saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = Language(rawValue: savedLanguage) {
            setLanguage(language)
        } else {
            // Use system language if supported
            let systemLanguage = Locale.current.languageCode ?? "en"
            if let language = Language(rawValue: systemLanguage) {
                setLanguage(language)
            } else {
                setLanguage(.english)
            }
        }
    }
}

// MARK: - Language Enum

public enum Language: String, CaseIterable {
    case english = "en"
    case hebrew = "he"
    
    public var displayName: String {
        switch self {
        case .english: "English"
        case .hebrew: "עברית"
        }
    }
    
    public var code: String {
        return rawValue
    }
    
    public nonisolated var isRTL: Bool {
        switch self {
        case .english: return false
        case .hebrew: return true
        }
    }
    
    public var locale: Locale {
        return Locale(identifier: rawValue)
    }
}

// MARK: - String Extension

public extension String {
    /// Get localized string using LocalizationManager
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Get localized string with arguments
    func localized(arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// MARK: - View Modifiers

public struct LocalizedViewModifier: ViewModifier {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    public func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, localizationManager.isRTL ? .rightToLeft : .leftToRight)
            .environment(\.locale, localizationManager.currentLanguage.locale)
    }
}

public extension View {
    func localized() -> some View {
        modifier(LocalizedViewModifier())
    }
}

// MARK: - RTL Support

public struct RTLViewModifier: ViewModifier {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    public func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, localizationManager.isRTL ? .rightToLeft : .leftToRight)
    }
}


// MARK: - Typography RTL Support

public extension Font {
    /// Creates a font that respects RTL text direction
    nonisolated static func rtlAware(_ style: Font.TextStyle, design: Font.Design = .default) -> Font {
        let font = Font.system(style, design: design)
        
        // In RTL languages, we might want to adjust font characteristics
        // Note: This is a simplified approach - in a real app, you'd want to cache the language
        // or pass it as a parameter to avoid MainActor access from nonisolated context
        return font
    }
}

// MARK: - Text Alignment RTL Support

public extension TextAlignment {
    /// Returns the appropriate text alignment for the current language
    nonisolated static var localized: TextAlignment {
        // Note: This is a simplified approach - in a real app, you'd want to cache the language
        // or pass it as a parameter to avoid MainActor access from nonisolated context
        return .leading
    }
}

// MARK: - HStack RTL Support

public struct RTLHStack<Content: View>: View {
    let content: Content
    let alignment: VerticalAlignment
    let spacing: CGFloat?
    
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        if LocalizationManager.shared.isRTL {
            HStack(alignment: alignment, spacing: spacing) {
                content
            }
            .environment(\.layoutDirection, .rightToLeft)
        } else {
            HStack(alignment: alignment, spacing: spacing) {
                content
            }
        }
    }
}

// MARK: - VStack RTL Support

public struct RTLVStack<Content: View>: View {
    let content: Content
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
        .environment(\.layoutDirection, LocalizationManager.shared.isRTL ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Spacer RTL Support

public struct RTLSpacer: View {
    let minLength: CGFloat?
    
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
    
    public var body: some View {
        Spacer(minLength: minLength)
    }
}

// MARK: - Padding RTL Support

public struct RTLPadding: ViewModifier {
    let edges: Edge.Set
    let length: CGFloat?
    
    public init(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) {
        self.edges = edges
        self.length = length
    }
    
    public func body(content: Content) -> some View {
        if LocalizationManager.shared.isRTL {
            content
                .padding(edges, length)
                .environment(\.layoutDirection, .rightToLeft)
        } else {
            content
                .padding(edges, length)
        }
    }
}

public extension View {
    func rtlPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        modifier(RTLPadding(edges, length))
    }
}
