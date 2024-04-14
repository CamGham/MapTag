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
    
    @State var showLocationDetails = false
    @State var startExploring = false
    
    @State var sheetNavigationPath = NavigationPath()
    @State var sheetSize: PresentationDetent = PresentationDetent.medium
    
    var userInteractions: MapInteractionModes {
        if navigatedLocation == nil {
            return [.pan, .zoom]
        } else {
            return []
        }
    }
    
    @State var animate = false
    var posOffset: CGFloat {
        animate ? 54 : 0
    }

    var body: some View {
        ZStack {
            
            // TODO:
            // map reader to find clicks on map -> find clicked country
            // use ploygon to highlight country
            Map(position: $mapVM.mapCameraPosition, interactionModes: userInteractions, selection: $mapVM.selection) {
                ForEach(mapVM.taggedLocations, id: \.self) { location in
                    Annotation(location.country, coordinate: location.location.coordinate) {
                        MapAnnotation(location: location, navigatedLocation: $navigatedLocation, showLocationDetails: $showLocationDetails, startExploring: $startExploring, navPath: $sheetNavigationPath, sheetSize: $sheetSize)
                            .selectionDisabled(navigatedLocation == location)
                            
                    }
                    .tag(location)
                    .annotationTitles(navigatedLocation != nil ? .hidden : .visible)
                }
                
                UserAnnotation()
            }
            .disabled(navigatedLocation != nil)
            .mapStyle(.hybrid(elevation: .realistic,
                              pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest),
                              showsTraffic: false))
            .mapControls {
                MapUserLocationButton()
            }
            .mapControlVisibility(.visible)
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
                } else {
                    withAnimation {
                        navigatedLocation = nil
                        
                    }
                }
                // clear selection so tap is registered every annotation tap
                mapVM.selection = nil
                
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
                    CubicKeyframe(mapVM.calculatedCameraHeight, duration: mapVM.animationDuration)
                }
            })
            
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
            
            if let navLoc = navigatedLocation {

//                Rectangle()
//                    .background(.ultraThinMaterial.opacity(animate ? 0.1 : 0))
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            navigatedLocation = nil
//                        }
//                    }
//                    .zIndex(1)
                Color.white.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            navigatedLocation = nil
                        }
                    }
                    .zIndex(1)
                
                    
                
                
                Group {
                    Text(navLoc.country)
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .offset(y: -140)
                        .fixedSize()

                    Button {
                        startExploring.toggle()
                    } label: {
                        PopupIcon(title: "Explore", iconName: "figure.walk.circle.fill", iconColor: .orange, startingDegree: 300.0)
                    }
                    .offset(x: -posOffset, y: -posOffset)

                    
                    Button(action: {
                        sheetNavigationPath.append(navLoc)
                        sheetSize = .large
                        showLocationDetails.toggle()
                    }, label: {
                        PopupIcon(title: "Photos", iconName: "photo.circle.fill", iconColor: .purple, startingDegree: 310.0)
                        
                    })
                    .offset(x: posOffset, y: -posOffset)
                    
                    
                    Button(action: {
                        sheetNavigationPath.removeLast(sheetNavigationPath.count)
                        sheetSize = .medium
                        showLocationDetails.toggle()
                    }, label: {
                        PopupIcon(title: "Info", iconName: "info.circle.fill", iconColor: .mint, startingDegree: 322.0)
                    })
                    .offset(x: posOffset, y: posOffset)
                }
                .scaleEffect(animate ? 1 : 0)
                .opacity(animate ? 1 : 0)
                .onAppear(perform: {
                    withAnimation(.easeInOut(duration: 0.8)){
                        animate.toggle()
                    }
                })
                .onDisappear(perform: {
                    withAnimation(.easeInOut(duration: 0.8)){
                        animate.toggle()
                    }
                })
                .zIndex(1.1)
                
            }
            
            
            if startExploring {
                CountryMap(startExploring: $startExploring , location: navigatedLocation, mapRegion:  mapVM.mapRegion, calculatedCameraHeight: mapVM.calculatedCameraHeight)
            }
            
            // if show inside view
//            LocationModalView(locationDict: photoSelectionVM.locationGroupedImages, navigatedLocation: $navigatedLocation)
//            if navigatedLocation != nil {
//                Rectangle()
//                    .ignoresSafeArea()
//                    .scaledToFill()
//                    .foregroundStyle(.ultraThinMaterial)
//                    .zIndex(1.1)
//                    
//            }
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
        .sheet(isPresented: $showLocationDetails, content: {
            LocationSheetView(locationDict: photoSelectionVM.locationGroupedImages, location: $navigatedLocation, navPath: $sheetNavigationPath)
                .presentationDetents([.medium, .large], selection: $sheetSize)
        })
    }
}

#Preview {
//    let loc = TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971))
    
    MapHome()
        .environmentObject(MapViewModel())
        .environmentObject(PhotoSelectionViewModel())
}
