//
//  ImageContainerView.swift
//  MapTag
//
//  Created by Cam Graham on 05/04/2024.
//

import SwiftUI

struct ImageContainerView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let imageSize: CGFloat = 100
    
    var images: [MapTagImage]
    var title: String

    var gridLayout: [GridItem] {
        if verticalSizeClass == .regular {
            [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 2)]
        } else {
            [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)]
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 2) {
                ForEach(images.indices, id: \.self) { index in
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .listRowInsets(.init())
    }
}

#Preview {
    ImageContainerView(images: Array(repeating: MapTagImage(image: Image("FoxGlacier"), phAsset: nil), count: 8), title: "Test")
}
