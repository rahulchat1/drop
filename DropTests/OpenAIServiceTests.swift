// DropTests/OpenAIServiceTests.swift
import XCTest
@testable import Drop

final class OpenAIServiceTests: XCTestCase {
    func test_extracts_place_from_caption() async throws {
        let service = OpenAIService(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")
        let caption = "You NEED to visit Sketch in Mayfair, London 🍽️ The Gallery is insane"
        let result = try await service.extractPlace(from: caption)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.lowercased().contains("sketch"))
    }

    func test_returns_nil_for_non_place_content() async throws {
        let service = OpenAIService(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")
        let caption = "Just woke up feeling great! Morning routine 💪"
        let result = try await service.extractPlace(from: caption)
        XCTAssertNil(result)
    }
}
