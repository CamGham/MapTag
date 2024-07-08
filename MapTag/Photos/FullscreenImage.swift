//
//  FullscreenImage.swift
//  MapTag
//
//  Created by Cam Graham on 05/04/2024.
//

import SwiftUI

struct FullscreenImage: View {
    @Binding var showFullscreen: Bool
    @State var showToolbars = true
    
    var images: [MapTagImage]
    var index: Int
        @State var isShowcased: Bool = true
    
    var imageView: Namespace.ID
    
    @Binding var anchor: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            if !showToolbars {
                Color.primary
                    .ignoresSafeArea()
            } else {
                Color.white
            }
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(images.indices, id: \.self) { index in
                            images[index].image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .id(index)
                                .containerRelativeFrame(.horizontal, alignment: .center)
                                .matchedGeometryEffect(id: index, in: imageView)
                                
                        }
                    }
                    .scrollTargetLayout()
                }
                .defaultScrollAnchor(.init(x: anchor, y: 0))
                .scrollTargetBehavior(.paging)
            }
        }
//        .zIndex(1.0)
        .onTapGesture {
            showToolbars.toggle()
        }
//        .toolbar(showToolbars ? .visible : .hidden, for: .navigationBar)
        .toolbarBackground(showToolbars ? .visible : .hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        withAnimation(.smooth) {
                            showFullscreen.toggle()
                        }
//                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                            showFullscreen.toggle()
//                        }
                        
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .fontWeight(.semibold)
                    })
                    .opacity(showToolbars ? 1 : 0)
                    .disabled(!showToolbars)
                }
            
                ToolbarItem(placement: .principal) {
                    Text("Title")
                        .opacity(showToolbars ? 1 : 0)
                }
            
            ToolbarItem(placement: .confirmationAction) {
                
                Button(action: {
                    isShowcased.toggle()
                }, label: {
                   Image(systemName: isShowcased ? "star.fill" : "star")
                        .opacity(showToolbars ? 1 : 0)
                })
                .disabled(!showToolbars)
                
                
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        
//        FullscreenImage(showFullscreen: .constant(true), image: Image("FoxGlacier"), index: 0, isShowcased: .constant(false))
//    }
//}
