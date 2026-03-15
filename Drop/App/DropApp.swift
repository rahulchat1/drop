// Drop/App/DropApp.swift
import SwiftUI
import SwiftData

@main
struct DropApp: App {
    let container: ModelContainer

    init() {
        let appGroupID = "group.com.yourname.drop"
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { fatalError("App Group not configured") }

        let config = ModelConfiguration(url: containerURL.appendingPathComponent("drop.sqlite"))
        container = try! ModelContainer(for: Pin.self, configurations: config)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
