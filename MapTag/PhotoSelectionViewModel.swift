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
    
    @Published var retrievedImages: [MapTagImage] = [MapTagImage.testData]
    let goeCoder = CLGeocoder()
    
    var locationGroupedImages: [String: [MapTagImage]] {
        var tempDict: [String: [MapTagImage]] = [:]
        retrievedImages.forEach { taggedImage in
            guard let metaData = taggedImage.phAsset, let location = metaData.location else {
                // TODO: remove after debug
                tempDict["New Zealand"] = [taggedImage]
                return
            }
            goeCoder.reverseGeocodeLocation(location) { optionalPlacemarks, errror in
                guard let placemarks = optionalPlacemarks, let placemark = placemarks.first, let country = placemark.country else { return }
                
                // TODO: should keep placemark object?
                if tempDict.keys.contains(country) {
                    tempDict[country]?.append(taggedImage)
                } else {
                    tempDict[country] = [taggedImage]
                }
                // TODO: handle more than 1 location
                
            }
        }
        return tempDict
    }
    
    var placemarkCountryKeys: [String] {
        Array(locationGroupedImages.keys).sorted()
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
                                let imageWithMetaData = MapTagImage(image: success.image, phAsset: asset)
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

struct MapTagImage: Transferable{
    let image: Image
    let phAsset: PHAsset?
    
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
    
    static let testData: MapTagImage = MapTagImage(image: Image("FoxGlacier"), phAsset: nil)
}

enum TransferError: Error {
    case importFailed
}

