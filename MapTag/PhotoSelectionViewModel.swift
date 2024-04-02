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
    
    private func loadImages(selectedImages: [PhotosPickerItem]) -> Progress {
        let totalProgress: MutableProgress = MutableProgress()
        var loadedImages: [Image] = []
        selectedImages.forEach { image in
            let progress = image.loadTransferable(type: MapTagImage.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success?):
                        loadedImages.append(success.image)
                        self.imageState = .success(loadedImages)
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
    case success([Image])
    case loading(Progress)
    case empty
    case failure(Error)
}

struct MapTagImage: Transferable {
    let image: Image
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            #if canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return MapTagImage(image: image)
            #else
                throw TransferError.importFailed
            #endif
        }
    }
}


enum TransferError: Error {
    case importFailed
}
