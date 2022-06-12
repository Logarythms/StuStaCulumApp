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
    
    func getDayslots() throws -> [Dayslot] {
        var dayslots = [Dayslot]()
        
        for day in dataManager.days {
            var dayslot = Dayslot(day: day)
            for stage in Stage.allCases {
                dayslot.timeslots[stage] = try timeslotsFor(day, stage)
            }
            dayslots.append(dayslot)
        }
        
        return dayslots
    }
    
    private func timeslotsFor(_ day: SSCDay, _ stage: Stage) throws -> [Timeslot] {
        guard !dataManager.performances.isEmpty else { return [] }
        let filteredPerformances = dataManager.performancesFor(day, stage)
        let timeslots =  try getTimeslotsFor(filteredPerformances, day: day)
        
        return timeslots
    }
    
    private func getTimeslotsFor(_ performances: [Performance], day: SSCDay) throws -> [Timeslot] {
        if performances.isEmpty {
            return [Timeslot(duration: day.duration, isEvent: false)]
        }
        
        var timeslots = [Timeslot]()
        
        for (index, performance) in performances.enumerated() {
            let previous = performances[safe: index - 1]
            let next = performances[safe: index + 1]
            
            let previousOverlap = getOverlap(previous, performance)
            let nextOverlap = getOverlap(performance, next)
            
            if index == 0 {
                if performance.date > day.startOfDay {
                    timeslots.append(Timeslot(duration: getInterval(day.startOfDay, performance.date), isEvent: false))
                }
                timeslots.append(timeslotConsideringNextOverlap(performance, next, nextOverlap))
                continue
            }
            
            if index < performances.endIndex {
                guard let previous = previous else { throw TimeslotError.noPrevious }
                if previousOverlap == .none {
                    let interval = getInterval(previous.endDate(), performance.date)
                    if interval > 0 { timeslots.append(Timeslot(duration: interval, isEvent: false)) }
                }
                timeslots.append(timeslotConsideringNextOverlap(performance, next, nextOverlap))
                if previousOverlap == .contained {
                    let interval = getInterval(performance.endDate(), previous.endDate())
                    timeslots.append(Timeslot(duration: interval, isEvent: true, performance: previous))
                }
                
                if (index == performances.endIndex - 1) {
                    let endTime: Date
                    if previousOverlap == .none || previousOverlap == .extended {
                        endTime = performance.endDate()
                    } else {
                        endTime = previous.endDate()
                    }
                    
                    if day.endOfDay > endTime {
                        let interval = getInterval(endTime, day.endOfDay)
                        timeslots.append(Timeslot(duration: interval, isEvent: false))
                    }
                }
            }
            
        }
        
        return timeslots
    }
    
    private func timeslotConsideringNextOverlap(_ first: Performance, _ second: Performance?, _ overlap: Overlap) -> Timeslot {
        
        guard let second = second else {
            return Timeslot(duration: first.duration, isEvent: true, performance: first)
        }
        
        if overlap == .none {
            return Timeslot(duration: first.duration, isEvent: true, performance: first)
        } else {
            let interval = getInterval(first.date, second.date)
            return Timeslot(duration: interval, isEvent: true, performance: first)
        }
    }
        
    private func getInterval(_ first: Date, _ second: Date) -> Int {
        return Int(DateInterval(start: first, end: second).duration) / 60
    }
    
    private func getOverlap(_ first: Performance?, _ second: Performance?) -> Overlap {
        guard let first = first, let second = second else { return .none }
        
        guard second.date < first.endDate() else { return .none }
        
        if first.endDate() < second.endDate() {
            return .extended
        } else {
            return .contained
        }
    }
}

enum Overlap {
    case none
    case contained
    case extended
}

enum TimeslotError: Error {
    case overlap
    case noPrevious
}
