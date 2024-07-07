//
//  CountryMapViewModel.swift
//  MapTag
//
//  Created by Cam Graham on 19/04/2024.
//

import Foundation
import MapKit

class CountryMapViewModel: ObservableObject {
    
//    @Published var imageLocations: [AnimatableLocation]
    var zoom: CGFloat = 0.0
    func getCenterOfImages(images: [MapTagImage]?, currentHeight: CLLocationDistance?) -> AnimatableLocation? {
        
        //at least one image has a location
        if let unwrappedImages = images, let firstImage = unwrappedImages.first, let _ = firstImage.getImageCoords() {
            //TODO: if an image doesnt have a location, but user has manually added lcoation, on first time load show turoial on quickly adding location + might include needing to request permisssion to edit their library
            
            
            
            var minLat = Double.greatestFiniteMagnitude
            var minLong = Double.greatestFiniteMagnitude
            var maxLat = -Double.greatestFiniteMagnitude
            var maxLong = -Double.greatestFiniteMagnitude
            
            unwrappedImages.forEach { mapTagImage in
                guard let coord = mapTagImage.getImageCoords() else  {
                    //MARK: keep track of id for images without location?
                    
                    
                    // maybe throw an error to catch, then know no location for that month / group of images?
                    return
                }
                
                minLat = min(coord.latitude, minLat)
                minLong = min(coord.longitude, minLong)
                
                maxLat = max(coord.latitude, maxLat)
                maxLong = max(coord.longitude, maxLong)
            }
            
            var longSpan = abs(maxLong - minLong)
            if longSpan > 180 {
                longSpan = 360 - longSpan
            }
            let latSpan = abs(maxLat - minLat)
            
            let longMeters = longSpan * 111_000 * cos(minLat * .pi / 180)
            let latMeters = latSpan * 111_000
            
            // TODO: make above reusable
            
            
            
            let midLat = (minLat + maxLat) / 2
            let midLong = (minLong + maxLong) / 2
            
            let midCoord = MKMapPoint(CLLocationCoordinate2D(latitude: midLat, longitude: midLong))
            
            let rect = MKMapRect(origin: midCoord, size: MKMapSize(width: longMeters, height: latMeters))
            
            if rect.height != 0.0 {
                return AnimatableLocation(location: midCoord.coordinate, height: rect.height)
            } else if let unwrappedCurrentHeight = currentHeight{
                
//                let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                let defaultHeight = 2_250_000.0
                let height = max(unwrappedCurrentHeight, defaultHeight)
                
                return AnimatableLocation(location: midCoord.coordinate, height: height)
            } else {
                let defaultHeight = 2_250_000.0
                return AnimatableLocation(location: midCoord.coordinate, height: defaultHeight)
            }
            
            
            
            
            
        }
        return nil
//        images.reduce(into: CLLocationCoordinate2D()) { partialResult, mapTagImage in
//            let current
//        }
//        
//        images.first?.getImageCoords()
    }
}
