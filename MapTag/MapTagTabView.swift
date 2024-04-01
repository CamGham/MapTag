//
//  MapTagTabView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI

struct MapTagTabView: View {

    @State var selectedTab = TabViews.mapTab
    
    var body: some View {
        TabView(selection: $selectedTab,
                content:  {
            MapHome()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(TabViews.mapTab)
            
            CountryListView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TabViews.listTab)
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
