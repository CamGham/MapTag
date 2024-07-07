//
//  CountryMap.swift
//  MapTag
//
//  Created by Cam Graham on 14/04/2024.
//

import SwiftUI
import MapKit

struct CountryMap: View {
    @EnvironmentObject var photoVM: PhotoSelectionViewModel
    @StateObject var countryMapVM = CountryMapViewModel()
    @Binding var startExploring: Bool
    var location: TaggedLocation
    var mapRegion: MKCoordinateRegion
    var calculatedCameraHeight: Double
    
    @Namespace var innerLoc
    var pointsOfInterest: [MKPointOfInterestCategory] = [.airport,.amusementPark,.aquarium,.bakery,.beach,.brewery, .cafe,.campground,.carRental,.foodMarket,.gasStation,.hotel,.marina,.museum,.nationalPark,.nightlife,.park,.parking,.publicTransport,.restaurant,.stadium,.store,.winery,.zoo]
    
    @State var mapCam: MapCameraPosition = .region((MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))))
    
    
    
    @State var monthGroupedImages: [Int: [MapTagImage]] = [:]
    
//    var zoom: CGFloat = 0.0
//    var scale: CGFloat {
//        if zoom < 100_000 {
//            return 1.0
//        } else if zoom < 1_000_000 {
//            return 0.8
//        } else {
//            return 0.5
//        }
//    }
    
    @State var currentIndex = 0
    @State var manualIndexUpdate = false
    
    var currentLocation: AnimatableLocation? {
        countryMapVM.getCenterOfImages(images: monthGroupedImages[currentIndex], currentHeight: countryMapVM.zoom)
        
        
//        monthGroupedImages[currentIndex]?.first?.getImageCoords()
    }
    
//    func getZoom() -> Double {
//        return self.zoom
//    }
    
    
    @State var animateCamera = false
    @State var countryLoaded = false
    
    //TODO: currently string arr, change to date?
    var dateRange = Calendar.current.monthSymbols
    
    @State var imageDateGrouping = DateGroup.custom
    
    var groupings: [DateGroup] = [.custom, .month, .week, .day]
    
    
    var body: some View {
        let _ = Self._printChanges()
        ZStack {
            Map(position: $mapCam, bounds: MapCameraBounds(centerCoordinateBounds: mapRegion, maximumDistance: calculatedCameraHeight), interactionModes: [.pan, .zoom], scope: innerLoc) {
                ForEach(Array(monthGroupedImages.keys), id: \.self) { monthInt in
                    
                    //TODO: check if this gets called evytime zoom changes - dont twant this
                    if let animateableLocation =  countryMapVM.getCenterOfImages(images: monthGroupedImages[monthInt], currentHeight: nil), let firstImage = monthGroupedImages[monthInt]?.first {
                        let _ = print("innder ann created")
                        
                        Annotation(monthInt.getMonthString(), coordinate: animateableLocation.location) {
                            
                            PhotoAnnotation(image: firstImage.image)
                                .frame(width: 80, height: 80)
//                                .frame(width: scale * 100, height: scale * 100)
                        }
                    }
                    
                    
                    
                    
                    // TODO: get averaged location
//                    if let firstImage = monthGroupedImages[monthInt]?.first, let coord = firstImage.getImageCoords() {
//                        Annotation(monthInt.getMonthString(), coordinate: coord) {
//                            
//                            PhotoAnnotation(image: firstImage.image)
//                                .frame(width: scale * 100, height: scale * 100)
//                        }
//                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic,
                              pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest),
                              showsTraffic: false))
//            .onMapCameraChange(frequency: .continuous, { mapCam in
////                withAnimation {
//                countryMapVM.zoom = mapCam.camera.distance
////                }
//            })
            .mapCameraKeyframeAnimator(trigger: animateCamera) { mapCamera in
                KeyframeTrack(\.centerCoordinate) {
                    CubicKeyframe(currentLocation!.location, duration: 1)
                }
                
                KeyframeTrack(\.distance) {
                    CubicKeyframe(currentLocation!.height, duration: 1)
                }
            }

            HStack {
                VStack {
                    Button(action: {
                        withAnimation(.easeIn(duration: 1.0)) {
                            countryLoaded.toggle()
                        } completion: {
                            startExploring.toggle()
                        }
//                        withAnimation(.easeInOut(duration: 2.0)){
//                            startExploring.toggle()
//                        }
                        
                    }, label: {
                        Text("EXIT")
                    })
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(8)
                    
                    Spacer()
                    
                    
                }
                
                
                
                Spacer()
                
                VStack {
                    
                    Picker("Group By", selection: $imageDateGrouping) {
                        ForEach(groupings, id: \.self) { group in
                            Text(group.rawValue)
                        }
                    }
                    Spacer()
                }
            }
            
//            Text("\(currentIndex)")
//                .font(.largeTitle)
            
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    Button(action: {
                        if currentIndex > 0 {
                            currentIndex -= 1
                        manualIndexUpdate.toggle()
                        }
                    }, label: {
                        Text("Month -1")
                            .foregroundStyle(.primary)
                    })
                    .disabled(currentIndex == 0)
                    .buttonStyle(BorderedButtonStyle())
                    
                    TimelineView(dateRange: dateRange, currentIndex: $currentIndex, updateDrag: $manualIndexUpdate)
                    
                    Button(action: {
                        if currentIndex < 11 {
                            //withAnimation {
                                currentIndex += 1
                            manualIndexUpdate.toggle()
                            //}
                            
                        }
                    }, label: {
                        Text("Month +1")
                    })
                    .disabled(currentIndex == 11)
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            
            Color.black
                .opacity(countryLoaded ? 0 : 1)
                .ignoresSafeArea()
            
            
            
        }
        .onAppear(perform: {
            monthGroupedImages = photoVM.monthGroupedImages(images: photoVM.locationGroupedImages[location.country] ?? [])
            withAnimation(.easeOut(duration: 1.0)) {
                countryLoaded.toggle()
            }
        })
        .onChange(of: currentLocation) { oldValue, newValue in
            // TODO: use old value to calc animation
            if newValue != nil {
                animateCamera.toggle()
            }
        }
        
    }
}

#Preview {
    CountryMap(countryMapVM: CountryMapViewModel(), startExploring: .constant(true),location: TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971)), mapRegion: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -41.837132505080696, longitude: 172.79331092869865), span: MKCoordinateSpan(latitudeDelta: 24.752210992836861, longitudeDelta: 19.233723900868455)), calculatedCameraHeight: 4890336.595950017)
        .environmentObject(PhotoSelectionViewModel())
}

extension Int {
    func getMonthString() -> String {
        let calender = Calendar.current
        return calender.monthSymbols[self]
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    
}

struct AnimatableLocation: Equatable {
    var location: CLLocationCoordinate2D
    var height: CLLocationDistance
}

enum DateGroup: String {
    case custom = "default", month, week, day
}
