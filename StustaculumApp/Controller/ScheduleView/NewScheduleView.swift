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
        ScrollView {
//            HStack(alignment: .top) {
//                ForEach(Stage.allCases, id: \.rawValue) { stage in
//                    LocationLabel(locationName: Util.nameForLocation(stage.rawValue), locationColor: Color(dataManager.getLocationFor(stage)?.color() ?? Util.colorForStage(stage.rawValue)))
//                }
//            }
//            .frame(height: 40)
            HStack(alignment: .top, spacing: 5) {
                ForEach(Stage.allCases, id: \.rawValue) { stage in
                    VStack(alignment: .center) {
                        LocationLabel(locationName: Util.nameForLocation(stage.rawValue), locationColor: Color(dataManager.getLocationFor(stage)?.color() ?? Util.colorForStage(stage.rawValue)))
                            .frame(height: 40)
                        DaySchedule(timeslots: dataManager.getTimeslotsFor(day, location: stage))
                    }
                }
            }
        }
    }
}

//struct NewScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewScheduleView()
//    }
//}
