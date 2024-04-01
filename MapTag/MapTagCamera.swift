//
//  MapTagCamera.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import Foundation
import SwiftUI
import MapKit

class MapTagCamera: ObservableObject {
    @Published var selectedTab = TabViews.mapTab
    
    @Published var position: MapCameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), distance: 20_000_000.0))
}
