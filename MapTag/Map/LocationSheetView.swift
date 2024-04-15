//
//  LocationSheetView.swift
//  MapTag
//
//  Created by Cam Graham on 14/04/2024.
//

import SwiftUI
import CoreLocation

struct LocationSheetView: View {
    @EnvironmentObject var photoVM: PhotoSelectionViewModel
    var locationDict: [String: [MapTagImage]]
    @Binding var location: TaggedLocation?
    @Binding var navPath: NavigationPath
   
    var body: some View {
        if let location = location {
            NavigationStack(path: $navPath) {
                Form {
                   
                    ProfileImageContainer(hashableNavigation: location, headerTitle: "Your Photos", images: locationDict[location.country] ?? [])
                }
                .navigationTitle(location.country)
                .navigationDestination(for: TaggedLocation.self) { location in
                    ImageContainerView(title: location.country, images: locationDict[location.country] ?? [], dateGroupedImages: photoVM.dateGroupedImages(images: locationDict[location.country] ?? []))
                }
            }
           
        }
    }
}


#Preview {
    LocationSheetView(locationDict: [:], location: .constant(TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971))), navPath: .constant(NavigationPath()))
        .environmentObject(PhotoSelectionViewModel())
}
