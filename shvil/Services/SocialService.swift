//
//  SocialService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

@MainActor
public class SocialService: ObservableObject {
    @Published public var groups: [SocialGroup] = []
    @Published public var friends: [User] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private let supabaseService: SupabaseService
    private var cancellables = Set<AnyCancellable>()
    
    public init(supabaseService: SupabaseService? = nil) {
        self.supabaseService = supabaseService ?? DependencyContainer.shared.supabaseService
        loadGroups()
    }
    
    // MARK: - Group Management
    
    public func createGroup(_ group: SocialGroup) async throws {
        isLoading = true
        error = nil
        
        do {
            let createdGroup = try await supabaseService.createGroup(group)
            groups.append(createdGroup)
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func joinGroup(inviteCode: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let group = try await supabaseService.joinGroup(inviteCode: inviteCode)
            if !groups.contains(where: { $0.id == group.id }) {
                groups.append(group)
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func leaveGroup(_ group: SocialGroup) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.leaveGroup(groupId: group.id)
            groups.removeAll { $0.id == group.id }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func updateGroup(_ group: SocialGroup) async throws {
        isLoading = true
        error = nil
        
        do {
            let updatedGroup = try await supabaseService.updateGroup(group)
            if let index = groups.firstIndex(where: { $0.id == group.id }) {
                groups[index] = updatedGroup
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Friend Management
    
    public func addFriend(_ user: User) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.addFriend(userId: user.id)
            if !friends.contains(where: { $0.id == user.id }) {
                friends.append(user)
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func removeFriend(_ user: User) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.removeFriend(userId: user.id)
            friends.removeAll { $0.id == user.id }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func searchUsers(query: String) async throws -> [User] {
        isLoading = true
        error = nil
        
        do {
            let users = try await supabaseService.searchUsers(query: query)
            isLoading = false
            return users
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func loadGroups() {
        Task {
            do {
                let groups = try await supabaseService.getUserGroups()
                await MainActor.run {
                    self.groups = groups
                }
            } catch {
                // Fallback to mock data when Supabase is not configured
                await MainActor.run {
                    self.groups = generateMockGroups()
                    self.error = nil
                }
            }
        }
    }
    
    private func generateMockGroups() -> [SocialGroup] {
        let mockUserId = UUID() // Mock user ID for createdBy
        
        return [
            SocialGroup(
                id: UUID(),
                name: "Jerusalem Explorers",
                description: "Discover the hidden gems of Jerusalem together",
                createdBy: mockUserId,
                inviteCode: "JER123",
                qrCode: "qr_jer123_code",
                memberCount: 12,
                createdAt: Date(),
                updatedAt: Date()
            ),
            SocialGroup(
                id: UUID(),
                name: "Tel Aviv Adventures",
                description: "Urban adventures in the city that never sleeps",
                createdBy: mockUserId,
                inviteCode: "TLV456",
                qrCode: "qr_tlv456_code",
                memberCount: 8,
                createdAt: Date(),
                updatedAt: Date()
            ),
            SocialGroup(
                id: UUID(),
                name: "Nature Lovers",
                description: "Hiking and outdoor activities across Israel",
                createdBy: mockUserId,
                inviteCode: "NAT789",
                qrCode: "qr_nat789_code",
                memberCount: 15,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
}
