// Drop/Services/LocationExtractor.swift
import Foundation
import CoreLocation

struct ExtractedLocation {
    let placeName: String
    let latitude: Double
    let longitude: Double
    let thumbnailURL: String?
}

protocol PlacesServiceProtocol {
    func findPlace(query: String) async throws -> PlaceCoordinate?
}
protocol OpenAIServiceProtocol {
    func extractPlace(from caption: String) async throws -> String?
}

extension PlacesService: PlacesServiceProtocol {}
extension OpenAIService: OpenAIServiceProtocol {}

final class LocationExtractor {
    private let metadataFetcher: MetadataFetcherProtocol
    private let openAIService: OpenAIServiceProtocol
    private let placesService: PlacesServiceProtocol

    init(
        metadataFetcher: MetadataFetcherProtocol,
        openAIService: OpenAIServiceProtocol,
        placesService: PlacesServiceProtocol
    ) {
        self.metadataFetcher = metadataFetcher
        self.openAIService = openAIService
        self.placesService = placesService
    }

    func extract(from url: URL) async throws -> ExtractedLocation? {
        let metadata = try await metadataFetcher.fetch(url: url)

        // Step 1: try location tag directly
        if let tag = metadata.locationTag, !tag.isEmpty {
            if let coord = try await placesService.findPlace(query: tag) {
                return ExtractedLocation(placeName: coord.name, latitude: coord.latitude, longitude: coord.longitude, thumbnailURL: metadata.thumbnailURL)
            }
        }

        // Step 2: use OpenAI on caption
        if !metadata.caption.isEmpty,
           let placeName = try await openAIService.extractPlace(from: metadata.caption),
           let coord = try await placesService.findPlace(query: placeName) {
            return ExtractedLocation(placeName: coord.name, latitude: coord.latitude, longitude: coord.longitude, thumbnailURL: metadata.thumbnailURL)
        }

        return nil
    }
}
