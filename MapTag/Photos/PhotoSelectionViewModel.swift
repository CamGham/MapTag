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
    let geoCoder = CLGeocoder()
    
    let testImgIden = "8855B154-86CF-49A7-A5F8-1117A13A719F/L0/001"
    
    @Published var imageState: ImageState = .empty
    @Published var selectedImages: [PhotosPickerItem] = [] {
        didSet {
            if !selectedImages.isEmpty {
                print("loading images \(selectedImages.count)")
                let progress = loadImages(selectedImages: selectedImages)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    //MapTagImage.testData
    @Published var retrievedImages: [MapTagImage] = [] {
        didSet {
            
                Task {
                    print("geo locating images")
                    await geoLocateImages()
                }
            
        }
    }
    
    @Published var testImage: UIImage?
    
    func retrieveUserPhotos() async {
        let photoItem = PhotosPickerItem(itemIdentifier: testImgIden)
        selectedImages.append(photoItem)

//        self.imageState = .loading(T##Progress)
        let assetManager = PHImageManager.default()
        let assetReq = PHAsset.fetchAssets(withLocalIdentifiers: [testImgIden], options: nil)
//        
        if let asset = assetReq.firstObject {
            let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            //
            assetManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: .none) { uiImage, hashArr in
                
                guard let unwrappedUiImage = uiImage else { return }
                let image = Image(uiImage: unwrappedUiImage)
                
                let newImage = MapTagImage(id: self.testImgIden, image: image, phAsset: asset)
                
//                if !self.retrievedImages.isEmpty, let index = self.retrievedImages.firstIndex(where: { mapImg in
//                    mapImg.id == newImage.id
//                }) {
//                    self.retrievedImages.remove(at: index)
//                }
                let degradeKey = PHImageResultIsDegradedKey
                if let isDegraded = hashArr?[degradeKey], let bool = isDegraded as? NSNumber, bool == 0 {
//                    let isLowQual = hashArr
                    self.retrievedImages.append(newImage)
                    self.imageState = .success(self.retrievedImages)
                } else {
                    self.imageState = .empty
                }
               
                
            }
        }
                
    }
    
//    func testAddPhoto() {
////        selectedImages = [testImg]
//        
////        let photoItem = PhotosPickerItem(itemIdentifier: testImgIden)
////        
////        self.selectedImages.append(PhotosPickerItem(itemIdentifier: self.testImgIden))
//        
////        let assetReq = PHAsset.fetchAssets(withLocalIdentifiers: [testImgIden], options: nil)
////        
////        let assetManager = PHImageManager.default()
////        if let asset = assetReq.firstObject {
////            let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
////            
////            assetManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: .none) { uiImage, hashArr in
////                guard let unwrappedUiImage = uiImage else { return }
////                let image = Image(uiImage: unwrappedUiImage)
////                
////                
//////                self.selectedImages.append(PhotosPickerItem(itemIdentifier: self.testImgIden))
////   
////                self.retrievedImages.append(MapTagImage(image: image, phAsset: asset))
//////                
////                self.imageState = .success(self.retrievedImages)
////            }
////        }
//        
////        Task {
////            if let selectedImage = try await testImg.loadTransferable(type: Image.self){
////                
////                retrievedImages.append(MapTagImage(image: selectedImage, phAsset: nil))
////            } else {
////                print("a")
////            }
////            }
//    }
    
    var showcaseImages: [MapTagImage] {
        retrievedImages.filter { mapTagImage in
            mapTagImage.showcased
        }
    }
    
    func geoLocateImages() async {
        var tempDict: [String: [MapTagImage]] = [:]
        for taggedImage in retrievedImages {
//        retrievedImages.forEach { taggedImage in
            guard let metaData = taggedImage.phAsset, let location = metaData.location else {
                // TODO: remove after debug
                var copyImage = taggedImage
                copyImage.creationDate = Date()
                if tempDict.keys.contains("New Zealand") {
                    tempDict["New Zealand"]?.append(copyImage)
                } else {
                    tempDict["New Zealand"] = [copyImage]
                }
                locationGroupedImages = tempDict
                return
            }
            
            // turn into task group
            do {
                if let placemark = try await geoCoder.reverseGeocodeLocation(location).first {
                    guard let country = placemark.country else { return }
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
                }
            } catch {
                var copyImage = taggedImage
                copyImage.creationDate = Date()
                if tempDict.keys.contains("New Zealand") {
                    tempDict["New Zealand"]?.append(copyImage)
                } else {
                    tempDict["New Zealand"] = [copyImage]
                }
                locationGroupedImages = tempDict
                return
            }
        }
        locationGroupedImages = tempDict
    }
    
    @Published var locationGroupedImages: [String: [MapTagImage]] = [:]
    
    //TODO: is getting called constantly - remove all computed v ariables on map viewmodel 
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
    
    //TODO: currently setup for local datetime - implement ability to orgainse by date of timezone where photo took place
    func groupImagesByDate(images: [MapTagImage], dateGroup: DateGroup) -> [String: [MapTagImage]] {
        
        var monthDict: [String: [MapTagImage]] = [:]
        var weekDict: [String: [MapTagImage]] = [:]
        var dayDict: [String: [MapTagImage]] = [:]
        
        let dateFilteredImages = images.filter { mapTagImage in
            mapTagImage.creationDate != nil
        }
    
        
        let dateOrganisedImages = dateFilteredImages.sorted { img1, img2 in
            if let date1 = img1.creationDate {
                if let date2 = img2.creationDate {
                    return date1 < date2
                } else {
                    return true
                }
            } else {
                if let _ = img2.creationDate {
                    return false
                } else {
                    return true
                }
            }
        }
        let calender = Calendar.current
        
        
        if let startDate = dateOrganisedImages.first?.creationDate, let endDate = dateOrganisedImages.last?.creationDate {
            
            
            //first check if there is a range of years
            // if so need to include that info in groupong
            
            if let years = calender.dateComponents([.year], from: startDate, to: endDate).year {
                
                
                let needToIncludeYears = years != 0
                
                
                dateOrganisedImages.forEach { mapTagImage in
                    if let date = mapTagImage.creationDate, let month = calender.dateComponents([.month], from: date).month, let day = calender.dateComponents([.day], from: date).day {
                        
                        var yearKey = ""
                        if needToIncludeYears, let year = calender.dateComponents([.year], from: date).year {
                            
                            yearKey = "/\(year)"
                        }
                        
                        
                        // MARK: month grouping
                        let monthKey = "\(month)" + yearKey
                        
                        if monthDict.keys.contains(monthKey) {
                            monthDict[monthKey]?.append(mapTagImage)
                        } else {
                            monthDict[monthKey] = [mapTagImage]
                        }
                        
                        
                        // MARK: day grouping
                        let dayKey = "\(day)" + "/\(monthKey)"
                        if dayDict.keys.contains(dayKey) {
                            dayDict[dayKey]?.append(mapTagImage)
                        } else {
                            dayDict[dayKey] = [mapTagImage]
                        }
                        
                    }
                }
                
                
            }
            
            
            

        }
        
        
        
        
        
        

        
        return [:]
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
            if retrievedImages.contains(where: { mapTagImage in
                mapTagImage.id == image.itemIdentifier
            }) {
                totalProgress.addChild(Progress(totalUnitCount: 0))
                self.imageState = .success(self.retrievedImages)
            } else {
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
                            print("\(self.retrievedImages.count)")
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
        
//        return self.placemark?.location?.coordinate
        
        //TODO: REMOVE - DEBUG ONLY
        return CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971)
//        if let coord = self.placemark?.location?.coordinate {    
//        }
    }
    
    static let testData: MapTagImage = MapTagImage(image: Image("FoxGlacier"), phAsset: nil)
}



enum TransferError: Error {
    case importFailed
}

struct CountryKey: Hashable {
    var countryName: String
}


