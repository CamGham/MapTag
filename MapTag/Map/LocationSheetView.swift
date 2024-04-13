//
//  LocationSheetView.swift
//  MapTag
//
//  Created by Cam Graham on 14/04/2024.
//

import SwiftUI

struct LocationSheetView: View {
    var locationDict: [String: [MapTagImage]]
    @Binding var location: TaggedLocation?
    @Binding var navPath: NavigationPath
    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                Text("details here")
            }
            .navigationTitle(location?.country ?? "Location")
            .navigationDestination(for: TaggedLocation.self) { location in
                ImageContainerView(images: locationDict[location.country] ?? [], title: location.country)
            }
        }
    }
}

//#Preview {
//    LocationSheetView()
//}
