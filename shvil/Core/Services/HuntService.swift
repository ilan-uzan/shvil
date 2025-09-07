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
                await MainActor.run {
                    self.error = error
                }
            }
        }
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
