//
//  CountryGroupedImageContainer.swift
//  MapTag
//
//  Created by Cam Graham on 03/04/2024.
//

import SwiftUI

struct CountryGroupedImageContainer: View {
    var country: String
    var images: [MapTagImage]
    @State var specificCountrySheet = false
    
    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 2) {
                    ForEach(images.indices, id: \.self) { index in
                        images[index].image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 100, height: 100)
                    }
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
        } header: {
            HStack {
                Text(country)
            }
        } footer: {
            HStack {
                Spacer()
                Button("View All") {
                    specificCountrySheet.toggle()
                }
                .disabled(images.isEmpty)
            }
        }
        .sheet(isPresented: $specificCountrySheet, content: {
            Text("images here")
        })
    }
}

#Preview {
    CountryGroupedImageContainer(country: "New Zealand", images: [])
}
