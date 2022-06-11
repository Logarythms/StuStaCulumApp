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
    
    func getDayslots(_ days: [SSCDay]) throws -> [Dayslot] {
        var dayslots = [Dayslot]()
        
        for day in days {
            var dayslot = Dayslot(day: day)
            for stage in Stage.allCases {
                dayslot.timeslots[stage] = timeslotsFor(day, stage)
            }
            dayslots.append(dayslot)
        }
        
        return dayslots
    }
    
    private func timeslotsFor(_ day: SSCDay, _ stage: Stage) -> [Timeslot] {
        guard !dataManager.performances.isEmpty else { return [] }
        let filteredPerformances = dataManager.performancesFor(day, stage)
        let timeslots =  try? getTimeslotsFor(filteredPerformances, day: day)
        
        guard let timeslots = timeslots else {
            return [Timeslot(duration: day.duration, isEvent: false)]
        }
        
        return timeslots
    }
    
    private func getTimeslotsFor(_ performances: [Performance], day: SSCDay) throws -> [Timeslot] {
        var timeslots = [Timeslot]()

        //No performances -> Create empty timeslot for entire day
        if performances.isEmpty {
            return [Timeslot(duration: day.duration, isEvent: false)]
        }
        
        for (index, performance) in performances.enumerated() {
            
            //If performance is exactly at start of day, add timeslot for performance
            if (performance.date == day.startOfDay) && !(performances.count == 1) {
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
                continue
            }
            
            let emptySlotLength: Int
            
            if let previousPerformance = performances[safe: index - 1] {
                
                //if pevious performance overlaps the current one throw error
                //TODO: Handle overlaps
                
                guard previousPerformance.endDate() <= performance.date else { throw TimeslotError.overlap }
                
                //emptyslot length is time between end of previous performance and start of next one
                emptySlotLength = Int(DateInterval(start: previousPerformance.endDate(), end: performance.date).duration) / 60
            } else {
                //set emptyslot length to interval between start of day and start of performance
                emptySlotLength = Int(DateInterval(start: day.startOfDay, end: performance.date).duration) / 60
            }
            
            //only add emptyslot if length is greater than 0
            if emptySlotLength > 0 {
                timeslots.append(Timeslot(duration: emptySlotLength, isEvent: false))
            }
            
            //add timeslot for the current performance
            timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
            
            //if performance is last of day and ends before end of day, append emptyslot until end of day
            if performances[safe: index + 1] == nil && performance.endDate() != day.endOfDay {
                let timeslotLength = Int(DateInterval(start: performance.endDate(), end: day.endOfDay).duration) / 60
                timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
            }
            
        }
        return timeslots
    }
}

enum TimeslotError: Error {
    case overlap
}
