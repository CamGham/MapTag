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
    @Published var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))))
    // locations from photo metadata
    @Published var taggedLocations: [TaggedLocation] = []
    // user tapped location
    @Published var selection: TaggedLocation?
    
    let goeCoder = CLGeocoder()
    // camera position updated onEnd of movement
    var currentMapPoint: MKMapPoint = MKMapPoint()
    // TODO: only get countries required and add as needed
    // calculated polygons of each country
    var countryPolygonDict: [String: [[[CLLocationCoordinate2D]]]] = [:]
    
    // camera transition info
    var animationDuration: Double = 0.0
    var calculatedCameraHeight: Double = 0.0

    func getLocations(countries: [String]) async {
        for country in countries {
            if let location = await getCountryLocation(country: country) {
                self.taggedLocations.append(TaggedLocation(country: country, location: location))
            }
        }
    }
    
    private func getCountryLocation(country: String) async -> CLLocation? {
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
    
    func setCurrentPosition(mapCameraContext: MapCameraUpdateContext) {
        currentMapPoint = MKMapPoint(mapCameraContext.region.center)
    }
    
    
    func retrieveCountryPolygons() {
        var dict = [String: [[[CLLocationCoordinate2D]]]]()
        let featureColl = decodeGeoJSON()
        
        if let fc = featureColl {
            fc.features.forEach { countryBoundry in
                let name = countryBoundry.countryName
                let coordinates = countryBoundry.coordinates
                dict[name] = coordinates
            }
        }
        countryPolygonDict = dict
    }
    

    private func decodeGeoJSON() -> FeatureCollection? {
        guard let geoFile = Bundle.main.url(forResource: "countries", withExtension: "geojson") else { return nil}
        do {
            let data = try Data(contentsOf: geoFile)
             return try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error dealing with geoJSON")
        }
      return nil
    }
    

    func setupCameraTransition(taggedLocation: TaggedLocation) {
        let mapPoint: MKMapPoint = MKMapPoint(taggedLocation.location.coordinate)
        let distance = currentMapPoint.distance(to: mapPoint)
        
        // animation time
        switch distance {
//        case let x where x < 100:
//            duration = 0.01
////        case let x where x < 1_000:
////            duration = 0.2
////        case let x where x < 10_000:
////            duration = 0.4
////        case let x where x < 100_000:
////            duration = 0.6
//        case let x where x < 1_000_000:
//            duration = 0.8
        default:
            animationDuration = 1.0
        }
        
        // altitude
        var minLat = Double.greatestFiniteMagnitude
        var minLong = Double.greatestFiniteMagnitude
        var maxLat = 0.0
        var maxLong = 0.0
        
        if let coordArr = countryPolygonDict[taggedLocation.country] {
            coordArr.forEach({ arr in
                if let coord = arr.first {
                    coord.forEach { clCoord in
                        minLat = min(clCoord.latitude, minLat)
                        minLong = min(clCoord.longitude, minLong)
                        
                        maxLat = max(clCoord.latitude, maxLat)
                        maxLong = min(clCoord.longitude, maxLong)
                    }
                }
            })
        }
        let longSpan = abs(maxLong - minLong)
        let latSpan = abs(maxLat - minLat)
        
        let longMeters = longSpan * 111_000 * cos(minLong * .pi / 180)
        let latMeters = latSpan * 111_000
        
        let rect = MKMapRect(origin: mapPoint, size: MKMapSize(width: longMeters, height: latMeters))
        calculatedCameraHeight = rect.height
        print("dist: \(distance)")
        print("ani: \(animationDuration)")
    }
    
    
    // MARK: map polygons
        
    //    @Published var tappedCountry: [MKPolygon] = []
//    var countrySpan: MKCoordinateSp
    
//    func selectTappedCountry(countryName: String) {
//        if let coordArr = countryPolygonDict[countryName] {
//            countryPolygonDict[countryName]?.forEach({ arr in
//                if let coord = arr.first {
//                    tappedCountry.append(MKPolygon(coordinates: coord, count: coord.count))
//                }
//            })
//        }
//
//    }
    
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
