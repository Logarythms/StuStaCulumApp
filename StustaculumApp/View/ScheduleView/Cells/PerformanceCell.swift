//
//  PerformanceCell.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 03.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI

struct PerformanceCell: View {
    let performance: Performance
    let duration: Int
    let columnWidth: CGFloat
    
    let artist: String
    let description: EventDescripton
    
    @Environment(\.colorScheme) var colorScheme
        
    init(performance: Performance, duration: Int, columnWidth: CGFloat) {
        self.performance = performance
        self.duration = duration
        self.columnWidth = columnWidth
        
        self.description = performance.getEventDescription()
        self.artist = performance.artist ?? ""
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(artist)
                .font(.system(size: 11))
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding([.top], 5)
                .padding([.leading, .trailing], 5)
            Spacer()
        }
        .frame(width: columnWidth, height: CGFloat(duration * 2 - 4))
        .background(description.locationColor)
        .cornerRadius(8)
        .shadow(color: .gray, radius: colorScheme == .light ? 5 : 2.5)
    }
}
