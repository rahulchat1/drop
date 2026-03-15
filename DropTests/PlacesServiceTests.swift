// DropTests/PlacesServiceTests.swift
import XCTest
@testable import Drop

final class PlacesServiceTests: XCTestCase {
    func test_geocode_returns_coordinates_for_known_place() async throws {
        let service = PlacesService(apiKey: ProcessInfo.processInfo.environment["GOOGLE_PLACES_API_KEY"] ?? "")
        let result = try await service.findPlace(query: "Sketch Restaurant London")
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.latitude, 51.51, accuracy: 0.05)
        XCTAssertEqual(result!.longitude, -0.14, accuracy: 0.05)
    }

    func test_geocode_returns_nil_for_nonsense() async throws {
        let service = PlacesService(apiKey: ProcessInfo.processInfo.environment["GOOGLE_PLACES_API_KEY"] ?? "")
        let result = try await service.findPlace(query: "xyzzy1234nonsense")
        XCTAssertNil(result)
    }
}
