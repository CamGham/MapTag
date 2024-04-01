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
    
    private func showProfile() {
        openProfileSheet.toggle()
    }
    
    var body: some View {
        ZStack {
            Map()
                .mapStyle(.hybrid(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                }
                .mapControlVisibility(.visible)
            VStack {
                HStack {
                    Button(action: showProfile, label: {
                        Image(systemName: "person.crop.circle")
                    })
                    .buttonStyle(BorderedProminentButtonStyle())
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
