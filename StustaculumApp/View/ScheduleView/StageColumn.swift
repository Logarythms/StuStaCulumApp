//
//  DaySchedule.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 01.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct StageColumn: View {
    
    let timeslots: [Timeslot]
    let columnWidth: CGFloat
    
    @State private var notificationEnabledToast = false
    @State private var notificationDisabledToast = false
    @State private var notificationErrorToast = false
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(timeslots) { timeslot in
                if let performance = timeslot.performance {
                    NavigationLink {
                        PerformanceView(performance: performance)
                    } label: {
                        PerformanceCell(performance: performance, duration: timeslot.duration, columnWidth: columnWidth)
                    }
                    .buttonStyle(.plain)

                } else {
                    EmptyCell(duration: timeslot.duration)

                }
            }
        }
        .frame(width: columnWidth)
    }
}




//struct StageColumn_Previews: PreviewProvider {
//    static var previews: some View {
//        StageColumn()
//    }
//}
