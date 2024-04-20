//
//  PhotoAnnotation.swift
//  MapTag
//
//  Created by Cam Graham on 15/04/2024.
//

import SwiftUI

struct PhotoAnnotation: View {
    var image: Image
    var body: some View {
        GeometryReader(content: { geo in
            ZStack {
                Triangle()
                    .rotation(.degrees(180))
                    .frame(width: geo.size.width * 0.60, height: geo.size.height * 0.60)
                    .offset(y: geo.size.height * 0.40)
                
                RoundedRectangle(cornerSize: CGSize(width: geo.size.width * 0.22, height: geo.size.height * 0.22), style: .continuous)
                    .frame(width: geo.size.width * 0.92, height: geo.size.height * 0.92)
                
                GeometryReader(content: { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(.rect(cornerRadius: 20))
                })
                .aspectRatio(1, contentMode: .fit)
                .frame(width: geo.size.width * 0.88, height: geo.size.height * 0.88)
                    
            }
        })
        
        


    }
}

#Preview {
    PhotoAnnotation(image: Image("FoxGlacier"))
        .frame(width: 100, height: 100)
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}
