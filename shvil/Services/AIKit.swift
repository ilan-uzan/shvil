//
//  AIKit.swift
//  shvil
//
//  Created by ilan on 2024.
//

import CoreLocation
import Foundation

// MARK: - AIKit Service

/// AI service for OpenAI integration and prompt management
@MainActor
public class AIKit: ObservableObject {
    @Published public var isGenerating = false
    @Published public var error: Error?

    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Convenience initializer that uses secure key access
    public convenience init() throws {
        let key = try Configuration.getOpenAIKey()
        self.init(apiKey: key)
    }

    /// Generate an adventure plan using OpenAI
    public func generateAdventurePlan(input: AdventureGenerationInput) async throws -> AdventurePlan {
        isGenerating = true
        defer { isGenerating = false }

        do {
            let prompt = createAdventurePrompt(input: input)
            let response = try await callOpenAI(prompt: prompt)
            return try parseAdventureResponse(response)
        } catch {
            self.error = error
            throw error
        }
    }

    /// Generate alternatives for a stop
    public func generateStopAlternatives(stop: AdventureStop, input: AdventureGenerationInput) async throws -> [AdventureStop] {
        isGenerating = true
        defer { isGenerating = false }

        do {
            let prompt = createAlternativePrompt(stop: stop, input: input)
            let response = try await callOpenAI(prompt: prompt)
            return try parseAlternativesResponse(response)
        } catch {
            self.error = error
            throw error
        }
    }

    /// Generate stop rationale
    public func generateStopRationale(stop: AdventureStop, input: AdventureGenerationInput) async throws -> String {
        isGenerating = true
        defer { isGenerating = false }

        do {
            let prompt = createRationalePrompt(stop: stop, input: input)
            let response = try await callOpenAI(prompt: prompt)
            return try parseRationaleResponse(response)
        } catch {
            self.error = error
            throw error
        }
    }

    /// Generate adventure recap
    public func generateAdventureRecap(adventure: AdventurePlan) async throws -> String {
        isGenerating = true
        defer { isGenerating = false }

        do {
            let prompt = createRecapPrompt(adventure: adventure)
            let response = try await callOpenAI(prompt: prompt)
            return try parseRecapResponse(response)
        } catch {
            self.error = error
            throw error
        }
    }

    // MARK: - Private Methods

    private func createAdventurePrompt(input: AdventureGenerationInput) -> String {
        """
        Generate a personalized adventure plan with the following parameters:

        Time Frame: \(input.timeFrame.displayName)
        Mood: \(input.mood.displayName)
        Budget: \(input.budget.displayName)
        Companions: \(input.companions.map(\.displayName).joined(separator: ", "))
        Transportation: \(input.transportationMode.displayName)
        Interests: Not available
        Avoid Crowds: Not available
        Max Walking Distance: Not available

        Return a JSON response with this exact structure:
        {
          "title": "Adventure title",
          "tagline": "Short engaging description",
          "stops": [
            {
              "chapter": "Chapter name",
              "category": "landmark|food|scenic|museum|activity|nightlife|hidden_gem",
              "ideal_duration_min": 30,
              "narrative": "1-3 sentences describing this stop",
              "constraints": {
                "open_late": true,
                "budget": "low|medium|high",
                "accessibility": true,
                "outdoor": false
              }
            }
          ],
          "notes": "Short tips for this adventure"
        }
        """
    }

    private func createAlternativePrompt(stop: AdventureStop, input: AdventureGenerationInput) -> String {
        """
        Generate 2 alternative stops for this adventure chapter:

        Original: \(stop.name)
        Category: \(stop.category.displayName)
        Current Description: \(stop.description ?? "No description")
        Duration: \(stop.estimatedDuration) minutes

        Mood: \(input.mood.displayName)
        Budget: \(input.budget.displayName)

        Return a JSON response with this structure:
        {
          "alternatives": [
            {
              "chapter": "Alternative chapter name",
              "category": "landmark|food|scenic|museum|activity|nightlife|hidden_gem",
              "ideal_duration_min": 30,
              "narrative": "1-3 sentences describing this alternative",
              "constraints": {
                "open_late": true,
                "budget": "low|medium|high",
                "accessibility": true,
                "outdoor": false
              },
              "rationale": "Why this is a good alternative"
            }
          ]
        }
        """
    }

