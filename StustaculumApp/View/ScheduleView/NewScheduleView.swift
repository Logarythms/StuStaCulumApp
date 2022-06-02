//
//  NewScheduleView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 01.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct NewScheduleView: View {
    
    let headerHeight: CGFloat = 25
    
    let dataManager = DataManager.shared
    @Environment(\.colorScheme) var colorScheme
    
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
            .padding([.top], 5)
            HStack(alignment: .top, spacing: 0) {
                Text("")
                    .frame(width: 40, height: headerHeight)
                    .background(Color.clear)
                    
                ForEach(Stage.allCases, id: \.rawValue) { stage in
                    VStack {
                        Spacer()
                        Text(Util.nameForLocation(stage.rawValue))
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(width: width, height: headerHeight, alignment: .center)
                    .background(Color(dataManager.getLocationFor(stage)?.color() ?? Util.colorForStage(stage.rawValue)))
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: colorScheme == .light ? 5 : 2.5)
                    Spacer()
                        .frame(width: stage != .gelände ? 5 : 0)
                    
                }
            }
            .frame(height: headerHeight)
        }
    }
}

//struct NewScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewScheduleView()
//    }
//}
