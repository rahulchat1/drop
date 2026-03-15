// DropTests/LocationExtractorTests.swift
import XCTest
@testable import Drop

final class LocationExtractorTests: XCTestCase {

    func test_extracts_from_caption_when_no_tag() async throws {
        let mockPlaces = MockPlacesService(result: PlaceCoordinate(latitude: 51.51, longitude: -0.14, name: "Sketch"))
        let mockOpenAI = MockOpenAIService(result: "Sketch, London")
        let mockFetcher = MockMetadataFetcher(locationTag: nil, caption: "Visit Sketch in Mayfair!")

        let extractor = LocationExtractor(
            metadataFetcher: mockFetcher,
            openAIService: mockOpenAI,
            placesService: mockPlaces
        )
        let result = try await extractor.extract(from: URL(string: "https://tiktok.com/video/1")!)
        XCTAssertEqual(result?.placeName, "Sketch")
        XCTAssertEqual(result?.latitude ?? 0, 51.51, accuracy: 0.01)
    }

    func test_uses_location_tag_when_available() async throws {
        let mockPlaces = MockPlacesService(result: PlaceCoordinate(latitude: 51.51, longitude: -0.14, name: "Sketch"))
        let mockOpenAI = MockOpenAIService(result: nil)
        let mockFetcher = MockMetadataFetcher(locationTag: "Sketch Restaurant London", caption: "")

        let extractor = LocationExtractor(
            metadataFetcher: mockFetcher,
            openAIService: mockOpenAI,
            placesService: mockPlaces
        )
        let result = try await extractor.extract(from: URL(string: "https://tiktok.com/video/1")!)
        XCTAssertNotNil(result)
        XCTAssertFalse(mockOpenAI.wasCalled)
    }

    func test_returns_nil_when_no_location_found() async throws {
        let mockPlaces = MockPlacesService(result: nil)
        let mockOpenAI = MockOpenAIService(result: nil)
        let mockFetcher = MockMetadataFetcher(locationTag: nil, caption: "Morning vibes ☀️")

        let extractor = LocationExtractor(
            metadataFetcher: mockFetcher,
            openAIService: mockOpenAI,
            placesService: mockPlaces
        )
        let result = try await extractor.extract(from: URL(string: "https://tiktok.com/video/1")!)
        XCTAssertNil(result)
    }
}

// MARK: - Mocks
class MockPlacesService: PlacesServiceProtocol {
    let result: PlaceCoordinate?
    init(result: PlaceCoordinate?) { self.result = result }
    func findPlace(query: String) async throws -> PlaceCoordinate? { result }
}

class MockOpenAIService: OpenAIServiceProtocol {
    let result: String?
    var wasCalled = false
    init(result: String?) { self.result = result }
    func extractPlace(from caption: String) async throws -> String? {
        wasCalled = true
        return result
    }
}

class MockMetadataFetcher: MetadataFetcherProtocol {
    let locationTag: String?
    let caption: String
    init(locationTag: String?, caption: String) {
        self.locationTag = locationTag
        self.caption = caption
    }
    func fetch(url: URL) async throws -> PageMetadata {
        PageMetadata(locationTag: locationTag, caption: caption, thumbnailURL: nil)
    }
}
