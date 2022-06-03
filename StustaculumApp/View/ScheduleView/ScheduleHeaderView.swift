//
//  ScheduleHeaderView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 03.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI

struct ScheduleHeaderView: View {
    let height: CGFloat
    let columnWidth: CGFloat
    
    let dataManager = DataManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("")
                .frame(width: 40, height: height)
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
                    .frame(width: columnWidth, height: height, alignment: .center)
                    .background(Color(dataManager.getLocationFor(stage)?.color() ?? Util.colorForStage(stage.rawValue)))
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: colorScheme == .light ? 5 : 2.5)
                Spacer()
                    .frame(width: stage != .gelände ? 5 : 0)
                
            }
        }
        .frame(height: height)
    }
}

struct ScheduleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleHeaderView(height: 25, columnWidth: 50)
    }
}
