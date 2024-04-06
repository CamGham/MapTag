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
class MapViewModel: ObservableObject {
    @Published var selectedTab = TabViews.mapTab
    // cameraPostion
    @Published var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), distance: 20_000_000.0)))
    @Published var locations: [TaggedLocation] = []
    @Published var selection: TaggedLocation?
    
    let goeCoder = CLGeocoder()
    
    
    
    
    func getLocations(countries: [String]) async {
        for country in countries {
            if let location = await getCountryLocation(country: country) {
                self.locations.append(TaggedLocation(country: country, location: location))
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
    
//    var distance: Double {
//        mapChangeContext
//    }
    
//    func getAnimationTime(taggedLocationCoordinate: CLLocationCoordinate2D) -> CGFloat {
//        if let distance = getDistance(taggedLocationCoordinate: taggedLocationCoordinate) {
//            // TODO: calc the time
//            print("Distance is \(distance)")
//        }
//        return 1.0
//    }
    
//    func getDistance(taggedLocationCoordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
//        let mapPoint: MKMapPoint = MKMapPoint(taggedLocationCoordinate)
//        if let camera = mapCameraPosition.camera {
//            let cameraPoint = MKMapPoint(camera.centerCoordinate)
//            return cameraPoint.distance(to: mapPoint)
//        } else if let region = mapCameraPosition.region {
//            let regionPoint = MKMapPoint(region.center)
//            return regionPoint.distance(to: mapPoint)
//        } else if let rect = mapCameraPosition.rect { // user positioned point
//            let rectPoint = rect.origin
//            return rectPoint.distance(to: mapPoint)
//        }
//        return nil
//    }
    
    
    
//    @Published var selectedLocation: TaggedLocation? = nil {
//        didSet {
//            withAnimation {
//                showLocationPin.toggle()
//            }
//        }
//    }
//    
//    @Published var showLocationPin: Bool = false
    
}

struct TaggedLocation: Hashable {
    static func == (lhs: TaggedLocation, rhs: TaggedLocation) -> Bool {
        lhs.country == rhs.country
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(country)
    }
    
    var country: String
    var location: CLLocation
    
}
