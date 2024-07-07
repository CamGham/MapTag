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
    
    var image: Image
    var index: Int
    @Binding var isShowcased: Bool
    
    var imageView: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .center) {
            if !showToolbars {
                Color.black
                    .ignoresSafeArea()
            } else {
                Color.white
            }
                
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
                .matchedGeometryEffect(id: "image", in: imageView)
//                .animation(.bouncy, value: showFullscreen)
//                .matchedGeometryEffect(id: "image", in: imageView, isSource: false)
        }
        .zIndex(1.0)
//        .transition(.scale.combined(with: .slide))
        .onTapGesture {
            showToolbars.toggle()
        }
//        .toolbar(showToolbars ? .visible : .hidden, for: .navigationBar)
        .toolbarBackground(showToolbars ? .visible : .hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            showFullscreen.toggle()
                        }
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
