//
//  CountryListView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI
import MapKit

struct CountryListView: View {
    @EnvironmentObject var mapTagCamera: MapTagCamera
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    @StateObject var countriesVM = CountriesViewModel()
    @State var navPath = NavigationPath()
    
    private func navToCountryPos(country: Country) {
        mapTagCamera.position = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: country.lattitude, longitude: country.longitude), distance: 20_000_000.0))
        mapTagCamera.selectedTab = .mapTab
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                ForEach(countriesVM.countriesList, id: \.self) { country in
                    
                    NavigationLink(value: country) {
                        CountryRowView(country: country)
                            .swipeActions {
                                Button("Favourite",
                                       systemImage: country.isFavourite ? "star.slash.fill" : "star.fill",
                                       action: {
                                    countriesVM.countriesList[countriesVM.countriesList.firstIndex(where: { $0.name == country.name})!].isFavourite.toggle()
                                }).tint(country.isFavourite ? .red : .yellow)
                                
                                Button("Show on Map", systemImage: "mappin.and.ellipse", action: {
                                    navToCountryPos(country: country)
                                })
                                .tint(.purple)
                            }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 16))
                    
                }
            }
            .navigationTitle("Countries")
            .navigationDestination(for: Country.self) { country in
                CountryDetailView(country: country)
            }
        }
    }
}

#Preview {
    CountryListView()
        .environmentObject(MapTagCamera())
}

struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: country.flagURL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 50)
            
            
            Text(country.name)
                .font(.title2)
            if country.isFavourite {
                Image(systemName: "star.fill")
            }
        }
        
        
    }
}
