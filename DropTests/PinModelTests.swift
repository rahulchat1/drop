// DropTests/PinModelTests.swift
import XCTest
import SwiftData
@testable import Drop

final class PinModelTests: XCTestCase {
    func test_pin_initialization() {
        let pin = Pin(
            placeName: "Sketch London",
            latitude: 51.5138,
            longitude: -0.1443,
            sourceURL: "https://tiktok.com/@user/video/123"
        )
        XCTAssertEqual(pin.placeName, "Sketch London")
        XCTAssertEqual(pin.latitude, 51.5138, accuracy: 0.0001)
        XCTAssertEqual(pin.longitude, -0.1443, accuracy: 0.0001)
        XCTAssertNil(pin.thumbnailURL)
        XCTAssertNil(pin.note)
        XCTAssertNotNil(pin.id)
        XCTAssertNotNil(pin.savedAt)
    }
}
