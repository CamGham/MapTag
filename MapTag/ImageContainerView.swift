//
//  ImageContainerView.swift
//  MapTag
//
//  Created by Cam Graham on 05/04/2024.
//

import SwiftUI

struct ImageContainerView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    let imageSize: CGFloat = 100
    
    var title: String
    var images: [MapTagImage]
    var dateGroupedImages: [String: [MapTagImage]]
    

    var gridLayout: [GridItem] {
        if verticalSizeClass == .regular {
            [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 2)]
        } else {
            [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)]
        }
    }
    
    @State var showFullscreen = false
    @State var selectedIndex: Int = 0
    @State var pos: CGPoint = CGPoint(x: 0, y: 0)
    
    
   @State var showAll = true
    
    var body: some View {
        ZStack {
            ScrollView {
                if showAll {
                    LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 2) {
                        
                        ForEach(images.indices, id: \.self) { index in
                            Button {
                                selectedIndex = index
                                withAnimation {
                                    showFullscreen.toggle()
                                }
                            } label: {
                                GeometryReader(content: { geometry in
                                    images[index].image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .clipped()
                                })
                                .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                } else {  // if grouped
                    LazyVStack {
                        
                        ForEach(Array(dateGroupedImages.keys), id: \.self) { dateString in
                            
                            HStack {
                                Text(dateString)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 2) {
                            ForEach(dateGroupedImages[dateString]!.indices, id: \.self) { index in
                                Button {
                                    selectedIndex = index
                                    withAnimation {
                                        showFullscreen.toggle()
                                    }
                                } label: {
                                    GeometryReader(content: { geometry in
                                        images[index].image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .clipped()
                                    })
                                    .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                        
                        
                   
                       
                        
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                //TODO: replace with menu
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        //group and filter
                        withAnimation {
                            showAll.toggle()
                        }
                        
                    }, label: {
                        Image(systemName: "slider.horizontal.3")
                    })
                }
            })
            .listRowInsets(.init())
            if showFullscreen, let originalIndex = photoSelectionVM.getImageOriginIndex(mapTagImage: images[selectedIndex]) {
                FullscreenImage(showFullscreen: $showFullscreen, image: images[selectedIndex].image, isShowcased: $photoSelectionVM.retrievedImages[originalIndex].showcased)
                    
            }
        }
    }
}

#Preview {
    NavigationStack {
        ImageContainerView(title: "Test", images: Array(repeating: MapTagImage(image: Image("FoxGlacier"), phAsset: nil, creationDate: Date()), count: 8), dateGroupedImages: PhotoSelectionViewModel().dateGroupedImages(images: Array(repeating: MapTagImage(image: Image("FoxGlacier"), phAsset: nil, creationDate: Date()), count: 8)))
    }
}
