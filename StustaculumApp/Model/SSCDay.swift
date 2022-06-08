//
//  SSCDay.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation

struct SSCDay: Codable, Identifiable, Hashable {
    
    let day: Day
    let date: Date
    
    let id: Int
    
    let startOfDay: Date
    let endOfDay: Date
    
    let minHour: Int
    let maxHour: Int
    let duration: Int
    
    static func initFor(_ performances: [Performance]) -> [SSCDay] {
        do {
            return try SSCDay.Day.allCases.map {
                try SSCDay($0, performances: performances)
            }
        } catch {
            print(error)
            return []
        }
    }
        
    private init(_ day: Day, performances: [Performance]) throws {
        
        id = day.rawValue
        
        //calculate date of SSCDay
        guard let startDate = DataManager.shared.currentSSC?.startDate else { throw DateError.noStartDate }
        guard let date = calendar.date(byAdding: .day, value: day.rawValue, to: startDate) else { throw DateError.calculationError }
        
        let (firstPerformance, lastPerformance) = try SSCDay.getFirstLastPerformancesFor(date, performances: performances)
        
        //get minHour of Day
        let minHour = calendar.component(.hour, from: firstPerformance.date)
        
        //build start of day Date
        let startComponents = calendar.dateComponents([.year, .month, .day, .hour], from: firstPerformance.date)
        guard let startOfDay = calendar.date(from: startComponents) else { throw DateError.calculationError }
        
        //calculate end time of the last performance by adding duration to its start time
        guard let endOfLastPerformance = calendar.date(byAdding: .minute, value: lastPerformance.duration, to: lastPerformance.date) else { throw DateError.calculationError }
        
        //calculate end of day time by rounding up endOfLastPerformance to the next full hour
        var endOfDayComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endOfLastPerformance)
        guard let minute = endOfDayComponents.minute, let hour = endOfDayComponents.hour else {
            throw DateError.calculationError
        }
        if minute > 0 {
            endOfDayComponents.minute = 0
            endOfDayComponents.hour = hour + 1
        }
        guard let endOfDay = calendar.date(from: endOfDayComponents) else { throw DateError.calculationError }
        
        //calculate time between start and end of day
        let durationComponents = calendar.dateComponents([.hour], from: startOfDay, to: endOfDay)
        guard let duration = durationComponents.hour else { throw DateError.calculationError }
        
        self.date = date
        self.minHour = minHour
        self.maxHour = minHour + duration
        self.duration = duration * 60
        self.day = day
        self.startOfDay = startOfDay
        self.endOfDay = endOfDay
    }
    
    private static func getFirstLastPerformancesFor(_ date: Date, performances: [Performance]) throws -> (Performance, Performance) {
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
    
    enum Day: Int, Codable, CaseIterable {
        case day1 = 0
        case day2 = 1
        case day3 = 2
        case day4 = 3
    }
    
    func getShortWeekDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale = Locale(identifier: "de_DE")
        return dateFormatter.string(from: self.date)
    }
    
    func getScheduleTimeStrings() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        var strings: [String] = []
        
        var currentDate = self.startOfDay
        
        while (currentDate < self.endOfDay) {
            strings.append(dateFormatter.string(from: currentDate))
            guard let nextDate = calendar.date(byAdding: .minute, value: 30, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return strings
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
