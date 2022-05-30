//
//  UpcomingPerformanceView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct UpcomingPerformanceView: View {
    
    let upcomingPerformances: [Performance]
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Kommende Veranstaltungen")
                .font(.title2)
                .padding(.bottom, 10)
            if upcomingPerformances.isEmpty {
                Text("Keine Veranstaltungen geplant 😞")
                    .font(.body)
                    .padding()
            }
            ForEach(upcomingPerformances) { performance in
                ForEach(values: performance.getEventDescriptionSplit()) { string in
                    Text(string)
                        .font(.body)
                }
                Spacer()
            }
        }
    }
}

//struct UpcomingPerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpcomingPerformanceView()
//    }
//}
