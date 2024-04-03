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
    @EnvironmentObject var mapTagCamera: MapTagCamera
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    
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
                    Marker(location.country, coordinate: location.location)
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
        }
        .task {
            await mapTagCamera.getLocations(countries: photoSelectionVM.placemarkCountryKeys)
        }
        .fullScreenCover(isPresented: $openProfileSheet, content: {
            ProfileView()
        })        
    }
}

#Preview {
//    @StateObject var mapTagCamera = MapTagCamera()
    MapHome(openProfileSheet: false)
        .environmentObject(MapTagCamera())
}
