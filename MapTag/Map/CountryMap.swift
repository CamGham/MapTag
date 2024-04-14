//
//  CountryMap.swift
//  MapTag
//
//  Created by Cam Graham on 14/04/2024.
//

import SwiftUI
import MapKit

struct CountryMap: View {
    @Binding var startExploring: Bool
    var location: TaggedLocation?
    var mapRegion: MKCoordinateRegion
    var calculatedCameraHeight: Double
    
    @Namespace var innerLoc
    var pointsOfInterest: [MKPointOfInterestCategory] = [.airport,.amusementPark,.aquarium,.bakery,.beach,.brewery, .cafe,.campground,.carRental,.foodMarket,.gasStation,.hotel,.marina,.museum,.nationalPark,.nightlife,.park,.parking,.publicTransport,.restaurant,.stadium,.store,.winery,.zoo]
    
    @State var mapCam: MapCameraPosition = .region((MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))))

    var body: some View {
        ZStack {
            Map(position: $mapCam, bounds: MapCameraBounds(centerCoordinateBounds: mapRegion, maximumDistance: calculatedCameraHeight), interactionModes: [.pan, .zoom], scope: innerLoc) {

            }
//            .mapFeatureSelectionContent(content: { feature in
//                Annotation("asd", coordinate: feature.coordinate) {
//                    Text("asds")
//                }
//            })
            .mapStyle(.hybrid(elevation: .realistic,
                              pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest),
                              showsTraffic: false))
            
//            .standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest), showsTraffic: false)
            
            HStack {
                VStack {
                    Button(action: {
                        startExploring.toggle()
                    }, label: {
                        Text("EXIT")
                    })
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(4)
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

//#Preview {
//    CountryMap(location: TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971)))
//}
