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
//    var gridLayout: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var showFullscreen = false
    @State var selectedIndex: Int = 0
    @State var pos: CGPoint = CGPoint(x: 0, y: 0)
    
    
   @State var showAll = true
    
    @Namespace var imageView
    
    
    var body: some View {
        ZStack {
            if !showFullscreen {
                ScrollView {
                    if showAll {
                       
                        
                        LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 2) {
                            
                            ForEach(images.indices, id: \.self) { index in
//                                Button {
//                                    selectedIndex = index
//                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                                        showFullscreen.toggle()
//                                    }
//                                } label: {
                                    GeometryReader(content: { geometry in
                                        images[index].image
                                            .resizable()
//                                            .scaledToFit()
                                            .aspectRatio(contentMode: .fill)
                                        
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .clipped()
                                            .id(index)
                                            .matchedGeometryEffect(id: index, in: imageView, anchor: .center)
//                                            .matchedGeometryEffect(id: "image", in: imageView)
                                            .onTapGesture {
                                                selectedIndex = index
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                    showFullscreen.toggle()
                                                }
                                            }
                                            .contextMenu {
                                                Button {
                                                    print("first button")
                                                } label: {
                                                    Label("First Button", systemImage: "square.and.arrow.up")
                                                }

                                            } preview: {
                                                // TODO: look into resizeable
                                                images[index].image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 400, height: 400)
                                                    .id(index)
                                            }

                                    })
                                    .aspectRatio(1, contentMode: .fit)
                                    //                                .matchedGeometryEffect(id: "image", in: imageView, isSource: true)
//                                }
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
//                                        Button {
//                                            selectedIndex = index
//                                            //                                    withAnimation(.easeOut) {
//                                            //                                        showFullscreen.toggle()
//                                            //                                    }
//                                            
//                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                                                showFullscreen.toggle()
//                                            }
//                                            
//                                        } label: {
                                            GeometryReader(content: { geometry in
                                                images[index].image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                                    .clipped()
                                                    .onTapGesture {
                                                        selectedIndex = index
                                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                            showFullscreen.toggle()
                                                        }
                                                    }
                                            })
                                            .aspectRatio(1, contentMode: .fit)
                                            
                                            //                                    .animation(.bouncy, value: showFullscreen)
//                                        }
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
                        .opacity(showFullscreen ? 0 : 1)
                    }
                })
                .listRowInsets(.init())
            } else {
//                images[selectedIndex].image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .ignoresSafeArea()
//                    .matchedGeometryEffect(id: "image", in: imageView)
                FullscreenImage(showFullscreen: $showFullscreen, image: images[selectedIndex].image, index: selectedIndex, imageView: imageView)
                
                    
            }
            
//            if showFullscreen,
        }
    }
}

#Preview {
    NavigationStack {
        ImageContainerView(title: "Test", images: Array(repeating: MapTagImage(image: Image("FoxGlacier"), phAsset: nil, creationDate: Date()), count: 8), dateGroupedImages: PhotoSelectionViewModel().dateGroupedImages(images: Array(repeating: MapTagImage(image: Image("FoxGlacier"), phAsset: nil, creationDate: Date()), count: 8)))
    }
}
