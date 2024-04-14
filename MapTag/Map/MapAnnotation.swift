//
//  MapAnnotation.swift
//  MapTag
//
//  Created by Cam Graham on 04/04/2024.
//

import SwiftUI
import MapKit

struct MapAnnotation: View {
    var location: TaggedLocation
    @Binding var navigatedLocation: TaggedLocation?
    @Binding var showLocationDetails: Bool
    @Binding var startExploring: Bool
    @Binding var navPath: NavigationPath
    @Binding var sheetSize: PresentationDetent
    
    //    @State var showPopover = false
    //    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        ZStack {
            Image(systemName: "mappin")
                .resizable()
                .scaledToFit()
                .frame(height:44)
                .foregroundStyle(.background)
            
            
            
            
            
        }
        
        
        
        
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.6)
        MapAnnotation(location: TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971)), navigatedLocation: .constant(TaggedLocation(country: "New Zealand", location: CLLocation(latitude: -40.900557, longitude: 174.885971))), showLocationDetails: .constant(false), startExploring: .constant(false), navPath: .constant(NavigationPath()), sheetSize: .constant(.medium))
    }
}

struct PopupIcon: View {
    var title: String
    var iconName: String
    var iconColor: Color
    var startingDegree: Double
    var body: some View {
        ZStack {
            
            CircularTextView(title: title, radius: 53, startingDegree: startingDegree)
            
            Image(systemName: iconName)
                .resizable()
                .foregroundStyle(.black, iconColor)
                .frame(width: 66, height: 66)
                .shadow(radius: 10)
        }
        
    }
}



struct CircularTextView: View {
    @State var letterWidths: [Int:Double] = [:]
    
    @State var title: String
    
    var lettersOffset: [(offset: Int, element: Character)] {
        return Array(title.enumerated())
    }
    var radius: Double
    var startingDegree: Double
    
    var body: some View {
        ZStack {
            ForEach(lettersOffset, id: \.offset) { index, letter in // Mark 1
                VStack {
                    Text(String(letter))
                        .font(.subheadline)
                        .monospaced()
                        .bold()
                        .foregroundStyle(.white)
                        .kerning(5)
                        .background(LetterWidthSize()) // Mark 2
                        .onPreferenceChange(WidthLetterPreferenceKey.self, perform: { width in  // Mark 2
                            letterWidths[index] = width
                        })
                    Spacer() // Mark 1
                }
                .rotationEffect(fetchAngle(at: index)) // Mark 3
            }
        }
        .frame(width: 120, height: 120)
        .rotationEffect(.degrees(startingDegree))
    }
    
    func fetchAngle(at letterPosition: Int) -> Angle {
        let times2pi: (Double) -> Double = { $0 * 2 * .pi }
        
        let circumference = times2pi(radius)
        
        let finalAngle = times2pi(letterWidths.filter{$0.key <= letterPosition}.map(\.value).reduce(0, +) / circumference)
        
        return .radians(finalAngle)
    }
}

struct WidthLetterPreferenceKey: PreferenceKey {
    static var defaultValue: Double = 0
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = nextValue()
    }
}

struct LetterWidthSize: View {
    var body: some View {
        GeometryReader { geometry in // using this to get the width of EACH letter
            Color
                .clear
                .preference(key: WidthLetterPreferenceKey.self,
                            value: geometry.size.width)
        }
    }
}

