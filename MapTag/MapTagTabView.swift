//
//  MapTagTabView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI

struct MapTagTabView: View {
    @StateObject var mapTagCamera = MapViewModel()
    @StateObject var photoSelectionVM = PhotoSelectionViewModel()
    
    var body: some View {
//        TabView(selection: $mapTagCamera.selectedTab,
//                content:  {
//        NavigationStack {
//            ZStack {
                MapHome()
                //                .tabItem {
                //                    Label("Map", systemImage: "map.fill")
                //                }
                //                .tag(TabViews.mapTab)
                    .environmentObject(mapTagCamera)
                    .environmentObject(photoSelectionVM)
//                    .toolbar(search ? .visible : .hidden, for: .navigationBar)
//            }
//            .searchable(text: $searchQuery, isPresented: $search)
//                .toolbar(search ? .visible : .hidden, for: .navigationBar)
                
//        }
        
            
//            CountryListView()
//                .tabItem {
//                    Label("Search", systemImage: "magnifyingglass")
//                }
//                .tag(TabViews.listTab)
//                .environmentObject(mapTagCamera)
//                .environmentObject(photoSelectionVM)
//        })
    }
}

enum TabViews: String {
    case mapTab = "MapTab"
    case listTab = "ListTab"
}

#Preview {
    MapTagTabView()
}
