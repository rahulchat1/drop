// Drop/Storage/PinStore.swift
import Foundation
import SwiftData

final class PinStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ pin: Pin) throws {
        context.insert(pin)
        try context.save()
    }

    func fetchAll() throws -> [Pin] {
        let descriptor = FetchDescriptor<Pin>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func delete(_ pin: Pin) throws {
        context.delete(pin)
        try context.save()
    }

    func update(pin: Pin, note: String) throws {
        pin.note = note
        try context.save()
    }
}
