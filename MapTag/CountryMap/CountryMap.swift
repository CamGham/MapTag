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
    @Binding var startExploring: Bool
    var location: TaggedLocation
    var mapRegion: MKCoordinateRegion
    var calculatedCameraHeight: Double
    
    @Namespace var innerLoc
    var pointsOfInterest: [MKPointOfInterestCategory] = [.airport,.amusementPark,.aquarium,.bakery,.beach,.brewery, .cafe,.campground,.carRental,.foodMarket,.gasStation,.hotel,.marina,.museum,.nationalPark,.nightlife,.park,.parking,.publicTransport,.restaurant,.stadium,.store,.winery,.zoo]
    
    @State var mapCam: MapCameraPosition = .region((MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -40.900557, longitude: 174.885971), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))))
    
    @State var monthGroupedImages: [Int: [MapTagImage]] = [:]
    
    @State var zoom: CGFloat = 0.0
    var scale: CGFloat {
        if zoom < 100_000 {
            return 1.0
        } else if zoom < 1_000_000 {
            return 0.8
        } else {
            return 0.5
        }
    }
    
    @State var height: Double = 0
    
    var textHeight: Double {
        height / Double(Calendar.current.monthSymbols.count)
    }
    
    @State var dragPos: Double = 0.0
    
    var currentMonthInt: Int {
        Int(dragPos.rounded(.down))
    }
    
    var currentLocation: CLLocationCoordinate2D? {
        monthGroupedImages[currentMonthInt]?.first?.getImageCoords()
    }
    
    @State var animateCamera = false
    @State var countryLoaded = false
    
    var body: some View {
        ZStack {
            Map(position: $mapCam, bounds: MapCameraBounds(centerCoordinateBounds: mapRegion, maximumDistance: calculatedCameraHeight), interactionModes: [.pan, .zoom], scope: innerLoc) {
                ForEach(Array(monthGroupedImages.keys), id: \.self) { monthInt in
                    // TODO: get averaged location
                    if let firstImage = monthGroupedImages[monthInt]?.first, let coord = firstImage.getImageCoords() {
                        Annotation(monthInt.getMonthString(), coordinate: coord) {
                            
                            PhotoAnnotation(image: firstImage.image)
                                .frame(width: scale * 100, height: scale * 100)
                        }
                        
                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic,
                              pointsOfInterest: PointOfInterestCategories.including(pointsOfInterest),
                              showsTraffic: false))
            .onMapCameraChange(frequency: .continuous, { mapCam in
                withAnimation {
                    zoom = mapCam.camera.distance
                }
            })
            .mapCameraKeyframeAnimator(trigger: animateCamera) { mapCamera in
                KeyframeTrack(\.centerCoordinate) {
                    CubicKeyframe(currentLocation!, duration: 1)
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
                    .padding(4)
                    
                    Spacer()
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                VStack {
                    ForEach(Calendar.current.monthSymbols.indices, id: \.self) { index in
                        TimelineView(timeString: Calendar.current.monthSymbols[index], index: index, dragPos: dragPos, textHeight: textHeight)
                    }
                }
                .coordinateSpace(name: "Dates")
                .overlay(content: {
                    GeometryReader(content: { geometry in
                        Rectangle().opacity(0.2)
                            .onAppear {
                                height = geometry.size.height
                            }
                    })
                })
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("Dates")).onChanged({ dragValue in
                    var index = dragValue.location.y / textHeight
                    dragPos = index
                }))
                .sensoryFeedback(.increase, trigger: currentMonthInt)
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
    CountryMap(startExploring: .constant(true),location: TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971)), mapRegion: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -41.837132505080696, longitude: 172.79331092869865), span: MKCoordinateSpan(latitudeDelta: 24.752210992836861, longitudeDelta: 19.233723900868455)), calculatedCameraHeight: 4890336.595950017)
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

