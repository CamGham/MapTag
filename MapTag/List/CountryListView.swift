//
//  CountryListView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI
import MapKit

struct CountryListView: View {
    @EnvironmentObject var mapTagCamera: MapViewModel
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    @StateObject var countriesVM = CountriesViewModel()
    
    var searchQuery: String
//    @State var navPath = NavigationPath()
    
    private func navToCountryPos(country: Country) {
        mapTagCamera.mapCameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: country.lattitude, longitude: country.longitude), distance: 20_000_000.0))
//        mapTagCamera.selectedTab = .mapTab
    }
    
    var filteredList: [Country] {
        if searchQuery != "" {
            countriesVM.countriesList.filter { country in
                country.name.lowercased().contains(searchQuery.lowercased())
            }
        } else {
            countriesVM.countriesList
        }
    }
    
    var body: some View {
//        NavigationStack(path: $navPath) {
            List {
                ForEach(filteredList, id: \.self) { country in
                    
//                    NavigationLink(value: country) {
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
                            
//                            .listRowSeparator(.hidden)
//                            .listRowBackground(Color.clear)
//                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color(.tertiarySystemGroupedBackground))
                    
                    
                }
            }
            .listStyle(.plain)
            .clipShape(.rect(cornerRadius: 8))
//            .listStyle(.plain)
//            .listRowBackground(Color.gray)
//            .listItemTint(.pink)
            
        
//            .navigationTitle("Countries")
//            .navigationDestination(for: Country.self) { country in
//                CountryDetailView(country: country)
//            }
//        }
    }
}

#Preview {
    CountryListView(searchQuery: "")
        .environmentObject(MapViewModel())
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
            Spacer()
            if country.isFavourite {
                Image(systemName: "star.fill")
            }
        }
        .background(Color(.tertiarySystemGroupedBackground))
        
        
    }
}
