// Drop/Views/PinDetailSheet.swift
import SwiftUI
import SwiftData

struct PinDetailSheet: View {
    @Bindable var pin: Pin
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let urlString = pin.thumbnailURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: { Color.gray.opacity(0.2) }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(pin.placeName)
                .font(.title2.bold())

            TextField("Add a note...", text: Binding(
                get: { pin.note ?? "" },
                set: { pin.note = $0; try? context.save() }
            ), axis: .vertical)
            .font(.body)
            .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 12) {
                Button(action: openInGoogleMaps) {
                    Label("Navigate", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .confirmationDialog("Delete this pin?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(pin)
                try? context.save()
                dismiss()
            }
        }
    }

    private func openInGoogleMaps() {
        let lat = pin.latitude, lng = pin.longitude
        if let googleURL = URL(string: "comgooglemaps://?daddr=\(lat),\(lng)&directionsmode=walking"),
           UIApplication.shared.canOpenURL(googleURL) {
            UIApplication.shared.open(googleURL)
        } else if let appleURL = URL(string: "maps://?daddr=\(lat),\(lng)") {
            UIApplication.shared.open(appleURL)
        }
    }
}
