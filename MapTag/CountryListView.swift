//
//  CountryListView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI

struct CountryListView: View {
    @StateObject var countriesVM = CountriesViewModel()
    @State var navPath = NavigationPath()
    
    
    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                ForEach(countriesVM.countriesList, id: \.self) { country in
                    HStack {
                        Text(country.name)
                        if country.isFavourite {
                            Image(systemName: "star.fill")
                        }
                    }
                    .swipeActions {
                        Button("Favourite",
                               systemImage: "star.fill",
                               action: {
                            countriesVM.countriesList[countriesVM.countriesList.firstIndex(where: { $0.name == country.name})!].isFavourite.toggle()
                        }).tint(.yellow)
                        
                        
                    }
                    
                }
            }
            .navigationTitle("Countries")
        }
    }
}

#Preview {
    CountryListView()
}
