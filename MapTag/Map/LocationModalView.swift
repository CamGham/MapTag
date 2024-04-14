//
//  LocationModalView.swift
//  MapTag
//
//  Created by Cam Graham on 07/04/2024.
//

import SwiftUI

struct LocationModalView: View {
    @EnvironmentObject var photoVM: PhotoSelectionViewModel
    @State var fullScreen = false
    var locationDict: [String: [MapTagImage]]
    var title: String {
        navigatedLocation?.country ?? "Tagged Location"
    }
    @Binding var navigatedLocation: TaggedLocation?
    
    var body: some View {
        if let navLoc = navigatedLocation {
            GeometryReader { geo in
                VStack {
                    NavigationStack {
                        VStack {
                            Form(content: {
                                ProfileImageContainer(hashableNavigation: navLoc, headerTitle: "Your Photos", images: locationDict[navLoc.country] ?? [])
                            })
                        }
                        .navigationTitle(navLoc.country)
                        .toolbar(content: {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Dismiss") {
                                    withAnimation {
                                        navigatedLocation = nil
                                    }
                                }
                            }
                        })
                        .navigationDestination(for: TaggedLocation.self) { location in
                            
                            ImageContainerView(title: location.country, images: locationDict[location.country] ?? [], dateGroupedImages: photoVM.dateGroupedImages(images: locationDict[location.country] ?? []))
                                .onAppear(perform: {
                                    withAnimation(.default.delay(0.5)) {
                                        fullScreen.toggle()
                                    }
                                })
                                .onDisappear(perform: {
                                    withAnimation {
                                        fullScreen.toggle()
                                    }
                                })
                        }
                    }
                }
                .frame(width: fullScreen ? geo.size.width : geo.size.width * 0.8, height: fullScreen ? geo.size.height * 0.99 : geo.size.height * 0.8)
                .clipShape(.rect(cornerRadius: 20.0))
                .position(CGPoint(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY))
                .background(.black.opacity(0.4))
            }
            .transition(.opacity)
            .zIndex(1)
            
        }
    }
}
    

//#Preview {
//    LocationModalView()
//}
