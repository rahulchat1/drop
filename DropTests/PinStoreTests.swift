// DropTests/PinStoreTests.swift
import XCTest
import SwiftData
@testable import Drop

@MainActor
final class PinStoreTests: XCTestCase {
    var store: PinStore!
    var container: ModelContainer!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Pin.self, configurations: config)
        store = PinStore(context: container.mainContext)
    }

    func test_save_and_fetch_pin() throws {
        let pin = Pin(placeName: "Sketch", latitude: 51.5, longitude: -0.14, sourceURL: "https://tiktok.com/1")
        try store.save(pin)
        let pins = try store.fetchAll()
        XCTAssertEqual(pins.count, 1)
        XCTAssertEqual(pins.first?.placeName, "Sketch")
    }

    func test_delete_pin() throws {
        let pin = Pin(placeName: "Sketch", latitude: 51.5, longitude: -0.14, sourceURL: "https://tiktok.com/1")
        try store.save(pin)
        try store.delete(pin)
        let pins = try store.fetchAll()
        XCTAssertEqual(pins.count, 0)
    }
}
