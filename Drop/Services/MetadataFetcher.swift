// Drop/Services/MetadataFetcher.swift
import Foundation

struct PageMetadata {
    let locationTag: String?
    let caption: String
    let thumbnailURL: String?
}

protocol MetadataFetcherProtocol {
    func fetch(url: URL) async throws -> PageMetadata
}

final class MetadataFetcher: MetadataFetcherProtocol {
    func fetch(url: URL) async throws -> PageMetadata {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: request)
        let html = String(data: data, encoding: .utf8) ?? ""
        return PageMetadata(
            locationTag: extractOGTag(named: "og:locality", from: html)
                      ?? extractOGTag(named: "og:location", from: html),
            caption: extractOGTag(named: "og:description", from: html) ?? "",
            thumbnailURL: extractOGTag(named: "og:image", from: html)
        )
    }

    private func extractOGTag(named name: String, from html: String) -> String? {
        let pattern = #"<meta[^>]+property="\#(name)"[^>]+content="([^"]+)""#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }
        return String(html[range])
    }
}
