//
//  TimelineView.swift
//  MapTag
//
//  Created by Cam Graham on 19/04/2024.
//

import SwiftUI

struct TimelineItem: View {
    var timeString: String
    var index: Int
    var dragPos: Double
    var textHeight: Double
    var timelineRange: (Int, Int)
    
//    var selectedIndex: Double {
//        min(max(dragPos, Double(timelineRange.0)), Double(timelineRange.1)).rounded(.down)
//    }
    
    var distance: Double {
        
        
        
        abs((Double(index) + 0.5) - min(max(dragPos, Double(timelineRange.0)), Double(timelineRange.1)))
//        min(max(Int(index.rounded()), dateRange.startIndex), dateRange.endIndex)
        
    }
    
    var scaleEffect: CGFloat {
        if dragPos <= -0.0 && index == 0 {
            return 2 - (0.5/2)
        } else if dragPos >= 12 && index == 11 {
            return 2 - (0.5/2)
        } else {
            return max(2 - (distance / 2), 1)
        }
    }
    
    var offset: CGFloat {
        return max(CGFloat(Calendar.current.monthSymbols[index].count) * (scaleEffect * -1), 0)
    }
    
    var vertPadding: CGFloat {
//        if Int(selectedIndex) == index {
//                    2
//        } else {
//            0
//        }
//        scaleEffect * 2
        0
        
        
    }
    
    
    var body: some View {
        Text(timeString)
            .scaleEffect(scaleEffect, anchor: .trailing)
            .offset(x: offset)
            .padding(.vertical, vertPadding)
//            .onChange(of: distance) { oldValue, newValue in
//                print("\(newValue)")
//            }
            .animation(.spring, value: scaleEffect)
            
//            .onChange(of: dragPos) {
//                print("\(index) = \(dragPos)")
//            }
    }
}

#Preview {
    TimelineItem(timeString: "June", index: 6, dragPos: 150.66665649414062, textHeight: 22.16, timelineRange: (0, 11))
}
