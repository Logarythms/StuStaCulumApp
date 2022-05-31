//
//  PerformanceView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct PerformanceView: View {
    
    let performance: Performance
    
    var body: some View {
        Text("")
    }
    
    func getFormattedDateStringFor(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

//struct PerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PerformanceView()
//    }
//}
