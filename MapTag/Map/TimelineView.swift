//
//  TimelineView.swift
//  MapTag
//
//  Created by Cam Graham on 19/04/2024.
//

import SwiftUI

struct TimelineView: View {
    var timeString: String
    var index: Int
    var dragPos: Double
    var textHeight: Double
    
    var selectedIndex: Double {
        dragPos.rounded(.down)
    }
    
    var distance: Double {
        abs(Double(index) - dragPos)
    }
    
    var scaleEffect: CGFloat {
        if dragPos <= -0.0 && index == 0 {
            
                return 2
            
        } else if dragPos >= 12 && index == 11 {
            
                return 2
            
        } else {
            return max(2 - (distance / 10), 1)
        }
    }
    
    var offset: CGFloat {
        return max(CGFloat(Calendar.current.monthSymbols[index].count) * (scaleEffect * -1), 0)
    }
    
    
    var body: some View {
        Text(timeString)
            .scaleEffect(scaleEffect, anchor: .trailing)
            .offset(x: offset)
//            .onChange(of: dragPos) {
//                print("\(index) = \(dragPos)")
//            }
    }
}

#Preview {
    TimelineView(timeString: "June", index: 6, dragPos: 150.66665649414062, textHeight: 22.16)
}
