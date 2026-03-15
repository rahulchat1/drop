// Drop/Services/OpenAIService.swift
import Foundation

final class OpenAIService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Returns "Place Name, City" or nil if no specific place detected
    func extractPlace(from caption: String) async throws -> String? {
        let prompt = """
        Extract the specific place/venue name and city from this social media caption.
        Return ONLY "Place Name, City" (e.g. "Sketch, London").
        If no specific venue is mentioned, return exactly: NULL

        Caption: \(caption)
        """

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 50,
            "temperature": 0
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        let text = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text == "NULL" ? nil : text
    }
}

private struct OpenAIResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let content: String
    }
}
