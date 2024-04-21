//
//  CountryGroupedImageContainer.swift
//  MapTag
//
//  Created by Cam Graham on 03/04/2024.
//

import SwiftUI

struct ProfileImageContainer: View {
    var hashableNavigation: any Hashable
    var headerTitle: String
    var images: [MapTagImage]
    
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
                Text(headerTitle)
            }
        } footer: {
            HStack {
                Spacer()
                
                NavigationLink(value: hashableNavigation) {
                    Text("View All")
                }
                .disabled(images.isEmpty)
            }
        
           
        }
    }
}

#Preview {
    ProfileImageContainer(hashableNavigation: CountryKey(countryName: "New Zealand"), headerTitle: CountryKey(countryName: "New Zealand").countryName, images: [])
}
