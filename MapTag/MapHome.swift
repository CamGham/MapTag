//
//  MapHome.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI
import MapKit

struct MapHome: View {
    @EnvironmentObject var mapVM: MapViewModel
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    
    @State var openProfileSheet = false
    @State var navigatedLocation: TaggedLocation? = nil
    
    private func showProfile() {
        openProfileSheet.toggle()
    }
    
    @State private var moveCamera: Bool = false
    @State var fullScreenNav = false
    
    
    var pointsOfInterest: [MKPointOfInterestCategory] = [.airport,.amusementPark,.aquarium,.bakery,.beach,.brewery, .cafe,.campground,.carRental,.foodMarket,.gasStation,.hotel,.marina,.museum,.nationalPark,.nightlife,.park,.parking,.publicTransport,.restaurant,.stadium,.store,.winery,.zoo]
    
    var body: some View {
        ZStack {
            Map(position: $mapVM.mapCameraPosition, interactionModes: [.pan, .zoom], selection: $mapVM.selection) {
                ForEach(mapVM.locations, id: \.self) { location in
                    Annotation(location.country, coordinate: location.location.coordinate) {
                        MapAnnotation(location: location)
                            .tag(location)
                    }
                }
            
                UserAnnotation()
            }
            .onMapCameraChange(frequency: .onEnd, { mapCameraContext in
                // if user taps an annotation
                // and camera ends at expected location (animation was not interupted by user)
                if let selection = mapVM.selection,
                   (Double(mapCameraContext.camera.centerCoordinate.latitude).rounded(toPlaces: 2) == Double(selection.location.coordinate.latitude).rounded(toPlaces: 2) &&
                    Double(mapCameraContext.camera.centerCoordinate.longitude).rounded(toPlaces: 2) == Double(selection.location.coordinate.longitude).rounded(toPlaces: 2)) {
                    // show popover
                        withAnimation {
                            navigatedLocation = mapVM.selection
                        }
                }
                // clear selection so tap is registered every annotation tap
                mapVM.selection = nil
            })
            .onReceive(mapVM.$selection, perform: { newSelection in
                if newSelection != nil {
                    moveCamera.toggle()
                }
            })

            .mapCameraKeyframeAnimator(trigger: moveCamera, keyframes: { mapCamera in
                KeyframeTrack(\MapCamera.centerCoordinate) {
                    CubicKeyframe(mapVM.selection!.location.coordinate, duration: 0.5)
                }
            })
            
            .mapStyle(.hybrid(elevation: .realistic,
                              pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest),
                              showsTraffic: false))
            .mapControls {
                MapUserLocationButton()
            }
            .mapControlVisibility(.visible)
            
            HStack {
                VStack {
                    Button(action: showProfile, label: {
                        Image(systemName: "person.crop.circle")
                    })
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(4)
                    
                    Button(action: {
                        print("do something")
                    }, label: {
                        Image(systemName: "camera.fill")
                        
                    })
                    .buttonStyle(BorderedButtonStyle())
                    .padding(4)
                    
                    Spacer()
                }
                Spacer()
            }
            // if show inside view
            LocationModalView(locationDict: photoSelectionVM.locationGroupedImages, navigatedLocation: $navigatedLocation)
        }
        .task(id: photoSelectionVM.placemarkCountryKeys, {
            await mapVM.getLocations(countries: photoSelectionVM.placemarkCountryKeys)
        })
        .fullScreenCover(isPresented: $openProfileSheet, content: {
            ProfileView()
        })
    }
}

#Preview {
//    let loc = TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971))
    
    MapHome(openProfileSheet: false)
        .environmentObject(MapViewModel())
        .environmentObject(PhotoSelectionViewModel())
}