    private func createRationalePrompt(stop: AdventureStop, input: AdventureGenerationInput) -> String {
        """
        Explain why this stop fits the adventure:

        Stop: \(stop.name)
        Category: \(stop.category.displayName)
        Description: \(stop.description)
        Mood: \(input.mood.displayName)
        Budget: \(input.budget.displayName)

        Provide a brief, engaging rationale (1-2 sentences) explaining why this stop is perfect for this adventure.
        """
    }

    private func createRecapPrompt(adventure: AdventurePlan) -> String {
        """
        Create a memorable recap for this completed adventure:

        Title: \(adventure.title)
        Theme: \(adventure.theme.displayName)
        Duration: \(adventure.totalDuration / 60) hours
        Stops: \(adventure.stops.map(\.name).joined(separator: ", "))

        Write a 2-sentence recap that captures the essence and highlights of this adventure.
        """
    }

    private func callOpenAI(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that creates personalized adventure plans. Always respond with valid JSON in the exact format requested.",
                ],
                [
                    "role": "user",
                    "content": prompt,
                ],
            ],
            "max_tokens": 2000,
            "temperature": 0.7,
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw AIError.apiError
        }

        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String
        else {
            throw AIError.invalidResponse
        }

        return content
    }

    private func parseAdventureResponse(_ response: String) throws -> AdventurePlan {
        guard let data = response.data(using: .utf8) else {
            throw AIError.invalidResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let title = json?["title"] as? String,
              let tagline = json?["tagline"] as? String,
              let stopsData = json?["stops"] as? [[String: Any]],
              let notes = json?["notes"] as? String
        else {
            throw AIError.invalidResponse
        }

        let stops = try stopsData.map { stopData in
            try parseAdventureStop(from: stopData)
        }

        return AdventurePlan(
            id: UUID(),
            title: title,
            description: tagline,
            theme: .cultural,
            stops: stops,
            totalDuration: 120, // 2 hours in minutes
            totalDistance: 0,
            budgetLevel: .medium,
            status: .draft,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    private func parseAdventureStop(from data: [String: Any]) throws -> AdventureStop {
        guard let name = data["chapter"] as? String,
              let categoryString = data["category"] as? String,
              let category = StopCategory(rawValue: categoryString),
              let duration = data["ideal_duration_min"] as? Int,
              let description = data["narrative"] as? String,
              let constraintsData = data["constraints"] as? [String: Any]
        else {
            throw AIError.invalidResponse
        }

        let constraints = try parseStopConstraints(from: constraintsData)

        return AdventureStop(
            id: UUID(),
            name: name,
            description: description,
            location: LocationData(
                latitude: 0,
                longitude: 0,
                address: nil
            ),
            category: category,
            estimatedDuration: TimeInterval(duration)
        )
    }

    private func parseStopConstraints(from data: [String: Any]) throws -> StopConstraints {
        let openLate = data["open_late"] as? Bool ?? false
        let budgetString = data["budget"] as? String ?? "medium"
        let budget = BudgetLevel(rawValue: budgetString) ?? .medium
        let accessibility = data["accessibility"] as? Bool ?? true
        let outdoor = data["outdoor"] as? Bool ?? false

        return StopConstraints(
            openLate: openLate,
            budget: budget,
            accessibility: accessibility,
            outdoor: outdoor
        )
    }

    private func parseAlternativesResponse(_ response: String) throws -> [AdventureStop] {
        guard let data = response.data(using: .utf8) else {
            throw AIError.invalidResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let alternativesData = json?["alternatives"] as? [[String: Any]] else {
            throw AIError.invalidResponse
        }

        return try alternativesData.map { stopData in
            try parseAdventureStop(from: stopData)
        }
    }

    private func parseRationaleResponse(_ response: String) throws -> String {
        response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseRecapResponse(_ response: String) throws -> String {
        response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - AI Errors

public enum AIError: Error, LocalizedError {
    case invalidURL
    case apiError
    case invalidResponse
    case networkError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid API URL"
        case .apiError:
            "OpenAI API error"
        case .invalidResponse:
            "Invalid response format"
        case .networkError:
            "Network connection error"
        }
    }
}

// MARK: - Adventure Models (Re-exported for convenience)

// These are re-exported from AdventureKit for AIKit usage
// Note: These types are defined in AdventureKit.swift and are public

