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
    
    private func showProfile() {
        openProfileSheet.toggle()
    }
    
    private func moveCamera() {
        mapTagCamera.position = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: 40.730610, longitude: -73.935242), distance: 20_000_000.0))
    }
    
    var body: some View {
        ZStack {
            Map(position: $mapTagCamera.position, interactionModes: [.pan, .zoom])
                .mapStyle(.hybrid(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                }
                .mapControlVisibility(.visible)
                .onMapCameraChange {
                    print("cam changed")
                }
                
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
        .fullScreenCover(isPresented: $openProfileSheet, content: {
            ProfileView()
        })        
    }
}

#Preview {
    MapHome(openProfileSheet: false)
}
