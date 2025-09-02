//
//  User.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let displayName: String?
    let createdAt: Date
    let isGuest: Bool
    
    init(id: UUID = UUID(), email: String, displayName: String? = nil, createdAt: Date = Date(), isGuest: Bool = false) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.isGuest = isGuest
    }
    
    // Guest user factory
    static func guest() -> User {
        return User(email: "guest@shvil.app", displayName: "Guest", isGuest: true)
    }
}

// MARK: - User Extensions

extension User {
    var displayNameOrEmail: String {
        return displayName ?? email
    }
    
    var isAuthenticated: Bool {
        return !isGuest
    }
}
