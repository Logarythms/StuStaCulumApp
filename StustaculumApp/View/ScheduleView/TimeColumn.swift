//
//  TimeColumn.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 03.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct TimeColumn: View {
    let day: SSCDay
    let headerHeight: CGFloat
    
    var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: headerHeight)
                ForEach(day.getScheduleTimeStrings(), id: \.self) { timeString in
                   Divider()
                        .frame(height: 2)
                    Text(timeString)
                        .font(.caption)
                        .bold()
                        .frame(width: 40, height: 58, alignment: .top)
                }
            }
        .background(Color("TimeCell"))
    }
}

//struct TimeColumn_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeColumn()
//    }
//}
