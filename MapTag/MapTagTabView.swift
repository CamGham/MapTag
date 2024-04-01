//
//  MapTagTabView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI

struct MapTagTabView: View {
    @StateObject var mapTagCamera = MapTagCamera()
    
    var body: some View {
        TabView(selection: $mapTagCamera.selectedTab,
                content:  {
            MapHome()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(TabViews.mapTab)
                .environmentObject(mapTagCamera)
            
            CountryListView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TabViews.listTab)
                .environmentObject(mapTagCamera)
        })
    }
}

enum TabViews: String {
    case mapTab = "MapTab"
    case listTab = "ListTab"
}

#Preview {
    MapTagTabView()
}
