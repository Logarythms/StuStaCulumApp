//
//  NewScheduleView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 01.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct NewScheduleView: View {
    
    let dataManager = DataManager.shared
    let day: SSCDay
    
    var body: some View {
        let width = (UIScreen.main.bounds.size.width - 55) / 4
        ZStack(alignment: .top) {
            ScrollView {
                Spacer()
                    .frame(height: 20)
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 40, height: 10)
                        .background(Color("TimeCell"))
                        .padding([.bottom], -10)
                    Spacer()
                }
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(day.getScheduleTimeStrings(), id: \.self) { timeString in
                            Text(timeString)
                                .font(.caption)
                                .bold()
                                .frame(width: 40, height: 58, alignment: .top)
                        }
                    }
                        .background(Color("TimeCell"))
                    ForEach(Stage.allCases, id: \.rawValue) { stage in
                        DaySchedule(timeslots: dataManager.getTimeslotsFor(day, location: stage))
                        Spacer()
                            .frame(width: stage != .gelände ? 5 : 0)
                    }
                }
            }
            .padding([.top], 20)
            HStack(alignment: .top, spacing: 0) {
                Text("")
                    .frame(width: 40, height: 40)
                    .background(Color.clear)
                    
                ForEach(Stage.allCases, id: \.rawValue) { stage in
                    Capsule(style: .continuous)
                        .fill(Color(dataManager.getLocationFor(stage)?.color() ?? Util.colorForStage(stage.rawValue)))
                        .overlay(
                            Text(Util.nameForLocation(stage.rawValue))
                                .font(.subheadline)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)

                        )
                        .frame(width: width, height: 40, alignment: .center)
                    Spacer()
                        .frame(width: stage != .gelände ? 5 : 0)
                    
                }
            }
            .frame(height: 40)
        }
    }
}

//struct NewScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewScheduleView()
//    }
//}
