//
//  Util.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class Util {
    
    class func performanceOverlaps(_ performance: Performance) -> Bool {
        let calendar = Calendar.current
        
        let start = performance.date
        let end = calendar.date(byAdding: .minute, value: performance.duration, to: start)!
        
        let cutoffDate = getComparisonDateFor(end)
        
        let comparison = calendar.compare(start, to: end, toGranularity: .day)
        let cutoffComparison = calendar.compare(end, to: cutoffDate, toGranularity: .hour)
        let onSameDay = calendar.isDate(start, equalTo: end, toGranularity: .day)
        let onDifferentDays = onSameDay ? false : (comparison == .orderedAscending)
        let cutoff = onDifferentDays ? false : (cutoffComparison == .orderedAscending)
        
        if cutoff {
            return true
        } else {
            return false
        }
        
    }
    
    internal class func getComparisonDateFor(_ endDate: Date) -> Date {
        let calendar = Calendar.current
        let endComponents = calendar.dateComponents([.day, .hour, .minute, .month, .year], from: endDate)
        
        var comparisonComponents = DateComponents()
        comparisonComponents.year = endComponents.year
        comparisonComponents.month = endComponents.month
        comparisonComponents.day = endComponents.day
        
        comparisonComponents.hour = 4
        comparisonComponents.minute = 0
        
        guard let comparisonDate = Calendar.current.date(from: comparisonComponents) else {
            fatalError("Could not generate Comparison Date")
        }
        return comparisonDate
    }
    
    class func getSSCDays() -> [SSCDay] {
        return [SSCDay(.day1), SSCDay(.day2), SSCDay(.day3), SSCDay(.day4)]
    }
    
    class func getDateForDay(_ id: Int) -> Date {
        var dateComponents = DateComponents()
        let calender = Calendar.current
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.year = 2018
        
        if (1...2).contains(id) {
            dateComponents.month = 5
        } else {
            dateComponents.month = 6
        }
        
        switch id {
        case 1:
            dateComponents.day = 30
        case 2:
            dateComponents.day = 31
        case 3:
            dateComponents.day = 1
        case 4:
            dateComponents.day = 2
        default:
            break
        }
        
        guard let date = calender.date(from: dateComponents) else {
            fatalError("Could not generate SSC Dates")
        }
        
        return date
    }

    
}
