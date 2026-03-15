// Drop/Services/PlacesService.swift
import Foundation
import CoreLocation

struct PlaceCoordinate {
    let latitude: Double
    let longitude: Double
    let name: String
}

final class PlacesService {
    private let apiKey: String
    private let baseURL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func findPlace(query: String) async throws -> PlaceCoordinate? {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "inputtype", value: "textquery"),
            URLQueryItem(name: "fields", value: "geometry,name"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(PlacesResponse.self, from: data)
        guard let candidate = response.candidates.first,
              let lat = candidate.geometry?.location.lat,
              let lng = candidate.geometry?.location.lng else {
            return nil
        }
        return PlaceCoordinate(latitude: lat, longitude: lng, name: candidate.name ?? query)
    }
}

private struct PlacesResponse: Decodable {
    let candidates: [Candidate]
    struct Candidate: Decodable {
        let name: String?
        let geometry: Geometry?
    }
    struct Geometry: Decodable {
        let location: Location
    }
    struct Location: Decodable {
        let lat: Double
        let lng: Double
    }
}
