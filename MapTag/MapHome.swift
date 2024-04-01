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
    @State var position: MapCameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), distance: 20_000_000.0))
    
    private func showProfile() {
        openProfileSheet.toggle()
    }
    
    private func moveCamera() {
        position = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: 40.730610, longitude: -73.935242), distance: 20_000_000.0))
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, interactionModes: [.pan, .zoom])
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
