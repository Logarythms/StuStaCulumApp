//
//  DaySchedule.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 01.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct DaySchedule: View {
    
    let timeslots: [Timeslot]
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(timeslots) { timeslot in
                if let performance = timeslot.performance {
                    NavigationLink {
                        PerformanceView(performance: performance)
                    } label: {
                        PerformCell(performance: performance)
                    }
                    .buttonStyle(.plain)

                } else {
                    EmptCell(duration: timeslot.duration)

                }
            }
        }
//        .padding([.leading, .trailing], 5)
    }
}

struct EmptCell: View {
    let duration: Int 
    var body: some View {
        VStack {
            Text("\(duration)")
            Spacer()
        }
        .frame(height: CGFloat(duration * 2 - 4))
        .cornerRadius(10)
        .border(.yellow, width: 3)
    }
}

struct PerformCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    let performance: Performance
    let artist: String
    let description: EventDescripton
    
    let width = (UIScreen.main.bounds.size.width - 10) / 4
    
    init(performance: Performance) {
        self.performance = performance
        self.description = performance.getEventDescription()
        self.artist = performance.artist ?? ""
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(artist)
                .font(.system(size: 12))
                .fontWeight(.heavy)
//                .lineLimit(3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding([.top], 5)
                .padding([.leading, .trailing], 5)
//                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .frame(width: width, height: CGFloat(performance.duration * 2 - 4))
        .background(description.locationColor)
        .cornerRadius(8)
        .shadow(color: .gray, radius: 3)
    }
}

//struct DaySchedule_Previews: PreviewProvider {
//    static var previews: some View {
//        DaySchedule()
//    }
//}
