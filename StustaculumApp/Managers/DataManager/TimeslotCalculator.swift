//
//  TimeslotCalculator.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 04.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

struct TimeslotCalculator {
    
    let dataManager = DataManager.shared
    
    func getTimeslotsFor(_ day: SSCDay, location: Stage) -> [Timeslot] {
                
        guard !dataManager.performances.isEmpty else { return [] }
        let filteredPerformances = filterPerformancesBy(day, performances: dataManager.performances).filter { $0.location == location.rawValue }
        
        let timeslots =  getTimeslotsFor(filteredPerformances, day: day)
        
        guard !timeslots.isEmpty else {
            return [Timeslot(duration: day.duration, isEvent: false)]
        }
        
        return timeslots
    }
    
    func validatePerformances(_ performances: [Performance]) -> Bool {
        let days = dataManager.days
        
        for day in days {
            let filteredPerformances = filterPerformancesBy(day, performances: performances)
            
            for index in (1...4) {
                guard !getTimeslotsFor(filteredPerformances.filter {
                    $0.location == index
                }, day: day).isEmpty else {
                    return false
                }
            }
        }
        return true
    }
    
    func getTimeslotsFor(_ performances: [Performance], day: SSCDay) -> [Timeslot] {
        var timeslots = [Timeslot]()

        if performances.isEmpty {
            guard day.startOfDay <= day.endOfDay else {
                return [Timeslot]()
            }
            let timeslotLength = Int(DateInterval(start: day.startOfDay, end: day.endOfDay).duration) / 60
            timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
        }
        
        for (index, performance) in performances.enumerated() {
            if (calendar.compare(performance.date, to: day.startOfDay, toGranularity: .minute) == .orderedSame) && !(performances.count == 1) {
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
                continue
            }
            let performanceEnd = calendar.date(byAdding: .minute, value: performance.duration, to: performance.date)!
            let endComparison = calendar.compare(performanceEnd, to: day.endOfDay, toGranularity: .minute)
            
            if endComparison != .orderedDescending {
                let timeslotLength: Int
                
                if let previousPerformance = performances[safe: index - 1] {
                    guard previousPerformance.endDate() <= performance.date else {
                        return [Timeslot]()
                    }
                    timeslotLength = Int(DateInterval(start: previousPerformance.endDate(), end: performance.date).duration) / 60
                } else {
                    guard day.startOfDay <= performance.date else {
                        return [Timeslot]()
                    }
                    timeslotLength = Int(DateInterval(start: day.startOfDay, end: performance.date).duration) / 60
                }
                if timeslotLength > 0 {
                    timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
                }
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
            }
            
            if performances[safe: index + 1] == nil && endComparison != .orderedSame {
                guard performanceEnd <= day.endOfDay else {
                    return [Timeslot]()
                }
                let timeslotLength = Int(DateInterval(start: performanceEnd, end: day.endOfDay).duration) / 60
                timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
            }
            
        }
        return timeslots
    }
    
    func filterPerformancesBy(_ day: SSCDay, performances: [Performance]) -> [Performance] {
        let filteredPerformances = performances.filter({ (performance) -> Bool in
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: day.date) else { fatalError("this should not happen") }
            
            let isSameDay = (calendar.compare(performance.date, to: day.date, toGranularity: .day)) == .orderedSame
            let isNextDay = (calendar.compare(performance.date, to: nextDate, toGranularity: .day)) == .orderedSame
            let isOverlapping = performanceOverlaps(performance)
            
            if isSameDay && !isOverlapping {
                return true
            } else if isNextDay && isOverlapping {
                return true
            } else {
                return false
            }
        })
        return filteredPerformances.sorted {
            $0.date <= $1.date
        }
    }
    
    func performanceOverlaps(_ performance: Performance) -> Bool {
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
    
    func getComparisonDateFor(_ endDate: Date) -> Date {
        let endComponents = calendar.dateComponents([.day, .hour, .minute, .month, .year], from: endDate)
        
        var comparisonComponents = DateComponents()
        comparisonComponents.year = endComponents.year
        comparisonComponents.month = endComponents.month
        comparisonComponents.day = endComponents.day
        
        comparisonComponents.hour = 4
        comparisonComponents.minute = 0
        
        guard let comparisonDate = calendar.date(from: comparisonComponents) else {
            fatalError("Could not generate Comparison Date")
        }
        return comparisonDate
    }
}
