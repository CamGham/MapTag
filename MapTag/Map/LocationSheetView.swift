//
//  LocationSheetView.swift
//  MapTag
//
//  Created by Cam Graham on 14/04/2024.
//

import SwiftUI
import CoreLocation

struct LocationSheetView: View {
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
                    ImageContainerView(images: locationDict[location.country] ?? [], title: location.country)
                }
            }
           
        }
    }
}


#Preview {
    LocationSheetView(locationDict: [:], location: .constant(TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971))), navPath: .constant(NavigationPath()))
}
