//
//  Util.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class Util {
    
    static var dadaColor = UIColor(red:0.35, green:0.57, blue:0.27, alpha:1.0)
    static var atriumColor = UIColor(red:0.56, green:0.26, blue:0.58, alpha:1.0)
    static var halleColor = UIColor(red:0.90, green:0.00, blue:0.33, alpha:1.0)
    static var zeltColor = UIColor(red:0.00, green:0.45, blue:0.64, alpha:1.0)
    
    static var backgroundColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.0)
    static var stageCellBackgroundColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
    
    class func colorForStage(_ id: Int) -> UIColor {
        switch id {
        case 1:
            return dadaColor
        case 2:
            return atriumColor
        case 3:
            return halleColor
        case 4:
            return zeltColor
        default:
            return dadaColor
        }
    }
    
    class func getTimeslotsFor(_ performances: [Performance], day: SSCDay) -> [Timeslot] {
        var timeslots = [Timeslot]()
        let calendar = Calendar.current
        let startOfDay = getDateForHour(day.minHour, day: day)
        let endOfDay = getDateForHour(day.maxHour, day: day)
        
        for (index, performance) in performances.enumerated() {
            if (calendar.compare(performance.date, to: startOfDay, toGranularity: .minute) == .orderedSame) {
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
                continue
            }
            let performanceEnd = calendar.date(byAdding: .minute, value: performance.duration, to: performance.date)!
            let endComparison = calendar.compare(performanceEnd, to: endOfDay, toGranularity: .minute)
            
            if endComparison != .orderedDescending {
                let timeslotLength: Int
                
                if let previousPerformance = performances[safe: index - 1] {
                    timeslotLength = Int(DateInterval(start: getEndOfPerformance(previousPerformance), end: performance.date).duration) / 60
                } else {
                    timeslotLength = Int(DateInterval(start: startOfDay, end: performance.date).duration) / 60
                }
                if timeslotLength > 0 {
                    timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
                }
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
            }
            
            if performances[safe: index + 1] == nil && endComparison != .orderedSame {
                let timeslotLength = Int(DateInterval(start: performanceEnd, end: endOfDay).duration) / 60
                timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
            }
            
        }
        return timeslots
    }
    
    class func filterPerformancesBy(_ day: SSCDay, performances: [Performance]) -> [Performance] {
        let calendar = Calendar.current
        
        return performances.filter({ (performance) -> Bool in
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: day.date) else { fatalError("this should not happen") }
            
            let isSameDay = (calendar.compare(performance.date, to: day.date, toGranularity: .day)) == .orderedSame
            let isNextDay = (calendar.compare(performance.date, to: nextDate, toGranularity: .day)) == .orderedSame
            let isOverlapping = Util.performanceOverlaps(performance)
            
            if isSameDay && !isOverlapping {
                return true
            } else if isNextDay && isOverlapping {
                return true
            } else {
                return false
            }
        })
    }
    
    class func getEndOfPerformance(_ performance: Performance) -> Date {
        let performanceEnd = Calendar.current.date(byAdding: .minute, value: performance.duration, to: performance.date)!
        return performanceEnd
    }
    
    class func getDateForHour(_ hour: Int, day: SSCDay) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day, .hour, .minute, .month, .year], from: day.date)
        
        components.hour = hour % 24
        components.minute = 0
        
        if hour > 23 {
            components.day = components.day! + 1
        }
        
        return calendar.date(from: components)!
    }
    
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
    
    class func getLabelTextFor(_ hour: Int) -> (String, String) {
        let normalizedHour = hour % 24
        let first = "\(normalizedHour):00"
        let second = "\(normalizedHour):30"
        
        return (first, second)
    }
    
}

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
