//
//  MapHome.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI
import MapKit

struct MapHome: View {
    @State var openProfileSheet = false
//    @State var selectedLocation: TaggedLocation? = nil
    @EnvironmentObject var mapTagCamera: MapTagCamera
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    @State var selectedLocation: TaggedLocation? = nil
    private func showProfile() {
        openProfileSheet.toggle()
    }
    
    private func moveCamera() {
        mapTagCamera.position = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: 40.730610, longitude: -73.935242), distance: 20_000_000.0))
    }
    
    var body: some View {
        ZStack {
            Map(position: $mapTagCamera.position, interactionModes: [.pan, .zoom]) {

                ForEach(mapTagCamera.locations, id: \.self) { location in
                    Annotation(location.country, coordinate: location.location.coordinate) {
                        MapAnnotation(location: location)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    mapTagCamera.position =
                                        .region(MKCoordinateRegion(center: location.location.coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
                                } completion: {
                                    
                                    // TODO: make delay based on distance from old location
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                                        withAnimation {
                                            selectedLocation = location
                                        }
                                        
                                    }
                                }
                            }
                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
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
                    
                    Button(action: moveCamera, label: {
                        Image(systemName: "camera.fill")
                        
                    })
                    .buttonStyle(BorderedButtonStyle())
                    .padding(4)
                    
                    Spacer()
                }
                Spacer()
            }
            
            if let navigatedLocation = selectedLocation {
                GeometryReader { geo in
                    VStack {
                        HStack {
                            Text(navigatedLocation.country)
                                .font(.title)
                                
                            Spacer()
                            Button("Dismiss") {
                                withAnimation {
                                    selectedLocation = nil
                                }
//                            completion: {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                                        mapTagCamera.selectedLocation = nil
//                                    }
//                                }
                            }
                        }
                        .padding()
                        
                        Spacer()
                        Text("asd")
                        Spacer()
                    }
                    .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.8)
                    .background(.bar)
                    .clipShape(.rect(cornerRadius: 20.0))
                    .position(CGPoint(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY))
                    .background(.black.opacity(0.4))
//                    .background(.windowBackground)
//                    .background(.ultraThinMaterial)
                    
                }
                .transition(.opacity)
                .zIndex(1)
            }
            
        }
        .task(id: photoSelectionVM.placemarkCountryKeys, {
            await mapTagCamera.getLocations(countries: photoSelectionVM.placemarkCountryKeys)
        })
        .fullScreenCover(isPresented: $openProfileSheet, content: {
            ProfileView()
        })
    }
}

#Preview {
//    let loc = TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971))
    
    MapHome(openProfileSheet: false)
        .environmentObject(MapTagCamera())
        .environmentObject(PhotoSelectionViewModel())
}
