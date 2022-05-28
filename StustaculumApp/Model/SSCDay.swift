//
//  SSCDay.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation

struct SSCDay {
    
    let day: Day
    let date: Date
    
    let startOfDay: Date
    let endOfDay: Date
    
    let minHour: Int
    let maxHour: Int
    let duration: Int
        
    init(_ day: Day, performances: [Performance]) throws {
        
        //calculate date of SSCDay
        guard let startDate = DataManager.shared.getCurrentSSC()?.startDate else { throw DateError.noStartDate }
        guard let date = calendar.date(byAdding: .day, value: day.rawValue, to: startDate) else { throw DateError.calculationError }
        
        let (firstPerformance, lastPerformance) = try SSCDay.getFirstLastPerformancesFor(date, performances: performances)
        
        //get minHour of Day
        self.minHour = calendar.component(.hour, from: firstPerformance.date)
        
        //build start of day Date
        let startComponents = calendar.dateComponents([.year, .month, .day, .hour], from: firstPerformance.date)
        guard let startOfDay = calendar.date(from: startComponents) else { throw DateError.calculationError }
        
        //calculate endOfDay by adding duration to the last performance
        guard let endOfDay = calendar.date(byAdding: .minute, value: lastPerformance.duration, to: lastPerformance.date) else { throw DateError.calculationError }
        
        //calculate time between start and end of day
        let delta = calendar.dateComponents([.hour, .minute], from: startOfDay, to: endOfDay)
        guard let hourDelta = delta.hour, let minuteDelta = delta.minute else { throw DateError.calculationError }
        
        
        
        if minuteDelta == 0 {
            self.maxHour = minHour + hourDelta
        } else {
            self.maxHour = minHour + hourDelta + 1
        }
        
        self.date = date
        self.duration = maxHour - minHour
        self.day = day
        self.startOfDay = startOfDay
        self.endOfDay = endOfDay
    }
    
    static func getFirstLastPerformancesFor(_ date: Date, performances: [Performance]) throws -> (Performance, Performance) {
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        //set cutoff date for first performance to 6am of CURRENT DAY because we don't want late-night events
        var firstComponents = dateComponents
        firstComponents.hour = 6
        firstComponents.minute = 0
        guard let firstDate = calendar.date(from: firstComponents) else { throw DateError.calculationError }
        
        //set cutoff date for last performance to 5:59am of NEXT DAY to include late-night events
        var lastComponents = dateComponents
        guard let dayComponent = dateComponents.day else { throw DateError.calculationError }
        lastComponents.day = dayComponent + 1
        lastComponents.hour = 5
        lastComponents.minute = 59
        guard let lastDate = calendar.date(from: lastComponents) else { throw DateError.calculationError }
        
        //sort performances by date
        let sorted = performances.sorted { $0.date < $1.date }
        
        //filter performances before cutoff, then take first as firstPerformance
        guard let firstPerformance = sorted.filter ({
            calendar.compare(firstDate, to: $0.date, toGranularity: .minute) == .orderedAscending
        }).first else { throw DateError.calculationError }
        
        //filter performances after cutoff, then take last as lastPerformance
        guard let lastPerformance = sorted.filter({
            calendar.compare($0.date, to: lastDate, toGranularity: .minute) == .orderedAscending
        }).last else { throw DateError.calculationError }
        
        return (firstPerformance, lastPerformance)
    }
    
    enum Day: Int {
        case day1 = 0
        case day2 = 1
        case day3 = 2
        case day4 = 3
    }
}

var calendar: Calendar {
    var gregorian = Calendar(identifier: .gregorian)
    gregorian.timeZone = TimeZone(abbreviation: "CEST")!
    return gregorian
}

enum DateError: Error {
    case noStartDate
    case calculationError
}
