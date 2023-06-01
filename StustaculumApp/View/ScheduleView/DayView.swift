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
    let columnWidth = (UIScreen.main.bounds.size.width - 55) / CGFloat(Stage.allCases.count)
    
    let dataManager = DataManager.shared
    
    let dayslot: Dayslot
    
    var body: some View {
        ZStack(alignment: .top) {
            DaySchedule(dayslot: dayslot, headerHeight: headerHeight, columnWidth: columnWidth)
            ScheduleHeaderView(height: headerHeight, columnWidth: columnWidth)
        }
    }
}

struct DaySchedule: View {
    
    let dayslot: Dayslot
    let headerHeight: CGFloat
    let columnWidth: CGFloat
    
    let dataManager = DataManager.shared
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                TimeColumn(day: dayslot.day, headerHeight: headerHeight)
                    .padding([.top], 3)
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: headerHeight + 5)
                    HStack(alignment: .top, spacing: 0) {
                        Spacer()
                            .frame(width: 40)
                        ForEach(Stage.allCases, id: \.rawValue) { stage in
                            StageColumn(timeslots: dayslot.timeslots[stage]!, columnWidth: columnWidth)
                            Spacer()
                                .frame(width: stage != .gelände ? 4 : 0)
                        }
                    }
                }
            }
        }
        .padding([.top], 5)
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
