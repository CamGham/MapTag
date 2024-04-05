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
            } else {
                Color.white
            }

            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .ignoresSafeArea()
        .onTapGesture {
            showToolbars.toggle()
        }
        .toolbar(showToolbars ? .visible : .hidden)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .bottomBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showFullscreen.toggle()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
//                        .font(.callout)
                        .fontWeight(.semibold)
                })
            }
            ToolbarItem(placement: .principal) {
                Text("Title")
            }
            
            ToolbarItem(placement: .confirmationAction) {
                //rectangle.and.arrow.up.right.and.arrow.down.left
                Button("Force best orientation", systemImage: "rectangle.and.arrow.up.right.and.arrow.down.left") {
                    
                    // TODO: Force orientation based on image dimensions
                    // dismiss toolbar on full screen
                    print("Force orientation based on image dimensions")
                    showToolbars.toggle()
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
//                Text("Bottom bar")
                //photo.artframe
                //crown
                //heart
                //trophy
                //folder.badge.person.crop
                //person.crop.rectangle.badge.plus
                Button("Add to showcase", systemImage: "bookmark") {
                    
                }
                
                
                //lock for when deciding private or public
                
                
            }
            
        }
        
    }
}

#Preview {
    NavigationStack {
        
        FullscreenImage(showFullscreen: .constant(true), image: Image("FoxGlacier"))
    }
}
