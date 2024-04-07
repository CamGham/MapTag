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
    
    // TODO: let user change the interest filters
    var pointsOfInterest: [MKPointOfInterestCategory] = [.airport,.amusementPark,.aquarium,.bakery,.beach,.brewery, .cafe,.campground,.carRental,.foodMarket,.gasStation,.hotel,.marina,.museum,.nationalPark,.nightlife,.park,.parking,.publicTransport,.restaurant,.stadium,.store,.winery,.zoo]
    
    var body: some View {
        ZStack {
            
            // TODO:
            // map reader to find clicks on map -> find clicked country
            // use ploygon to highlight country
            
            Map(position: $mapVM.mapCameraPosition, interactionModes: [.pan, .zoom], selection: $mapVM.selection) {
                
                
                ForEach(mapVM.taggedLocations, id: \.self) { location in
                    Annotation(location.country, coordinate: location.location.coordinate) {
                        MapAnnotation(location: location)
                            .tag(location)
                    }
                }
//                ForEach(mapVM.tappedCountry, id: \.self) { poly in
//                    MapPolygon(poly)
//                        .foregroundStyle(.white.opacity(animatePoly ? 1.0 : 0.3))
//                        .stroke(Color.accentColor, lineWidth: 1)
//                }
                
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
                            navigatedLocation = selection
                        }
//                    mapVM.selectTappedCountry(countryName: selection.country)
//                    withAnimation(.easeOut(duration: 0.5)) {
//                        animatePoly.toggle()
//                    }
                }
                // clear selection so tap is registered every annotation tap
                mapVM.selection = nil
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    withAnimation {
//                        animatePoly.toggle()
//                    }
//                    mapVM.tappedCountry = []
//                }
                
                mapVM.setCurrentPosition(mapCameraContext: mapCameraContext)
            })
            .onReceive(mapVM.$selection, perform: { newSelection in
                if let selection = newSelection {
                    // eventually remove
                    mapVM.setupCameraTransition(taggedLocation: selection)
                    moveCamera.toggle()
                }
            })

            .mapCameraKeyframeAnimator(trigger: moveCamera, keyframes: { mapCamera in
                KeyframeTrack(\MapCamera.centerCoordinate) {
                    CubicKeyframe(mapVM.selection!.location.coordinate, duration: mapVM.animationDuration)
                }
                KeyframeTrack(\MapCamera.distance) {
                    CubicKeyframe((mapVM.calculatedCameraHeight * 2) - (mapVM.calculatedCameraHeight * mapVM.animationDuration), duration: mapVM.animationDuration / 2)
                    CubicKeyframe(mapVM.calculatedCameraHeight, duration: mapVM.animationDuration)
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
        .task {
            mapVM.retrieveCountryPolygons()
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
