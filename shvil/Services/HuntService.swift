//
//  HuntService.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Combine

@MainActor
public class HuntService: ObservableObject {
    @Published public var hunts: [ScavengerHunt] = []
    @Published public var leaderboard: [LeaderboardParticipant] = []
    @Published public var currentHunt: ScavengerHunt?
    @Published public var checkpoints: [HuntCheckpoint] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private let supabaseService: SupabaseService
    private var cancellables = Set<AnyCancellable>()
    
    public init(supabaseService: SupabaseService? = nil) {
        self.supabaseService = supabaseService ?? DependencyContainer.shared.supabaseService
        loadHunts()
    }
    
    // MARK: - Hunt Management
    
    public func createHunt(_ hunt: ScavengerHunt) async throws {
        isLoading = true
        error = nil
        
        do {
            let createdHunt = try await supabaseService.createHunt(hunt)
            hunts.append(createdHunt)
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func joinHunt(huntCode: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let hunt = try await supabaseService.joinHunt(huntCode: huntCode)
            if !hunts.contains(where: { $0.id == hunt.id }) {
                hunts.append(hunt)
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func startHunt(_ hunt: ScavengerHunt) async throws {
        isLoading = true
        error = nil
        
        do {
            let updatedHunt = try await supabaseService.startHunt(huntId: hunt.id)
            if let index = hunts.firstIndex(where: { $0.id == hunt.id }) {
                hunts[index] = updatedHunt
            }
            currentHunt = updatedHunt
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func completeHunt(_ hunt: ScavengerHunt) async throws {
        isLoading = true
        error = nil
        
        do {
            let updatedHunt = try await supabaseService.completeHunt(huntId: hunt.id)
            if let index = hunts.firstIndex(where: { $0.id == hunt.id }) {
                hunts[index] = updatedHunt
            }
            if currentHunt?.id == hunt.id {
                currentHunt = updatedHunt
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func cancelHunt(_ hunt: ScavengerHunt) async throws {
        isLoading = true
        error = nil
        
        do {
            let updatedHunt = try await supabaseService.cancelHunt(huntId: hunt.id)
            if let index = hunts.firstIndex(where: { $0.id == hunt.id }) {
                hunts[index] = updatedHunt
            }
            if currentHunt?.id == hunt.id {
                currentHunt = nil
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Checkpoint Management
    
    public func loadCheckpoints(for hunt: ScavengerHunt) async throws {
        isLoading = true
        error = nil
        
        do {
            let checkpoints = try await supabaseService.getHuntCheckpoints(huntId: hunt.id)
            self.checkpoints = checkpoints
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    public func submitCheckpoint(_ submission: CheckpointSubmission) async throws {
        isLoading = true
        error = nil
        
        do {
            try await supabaseService.submitCheckpoint(submission)
            // Reload hunt progress
            if let hunt = currentHunt {
                try await loadHuntProgress(hunt)
            }
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Leaderboard
    
    public func loadLeaderboard(for hunt: ScavengerHunt) async throws {
        isLoading = true
        error = nil
        
        do {
            let leaderboard = try await supabaseService.getHuntLeaderboard(huntId: hunt.id)
            self.leaderboard = leaderboard
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func loadHunts() {
        Task {
            do {
                let hunts = try await supabaseService.getUserHunts()
                await MainActor.run {
                    self.hunts = hunts
                }
            } catch {
                // Fallback to mock data when Supabase is not configured
                await MainActor.run {
                    self.hunts = generateMockHunts()
                    self.error = nil
                }
            }
        }
    }
    
    private func generateMockHunts() -> [ScavengerHunt] {
        let mockUserId = UUID()
        return [
            ScavengerHunt(
                id: UUID(),
                title: "Old City Treasure Hunt",
                description: "Discover the secrets of Jerusalem's Old City",
                createdBy: mockUserId,
                status: .active,
                participantCount: 24,
                checkpointCount: 8,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ScavengerHunt(
                id: UUID(),
                title: "Tel Aviv Street Art",
                description: "Find the most beautiful street art in Tel Aviv",
                createdBy: mockUserId,
                status: .draft,
                participantCount: 18,
                checkpointCount: 12,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ScavengerHunt(
                id: UUID(),
                title: "Haifa Nature Trail",
                description: "Explore the natural beauty of Haifa's trails",
                createdBy: mockUserId,
                status: .completed,
                participantCount: 15,
                checkpointCount: 6,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    private func loadHuntProgress(_ hunt: ScavengerHunt) async throws {
        do {
            let updatedHunt = try await supabaseService.getHunt(huntId: hunt.id)
            if let index = hunts.firstIndex(where: { $0.id == hunt.id }) {
                hunts[index] = updatedHunt
            }
            if currentHunt?.id == hunt.id {
                currentHunt = updatedHunt
            }
        } catch {
            self.error = error
            throw error
        }
    }
}
