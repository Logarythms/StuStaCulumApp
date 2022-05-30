//
//  UpcomingPerformanceView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct UpcomingPerformanceView: View {
    
    let performance: Performance
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(values: performance.getEventDescriptionSplit()) { string in
                Text(string)
                    .font(.body)
            }
        }
    }
}

//struct UpcomingPerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpcomingPerformanceView()
//    }
//}
