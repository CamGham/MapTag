//
//  CountryMapViewModel.swift
//  MapTag
//
//  Created by Cam Graham on 19/04/2024.
//

import Foundation
import MapKit

class CountryMapViewModel: ObservableObject {
    @Published var monthGroupedImages: [Int: [MapTagImage]] = [:]
    @Published var dragPos: Double = 0.0
    
    @Published var navToNextMonth: Bool = false
    
    var currentMonthInt: Int {
        Int(dragPos.rounded(.down))
    }
    
    var currentLocation: CLLocationCoordinate2D? {
        monthGroupedImages[currentMonthInt]?.first?.getImageCoords()
    }
}
