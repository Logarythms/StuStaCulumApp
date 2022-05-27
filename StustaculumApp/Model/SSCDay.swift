//
//  SSCDay.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation

class SSCDay {
    
    let day: Day
    let date: Date
    let minHour: Int
    let maxHour: Int
    let duration: Int
    
    init(_ day: Day) throws {
        self.day = day
        let date: Date
        
        switch day {
        case .day1:
            date = try Util.getDateForDay(1)
            minHour  = 17
            maxHour = 26
        case .day2:
            date = try Util.getDateForDay(2)
            minHour = 15
            maxHour = 25
        case .day3:
            date = try Util.getDateForDay(3)
            minHour = 15
            maxHour = 26
        case .day4:
            date = try Util.getDateForDay(4)
            minHour = 11
            maxHour = 25
        }
        
        self.date = date
        self.duration = self.maxHour-self.minHour
    }
    
    enum Day {
        case day1
        case day2
        case day3
        case day4
    }
}
