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
        }
        .zIndex(1.0)
        .transition(.scale.combined(with: .slide))
        .onTapGesture {
            showToolbars.toggle()
        }
//        .toolbar(showToolbars ? .visible : .hidden, for: .navigationBar)
        .toolbarBackground(showToolbars ? .visible : .hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        withAnimation(.easeIn) {
                            showFullscreen.toggle()
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .fontWeight(.semibold)
                    })
                    .foregroundStyle(showToolbars ? Color.accentColor : .black)
                    .disabled(!showToolbars)
                }
            
                ToolbarItem(placement: .principal) {
                    Text("Title")
                }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Add to Showcase", systemImage: "star") {
                    // TODO: add to showcase
                    print("add to showcase")
                }
                .foregroundStyle(showToolbars ? Color.accentColor : .black)
                .disabled(!showToolbars)
            }
        }
    }
}

#Preview {
    NavigationStack {
        
        FullscreenImage(showFullscreen: .constant(true), image: Image("FoxGlacier"))
    }
}
