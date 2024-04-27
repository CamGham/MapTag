//
//  asd.swift
//  MapTag
//
//  Created by Cam Graham on 21/04/2024.
//

import SwiftUI

struct MapTagRootView: View {
    @StateObject var mapVM = MapViewModel()
    @StateObject var photoSelectionVM = PhotoSelectionViewModel()
    var body: some View {
        MapHome()
            .environmentObject(mapVM)
            .environmentObject(photoSelectionVM)
    }
}

#Preview {
    MapTagRootView()
}
