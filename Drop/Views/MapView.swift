// Drop/Views/MapView.swift
import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Query(sort: \Pin.savedAt, order: .reverse) private var pins: [Pin]
    @State private var selectedPin: Pin?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
            ForEach(pins) { pin in
                Annotation(pin.placeName, coordinate: CLLocationCoordinate2D(
                    latitude: pin.latitude,
                    longitude: pin.longitude
                )) {
                    PinAnnotationView(pin: pin)
                        .onTapGesture { selectedPin = pin }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
        .sheet(item: $selectedPin) { pin in
            PinDetailSheet(pin: pin)
                .presentationDetents([.medium])
        }
    }
}
