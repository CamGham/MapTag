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

    @State private var moveCamera: Bool = false
//    @State var fullScreenNav = false
    
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
    
    @State var countryReady = false
    
    
    private func camIsAtLocation(mapCameraContext: MapCameraUpdateContext, selection: TaggedLocation) -> Bool {
        return (Double(mapCameraContext.camera.centerCoordinate.latitude).rounded(toPlaces: 2) == Double(selection.location.coordinate.latitude).rounded(toPlaces: 2) &&
                Double(mapCameraContext.camera.centerCoordinate.longitude).rounded(toPlaces: 2) == Double(selection.location.coordinate.longitude).rounded(toPlaces: 2))
    }
    
    @State var loadMapAnnotations = false
    @State var search = false

    
    @Namespace var mainMap
    var body: some View {
        Group {
            switch mapVM.mapState {
            case .globe:
                ZStack {
                    
                    // TODO:
                    // map reader to find clicks on map -> find clicked country
                    // use ploygon to highlight country
                    Map(position: $mapVM.mapCameraPosition, interactionModes: userInteractions, selection: $mapVM.selection) {
                        ForEach(mapVM.taggedLocations, id: \.self) { location in
                            
                            Annotation(location.country, coordinate: location.location.coordinate) {
                                MapAnnotation()
                            }
                            .tag(location)
                            .annotationTitles(navigatedLocation != nil ? .hidden : .visible)
                        }
                        
                        UserAnnotation()
                    }
                    .matchedGeometryEffect(id: "map", in: mainMap)
                    .disabled(navigatedLocation != nil || search)
                    .mapStyle(.hybrid(elevation: .realistic,
                                      pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest),
                                      showsTraffic: false))
                    //                .mapControls {
                    //                    MapUserLocationButton()
                    //                }
                    //                .mapControlVisibility(.visible)
                    .mapControlVisibility(.hidden)
                    .onMapCameraChange(frequency: .onEnd, { mapCameraContext in
                        // if user taps an annotation
                        // and camera ends at expected location (animation was not interupted by user)
                        if let selection = mapVM.selection,
                           camIsAtLocation(mapCameraContext: mapCameraContext, selection: selection) {
                            // show popover
                            withAnimation {
                                navigatedLocation = selection
                            }
                        } else {
                            withAnimation {
                                navigatedLocation = nil
                            }
                            // clear selection so tap is registered every annotation tap
                            mapVM.selection = nil
                        }
                        
                        // get current cam pos everytime the camera stops
                        mapVM.setCurrentPosition(mapCameraContext: mapCameraContext)
                    })
                    .onReceive(mapVM.$selection, perform: { newSelection in
                        if let selection = newSelection {
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
                    
                    GlobeButtons(openProfileSheet: $openProfileSheet, search: $search)
                    
                    if let navLoc = navigatedLocation {
                        Color.white.opacity(0.01)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    mapVM.selection = nil
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
                                withAnimation(.easeIn(duration: 1.0)){
                                    startExploring.toggle()
                                    countryReady.toggle()
                                } completion: {
                                    mapVM.mapState = .country
                                }
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
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                        
                    }
                    
//                    Color.black.opacity(countryReady ? 1 : 0)
//                        .ignoresSafeArea()
//                        .zIndex(1.2)
//                        .onAppear {
//                            if countryReady {
//                                withAnimation(.easeOut(duration: 1.5)) {
//                                    countryReady.toggle()
//                                }
//                            }
//                        }
                    
                    //            LocationModalView(locationDict: photoSelectionVM.locationGroupedImages, navigatedLocation: $navigatedLocation)
                }
                
                .fullScreenCover(isPresented: $openProfileSheet, content: {
                    ProfileView()
                })
                .sheet(isPresented: $showLocationDetails, content: {
                    LocationSheetView(locationDict: photoSelectionVM.locationGroupedImages, location: $navigatedLocation, navPath: $sheetNavigationPath)
                        .presentationDetents([.medium, .large], selection: $sheetSize)
                })
            case .country:
                if startExploring, let loc = navigatedLocation {
                    CountryMap(startExploring: $startExploring , location: loc, mapRegion:  mapVM.mapRegion, calculatedCameraHeight: mapVM.calculatedCameraHeight)
                        .onDisappear(perform: {
                            mapVM.selection = navigatedLocation
                            mapVM.mapState = .globe
                        })
                }
            }
        }
        .task {
            mapVM.retrieveCountryPolygons()
            await photoSelectionVM.retrieveUserPhotos()
        }
        // does it need to be other than count
        .onChange(of: photoSelectionVM.placemarkCountryKeys.count) {
            loadMapAnnotations.toggle()
        }
        .task(id: loadMapAnnotations, {
            guard !photoSelectionVM.placemarkCountryKeys.isEmpty else { return }
            print("getting annotations")
            await mapVM.getLocations(countries: photoSelectionVM.placemarkCountryKeys)
        })
    }
}

#Preview {
    MapHome()
        .environmentObject(MapViewModel())
        .environmentObject(PhotoSelectionViewModel())
}
