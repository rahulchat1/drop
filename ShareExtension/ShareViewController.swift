// ShareExtension/ShareViewController.swift
import UIKit
import Social
import SwiftData
import CoreLocation

class ShareViewController: UIViewController {

    private let appGroupID = "group.com.yourname.drop"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        showConfirmationUI()
        Task { await handleShare() }
    }

    private func showConfirmationUI() {
        let label = UILabel()
        label.text = "Dropping pin..."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func handleShare() async {
        guard let url = await extractURL() else {
            complete(success: false, message: "Couldn't read link")
            return
        }

        do {
            let extractor = LocationExtractor(
                metadataFetcher: MetadataFetcher(),
                openAIService: OpenAIService(apiKey: apiKey("OPENAI_API_KEY")),
                placesService: PlacesService(apiKey: apiKey("GOOGLE_PLACES_API_KEY"))
            )
            if let location = try await extractor.extract(from: url) {
                savePin(location: location, sourceURL: url.absoluteString)
                complete(success: true, message: "📍 Dropped: \(location.placeName)")
            } else {
                openMainApp(with: url)
            }
        } catch {
            complete(success: false, message: "Error: \(error.localizedDescription)")
        }
    }

    private func savePin(location: ExtractedLocation, sourceURL: String) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }

        let config = ModelConfiguration(url: containerURL.appendingPathComponent("drop.sqlite"))
        guard let container = try? ModelContainer(for: Pin.self, configurations: config) else { return }
        let store = PinStore(context: ModelContext(container))
        let pin = Pin(
            placeName: location.placeName,
            latitude: location.latitude,
            longitude: location.longitude,
            sourceURL: sourceURL,
            thumbnailURL: location.thumbnailURL
        )
        try? store.save(pin)
    }

    private func extractURL() async -> URL? {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier("public.url") })
        else { return nil }
        let result = try? await provider.loadItem(forTypeIdentifier: "public.url")
        return result as? URL
    }

    private func apiKey(_ name: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: name) as? String ?? ""
    }

    private func openMainApp(with url: URL) {
        let deepLink = URL(string: "drop://manual?url=\(url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        _ = self.extensionContext?.open(deepLink, completionHandler: nil)
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private func complete(success: Bool, message: String) {
        DispatchQueue.main.async {
            (self.view.subviews.first as? UILabel)?.text = message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }
}
