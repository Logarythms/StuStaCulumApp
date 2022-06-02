//
//  NewScheduleView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 01.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct DayView: View {
    
    let headerHeight: CGFloat = 25
    let columnWidth = (UIScreen.main.bounds.size.width - 55) / 4
    
    let dataManager = DataManager.shared
    
    let day: SSCDay
    
    var body: some View {
        ZStack(alignment: .top) {
            DaySchedule(day: day, headerHeight: headerHeight, columnWidth: columnWidth)
            ScheduleHeaderView(height: headerHeight, columnWidth: columnWidth)
        }
    }
}

struct DaySchedule: View {
    
    let day: SSCDay
    let headerHeight: CGFloat
    let columnWidth: CGFloat
    
    let dataManager = DataManager.shared
    
    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: headerHeight + 5)
            HStack(alignment: .top, spacing: 0) {
                TimeColumn(day: day)
                ForEach(Stage.allCases, id: \.rawValue) { stage in
                    StageColumn(timeslots: dataManager.getTimeslotsFor(day, location: stage), columnWidth: columnWidth)
                    Spacer()
                        .frame(width: stage != .gelände ? 5 : 0)
                }
            }
        }
        .padding([.top], 5)
    }
}

struct TimeColumn: View {
    let day: SSCDay
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(day.getScheduleTimeStrings(), id: \.self) { timeString in
                Text(timeString)
                    .font(.caption)
                    .bold()
                    .frame(width: 40, height: 58, alignment: .top)
            }
        }
            .background(Color("TimeCell"))
    }
}

//struct DayView_Previews: PreviewProvider {
//    static var previews: some View {
//        DayView()
//    }
//}

//struct DaySchedule_Previews: PreviewProvider {
//    static var previews: some View {
//        DaySchedule()
//    }
//}

//struct TimeColumn_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeColumn()
//    }
//}
