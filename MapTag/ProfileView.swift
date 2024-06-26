//
//  ProfileView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI
import Photos
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State var hasPhotos = false
    @EnvironmentObject var photoSelectionVM: PhotoSelectionViewModel
    
    @State var displayShowCase = false
    @State var showAllSelected = false
    
    var locationGroupedSections: [CountryKey] {
        photoSelectionVM.locationGroupedImages.keys.map({ countryName in
            CountryKey(countryName: countryName)
        }).sorted { countryKey1, countryKey2 in
            countryKey1.countryName < countryKey2.countryName
        }
    }
    
    @State var showError = false
    
    var body: some View {
        NavigationStack {
            Form {
                if !photoSelectionVM.retrievedImages.isEmpty {
                    Section {
                        if photoSelectionVM.showcaseImages.isEmpty {
                            Button("Create your showcase") {
                                print("Initial showcase creation")
                            }
                            .disabled(photoSelectionVM.retrievedImages.isEmpty)
                        } else {
                            ScrollView(.horizontal) {
                                HStack(spacing: 2) {
                                    ForEach(photoSelectionVM.showcaseImages.indices, id: \.self) { index in
                                        photoSelectionVM.showcaseImages[index].image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Private Showcase")
                            
                            Spacer()
                            //                        PhotosPicker(selection: $photoSelectionVM.selectedImages) {
                            //                            Image(systemName: "photo.badge.plus")
                            //                        }
                            Text("showcase selector")
                        }
                    } footer: {
                        HStack {
                            Spacer()
                            Button("View All") {
                                displayShowCase.toggle()
                            }
                            .disabled(photoSelectionVM.showcaseImages.isEmpty)
                        }
                    }
                }
                
                
                Section {
                    switch photoSelectionVM.imageState {
                    case .success(let images):
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 2) {
                                ForEach(images.indices, id: \.self) { index in
                                    images[index].image
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                        
                    case .loading(let progress):
                        HStack {
                            Spacer()
                            ProgressView("Loading selected images...",
                                         value: progress.fractionCompleted)
                            .progressViewStyle(.circular)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    case .empty:
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.gray)
                                Text("No Photos Added")
                                    .font(.headline)
                                Text("Selected photos will appear here")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    case .failure(let error):
                        
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.gray)
                                Text("No Photos Added")
                                    .font(.headline)
                                Text("Showcase photos will appear here")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .onAppear(perform: {
                            showError.toggle()
                        })
                        .alert("Image Retrieval Failed", isPresented: $showError) {
                            Button("Ok", role: .cancel) {
                                showError.toggle()
                            }
                        } message: {
                            Text("An error occured while attempting to retrieve your selected image/s: \(error.localizedDescription)")
                        }
                        
                    }
                } header: {
                    HStack {
                        Text("Your Photos")
                        
                        Spacer()
                        PhotosPicker(selection: $photoSelectionVM.selectedImages) {
                            Image(systemName: "photo.badge.plus")
                        }
                    }
                } footer: {
                    HStack {
                        Spacer()
                        Button("View All") {
                            showAllSelected.toggle()
                        }
                        .disabled(photoSelectionVM.selectedImages.isEmpty)
                    }
                }
                
                if photoSelectionVM.placemarkCountryKeys.isEmpty && !photoSelectionVM.retrievedImages.isEmpty {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "location.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.gray)
                            Text("No Locations Deteced")
                                .font(.headline)
                            Text("Added photos have no location tags.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                } else {
                    ForEach(locationGroupedSections, id: \.countryName) { countryKey in
                        ProfileImageContainer(hashableNavigation: countryKey, headerTitle: countryKey.countryName, images: photoSelectionVM.locationGroupedImages[countryKey.countryName] ?? [])
                    }
                }
                
            }
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            })
            .navigationDestination(isPresented: $showAllSelected) {
                ImageContainerView(title: "Selected Images", images: photoSelectionVM.retrievedImages, dateGroupedImages: photoSelectionVM.dateGroupedImages(images: photoSelectionVM.retrievedImages))
            }
            .navigationDestination(isPresented: $displayShowCase) {
                ImageContainerView(title: "Show Case", images: photoSelectionVM.showcaseImages, dateGroupedImages: photoSelectionVM.dateGroupedImages(images: photoSelectionVM.showcaseImages))
            }
            .navigationDestination(for: CountryKey.self) { countryKey in
                ImageContainerView(title: countryKey.countryName, images: photoSelectionVM.locationGroupedImages[countryKey.countryName] ?? [], dateGroupedImages: photoSelectionVM.dateGroupedImages(images: photoSelectionVM.locationGroupedImages[countryKey.countryName] ?? []))
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(PhotoSelectionViewModel())
}
