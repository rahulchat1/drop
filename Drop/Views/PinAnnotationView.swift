// Drop/Views/PinAnnotationView.swift
import SwiftUI

struct PinAnnotationView: View {
    let pin: Pin

    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 44, height: 44)
                .shadow(radius: 3)
            if let urlString = pin.thumbnailURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                        .font(.title2)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
            }
        }
    }
}
