//
//  TimelineView.swift
//  MapTag
//
//  Created by Cam Graham on 27/04/2024.
//

import SwiftUI

struct TimelineView: View {
    var dateRange: [String]
    @Binding var currentIndex: Int
    
    var timelineRange: (Int, Int) { (dateRange.startIndex, dateRange.endIndex)
    }
    
    @State var dragPos: Double = 0.0
    @State var height: Double = 0
    var textHeight: Double {
        height / Double(dateRange.count)
    }
    @Binding var updateDrag: Bool
    var body: some View {
        VStack {
            ForEach(dateRange.indices, id: \.self) { index in
                TimelineItem(timeString: dateRange[index], index: index, dragPos: dragPos, textHeight: textHeight, timelineRange: timelineRange)
            }
        }
        .coordinateSpace(name: "Dates")
        .overlay(content: {
            GeometryReader(content: { geometry in
                Rectangle().opacity(0.01)
                    .onAppear {
                        height = geometry.size.height
                    }
            })
        })
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("Dates")).onChanged({ dragValue in
            
            dragPos = dragValue.location.y / textHeight
            print("\(dragPos)")
            
//                    dragPos = index
        }))
        .sensoryFeedback(.increase, trigger: currentIndex)
        .onChange(of: dragPos) { oldValue, newValue in
            currentIndex = Int(min(max(dragPos, Double(timelineRange.0)), Double(timelineRange.1 - 1)).rounded(.down))
        }
        .onChange(of: updateDrag) { oldValue, newValue in
            dragPos = Double(currentIndex) + 0.5
        }
    }
}

//#Preview {
//    TimelineView()
//}
