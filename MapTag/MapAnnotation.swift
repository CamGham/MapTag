//
//  MapAnnotation.swift
//  MapTag
//
//  Created by Cam Graham on 04/04/2024.
//

import SwiftUI
import MapKit

struct MapAnnotation: View {
    var location: TaggedLocation
    @State var showPopover = false
    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        Image(systemName: "mappin")
            .resizable()
            .scaledToFit()
            .frame(height:44)
            .foregroundStyle(.background)
            .tag(location)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition =
                        .region(MKCoordinateRegion(center: location.location.coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
                    showPopover.toggle()
                }
            }
            .popover(isPresented: $showPopover, content: {
                Text("Content view")
            })
    }
}

//#Preview {
//    MapAnnotation()
//}
