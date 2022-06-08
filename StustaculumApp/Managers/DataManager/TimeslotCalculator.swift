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
        let filteredPerformances = dataManager.performances.filter {
            (day.startOfDay <= $0.date) && ($0.date <= day.endOfDay) && ($0.location == location.rawValue)
        }.sorted {
            $0.date <= $1.date
        }
        
        let timeslots =  getTimeslotsFor(filteredPerformances, day: day)
        
        guard !timeslots.isEmpty else {
            return [Timeslot(duration: day.duration, isEvent: false)]
        }
        
        return timeslots
    }
    
    func validatePerformances(_ performances: [Performance]) -> Bool {
        let days = dataManager.days
        
        for day in days {
            let filteredPerformances = dataManager.performances.filter {
                (day.startOfDay <= $0.date) && ($0.date <= day.endOfDay)
            }.sorted {
                $0.date <= $1.date
            }
            
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
    
    private func getTimeslotsFor(_ performances: [Performance], day: SSCDay) -> [Timeslot] {
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
}
