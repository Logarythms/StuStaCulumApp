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
    let width = (UIScreen.main.bounds.size.width - 55) / 4
    
    var body: some View {
        VStack {
           Text("")
        }
        .frame(width: width, height: CGFloat(duration * 2 - 4))
//        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
//        .shadow(color: .gray, radius: 3)
//        .border(.yellow, width: 3)
    }
}

struct PerformCell: View {
    let performance: Performance
    let artist: String
    let description: EventDescripton
    
    let width = (UIScreen.main.bounds.size.width - 55) / 4
    
    init(performance: Performance) {
        self.performance = performance
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
//                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .frame(width: width, height: CGFloat(performance.duration * 2 - 4))
        .background(description.locationColor)
        .cornerRadius(8)
        .shadow(color: .gray, radius: 2)
    }
}

//struct DaySchedule_Previews: PreviewProvider {
//    static var previews: some View {
//        DaySchedule()
//    }
//}
