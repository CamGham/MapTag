//
//  MapTagCamera.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import Foundation
import SwiftUI
import MapKit

@MainActor
class MapTagCamera: ObservableObject {
    @Published var selectedTab = TabViews.mapTab
    @Published var position: MapCameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), distance: 20_000_000.0))
    @Published var locations: [TaggedLocation] = []
    let goeCoder = CLGeocoder()
    
    func getLocations(countries: [String]) async {
        for country in countries {
            if let location = await getCountryLocation(country: country) {
                self.locations.append(TaggedLocation(country: country, location: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)))
            }
        }
    }
    
    func getCountryLocation(country: String) async -> CLLocation? {
        var loc: CLLocation? = nil
        do {
            let places = try await goeCoder.geocodeAddressString(country)
            if let place = places.first, let location = place.location {
                loc = location
            }
        } catch {
            print("Error finding country \(error.localizedDescription)")
        }
        return loc
    }
    
}

struct TaggedLocation: Hashable {
    static func == (lhs: TaggedLocation, rhs: TaggedLocation) -> Bool {
        lhs.country == rhs.country
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(country)
    }
    
    var country: String
    var location: CLLocationCoordinate2D
}
