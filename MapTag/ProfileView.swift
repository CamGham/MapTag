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
    
    @State var publicShowCaseSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
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
                                Text("Showcase photos will appear here")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    case .failure(let error):
                        ZStack {
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
                        }
                    }
                } header: {
                    HStack {
                        Text("Public Showcase")
                        
                        Spacer()
                        PhotosPicker(selection: $photoSelectionVM.selectedImages) {
                            Image(systemName: "photo.badge.plus")
                        }
                    }
                } footer: {
                    HStack {
                        Spacer()
                        Button("View All") {
                            publicShowCaseSheet.toggle()
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
                    ForEach(photoSelectionVM.placemarkCountryKeys, id: \.self) { country in
                        CountryGroupedImageContainer(country: country, images: photoSelectionVM.locationGroupedImages[country] ?? [])
                        
                    }
                }

            }
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            })
            .navigationDestination(isPresented: $publicShowCaseSheet) {
                ImageContainerView(images: photoSelectionVM.retrievedImages, title: "Show Case")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(PhotoSelectionViewModel())
}
