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
//    @State var showPopover = false
//    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        Image(systemName: "mappin")
            .resizable()
            .scaledToFit()
            .frame(height:44)
            .foregroundStyle(.background)
            .tag(location)
            
//            .confirmationDialog("asd", isPresented: $showPopover, actions: {
//                
//            })
//            .popover(isPresented: $showPopover, content: {
//                Text("Content view")
//            })
    }
}

//#Preview {
//    MapAnnotation()
//}
