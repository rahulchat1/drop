// Drop/Models/Pin.swift
import Foundation
import SwiftData

@Model
final class Pin {
    var id: UUID
    var placeName: String
    var latitude: Double
    var longitude: Double
    var thumbnailURL: String?
    var sourceURL: String
    var note: String?
    var savedAt: Date

    init(
        placeName: String,
        latitude: Double,
        longitude: Double,
        sourceURL: String,
        thumbnailURL: String? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.sourceURL = sourceURL
        self.thumbnailURL = thumbnailURL
        self.note = note
        self.savedAt = Date()
    }
}
