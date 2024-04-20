//
//  PhotoSelectionViewModel.swift
//  MapTag
//
//  Created by Cam Graham on 02/04/2024.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI
import ImageIO

class PhotoSelectionViewModel: ObservableObject {
    @Published var imageState: ImageState = .empty
    @Published var selectedImages: [PhotosPickerItem] = [] {
        didSet {
            if !selectedImages.isEmpty {
                let progress = loadImages(selectedImages: selectedImages)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    //MapTagImage.testData
    @Published var retrievedImages: [MapTagImage] = [MapTagImage.testData]
    let goeCoder = CLGeocoder()
    
    var showcaseImages: [MapTagImage] {
        retrievedImages.filter { mapTagImage in
            mapTagImage.showcased
        }
    }
    
    var locationGroupedImages: [String: [MapTagImage]] {
        var tempDict: [String: [MapTagImage]] = [:]
        retrievedImages.forEach { taggedImage in
            guard let metaData = taggedImage.phAsset, let location = metaData.location else {
                // TODO: remove after debug
                var copyImage = taggedImage
                copyImage.creationDate = Date()
                if tempDict.keys.contains("New Zealand") {
                    tempDict["New Zealand"]?.append(copyImage)
                } else {
                    tempDict["New Zealand"] = [copyImage]
                }
                return
            }
            goeCoder.reverseGeocodeLocation(location) { optionalPlacemarks, errror in
                guard let placemarks = optionalPlacemarks, let placemark = placemarks.first, let country = placemark.country else { return }
                var mapTagCopy = taggedImage
                
                mapTagCopy.placemark = placemark
                if let date = metaData.creationDate {
                    mapTagCopy.creationDate = date
                }
                
                if tempDict.keys.contains(country) {
                    tempDict[country]?.append(mapTagCopy)
                } else {
                    tempDict[country] = [mapTagCopy]
                }
                // TODO: handle more than 1 location
                
            }
        }
        return tempDict
    }
    
    var placemarkCountryKeys: [String] {
        locationGroupedImages.keys.sorted()
    }
    
    func getImageOriginIndex(mapTagImage: MapTagImage) -> Int? {
        retrievedImages.firstIndex { image in
            image.id == mapTagImage.id
        }
    }
    
    
    // TODO: conver to current timezone, but proved true image timezone as well?
    func dateGroupedImages(images: [MapTagImage]) -> [String: [MapTagImage]] {
        var tempDict: [String: [MapTagImage]] = [:]
        images.forEach { mapTagImage in
            if let date = mapTagImage.creationDate {
                let formattedDateString = date.formatted(date: .numeric, time: .omitted)
                if tempDict.keys.contains(formattedDateString) {
                    tempDict[formattedDateString]?.append(mapTagImage)
                } else {
                    tempDict[formattedDateString] = [mapTagImage]
                }
            }
        }
        return tempDict
    }
    
    func dateGroupedImages() -> [String: [MapTagImage]] {
        var tempDict: [String: [MapTagImage]] = [:]
        retrievedImages.forEach { mapTagImage in
            if let date = mapTagImage.creationDate {
                let formattedDateString = date.formatted(date: .numeric, time: .omitted)
                if tempDict.keys.contains(formattedDateString) {
                    tempDict[formattedDateString]?.append(mapTagImage)
                } else {
                    tempDict[formattedDateString] = [mapTagImage]
                }
            }
        }
        return tempDict
    }
    
    func monthGroupedImages(images: [MapTagImage]) -> [Int: [MapTagImage]] {
        var tempDict: [Int: [MapTagImage]] = [:]
        images.forEach { mapTagImage in
            if let date = mapTagImage.creationDate {
                let calender = Calendar.current
                if let month = calender.dateComponents([.month], from: date).month {
                    if tempDict.keys.contains(month) {
                        tempDict[month]?.append(mapTagImage)
                    } else {
                        tempDict[month] = [mapTagImage]
                    }
                }
            }
        }
        return tempDict
    }
    
    func monthGroupedImages() -> [Int: [MapTagImage]] {
        var tempDict: [Int: [MapTagImage]] = [:]
        retrievedImages.forEach { mapTagImage in
            if let date = mapTagImage.creationDate {
                let calender = Calendar.current
                if let month = calender.dateComponents([.month], from: date).month {
                    if tempDict.keys.contains(month) {
                        tempDict[month]?.append(mapTagImage)
                    } else {
                        tempDict[month] = [mapTagImage]
                    }
                }
            }
        }
        return tempDict
    }
    
    
    private func loadImages(selectedImages: [PhotosPickerItem]) -> Progress {
        let totalProgress: MutableProgress = MutableProgress()
        selectedImages.forEach { image in
            let progress = image.loadTransferable(type: MapTagImage.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success?):
                        if let identifier = image.itemIdentifier {
                            let meta = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
                            if let asset = meta.firstObject {
                                let imageWithMetaData = MapTagImage(id: asset.localIdentifier, image: success.image, phAsset: asset)
                                self.retrievedImages.append(imageWithMetaData)
                                
                            } else {
                                self.retrievedImages.append(success)
                            }
                        } else {
                            self.retrievedImages.append(success)
                        }

                        self.imageState = .success(self.retrievedImages)
                    case .success(.none):
                        self.imageState = .empty
                    case .failure(let failure):
                        self.imageState = .failure(failure)
                    }
                }
            }
            totalProgress.addChild(progress)
        }
        return totalProgress
    }
    
    //    private func loadImage(image: PhotosPickerItem) -> Progress {
    //        return image.loadTransferable(type: MapTagImage.self) { result in
    //            DispatchQueue.main.async {
    //                guard self.selectedImage == image else {
    //                    return
    //                }
    //
    //                switch result {
    //                case .success(let success?):
    //                    self.imageState = .success(success.image)
    //                case .success(.none):
    //                    print("no image")
    //                    self.imageState = .empty
    //                case .failure(let failure):
    //                    self.imageState = .failure(failure)
    //
    //                }
    //            }
    //        }
    //    }
}

enum ImageState {
    case success([MapTagImage])
    case loading(Progress)
    case empty
    case failure(Error)
}

struct MapTagImage: Transferable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    let image: Image
    let phAsset: PHAsset?
    var showcased = false
    
    var placemark: CLPlacemark?
    var creationDate: Date?
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            #if canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return MapTagImage(image: image, phAsset: nil)
            #else
                throw TransferError.importFailed
            #endif
        }
    }
    
    func getImageCoords() -> CLLocationCoordinate2D? {
        //TODO: REMOVE - DEBUG ONLY
        return CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971)
//        return self.placemark?.location?.coordinate
    }
    
    static let testData: MapTagImage = MapTagImage(image: Image("FoxGlacier"), phAsset: nil)
}



enum TransferError: Error {
    case importFailed
}

struct CountryKey: Hashable {
    var countryName: String
}


