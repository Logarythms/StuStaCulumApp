//
//  Timeslot.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 25.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation

struct Timeslot: CustomStringConvertible, Identifiable {
    
    let duration: Int
    let isEvent: Bool
    let performance: Performance?
    let id = UUID()
    
    init(duration: Int, isEvent: Bool, performance: Performance? = nil) {
        self.duration = duration
        self.isEvent = isEvent
        self.performance = performance
    }
    
    var description: String {
        var string = ""
        
        if let p = self.performance {
            string += "\(p.artist!), "
        }
        
        string += "Duration: \(duration) min, isEvent: \(isEvent)"
        
        return string
    }
    
}
