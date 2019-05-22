//
//  Util.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class Util {
    
    static let dadaColor = UIColor(red:0.35, green:0.57, blue:0.27, alpha:1.0)
    static let atriumColor = UIColor(red:0.56, green:0.26, blue:0.58, alpha:1.0)
    static let halleColor = UIColor(red:0.90, green:0.00, blue:0.33, alpha:1.0)
    static let zeltColor = UIColor(red:0.00, green:0.45, blue:0.64, alpha:1.0)
    static let geländeColor = UIColor(red:0.38, green:0.38, blue:0.38, alpha:1.0)
    
    static var backgroundColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.0)
    static var stageCellBackgroundColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
    
    class func getLastUpdatedFor(_ performances: [Performance]?) -> Date? {
        return performances?.sorted(by: {
            $0.lastUpdate >= $1.lastUpdate
        }).first?.lastUpdate
    }
    
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
    
    class func nameForLocation(_ id: Int) -> String {
        switch id {
        case 1:
            return "Café Dada"
        case 2:
            return "Atrium"
        case 3:
            return "Hans-Scholl-Halle"
        default:
            return "Festzelt"
        }
    }
    
    class func getCoordinatesFor(_ location: Location) -> CLLocationCoordinate2D {
        guard let lat = Double(location.latitudeString) else { fatalError("lol") }
        guard let lon = Double(location.longitudeString) else { fatalError("lol") }
        
        let clLocation = CLLocation(latitude: lat, longitude: lon)
        return clLocation.coordinate
    }
    
    class func getFavouritesPath() -> URL? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let path = documentDirectoryPath {
            let favouritesPath = path + "/favourites.json"
            return URL(fileURLWithPath: favouritesPath)
        } else {
            return nil
        }
    }
    
    class func verifyDateInterval(date1: Date, date2: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        return date1 <= date2
    }
    
    class func getTimeslotsFor(_ performances: [Performance], day: SSCDay) -> [Timeslot] {
        var timeslots = [Timeslot]()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        let dateRange = getDateRangeFor(day)
        let startOfDay = dateRange.0
        let endOfDay = dateRange.1
        
        if performances.isEmpty {
            guard verifyDateInterval(date1: startOfDay, date2: endOfDay) else {
                return [Timeslot]()
            }
            let timeslotLength = Int(DateInterval(start: startOfDay, end: endOfDay).duration) / 60
            timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
        }
        
        for (index, performance) in performances.enumerated() {
            if (calendar.compare(performance.date, to: startOfDay, toGranularity: .minute) == .orderedSame) && !(performances.count == 1) {
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
                continue
            }
            let performanceEnd = calendar.date(byAdding: .minute, value: performance.duration, to: performance.date)!
            let endComparison = calendar.compare(performanceEnd, to: endOfDay, toGranularity: .minute)
            
            if endComparison != .orderedDescending {
                let timeslotLength: Int
                
                if let previousPerformance = performances[safe: index - 1] {
                    guard verifyDateInterval(date1: getEndOfPerformance(previousPerformance), date2: performance.date) else {
                        return [Timeslot]()
                    }
                    timeslotLength = Int(DateInterval(start: getEndOfPerformance(previousPerformance), end: performance.date).duration) / 60
                } else {
                    guard verifyDateInterval(date1: startOfDay, date2: performance.date) else {
                        return [Timeslot]()
                    }
                    timeslotLength = Int(DateInterval(start: startOfDay, end: performance.date).duration) / 60
                }
                if timeslotLength > 0 {
                    timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
                }
                timeslots.append(Timeslot(duration: performance.duration, isEvent: true, performance: performance))
            }
            
            if performances[safe: index + 1] == nil && endComparison != .orderedSame {
                guard verifyDateInterval(date1: performanceEnd, date2: endOfDay) else {
                    return [Timeslot]()
                }
                let timeslotLength = Int(DateInterval(start: performanceEnd, end: endOfDay).duration) / 60
                timeslots.append(Timeslot(duration: timeslotLength, isEvent: false))
            }
            
        }
        return timeslots
    }
    
    class func httpsURLfor(_ url: URL) -> URL? {
        let urlString = url.relativeString
        let httpsURLString = urlString.replacingOccurrences(of: "http", with: "https")
        return URL(string: httpsURLString)
    }
    
    class func filterPerformancesBy(_ day: SSCDay, performances: [Performance]) -> [Performance] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        let filteredPerformances = performances.filter({ (performance) -> Bool in
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
        return filteredPerformances.sorted {
            $0.date <= $1.date
        }
    }
    
    class func getEndOfPerformance(_ performance: Performance) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        let performanceEnd = calendar.date(byAdding: .minute, value: performance.duration, to: performance.date)!
        return performanceEnd
    }
    
    class func getDateRangeFor(_ day: SSCDay) -> (Date, Date) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        var components = DateComponents()
        components.year = 2019
        components.timeZone = TimeZone(abbreviation: "CEST")
        
        let startDate: Date
        let endDate: Date
        
        switch day.day {
        case .day1:
            components.month = 5
            components.day = 29
            components.hour = 17
            components.minute = 0
        case .day2:
            components.month = 5
            components.day = 30
            components.hour = 14
            components.minute = 0
        case .day3:
            components.month = 5
            components.day = 31
            components.hour = 15
            components.minute = 0
        case .day4:
            components.month = 6
            components.day = 1
            components.hour = 11
            components.minute = 0
        }
        
        startDate = calendar.date(from: components)!
        endDate = calendar.date(byAdding: .hour, value: day.duration, to: startDate)!
        
        return (startDate, endDate)
        
    }
    
    class func performanceOverlaps(_ performance: Performance) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
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
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
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
    
    class func getSSCDays() -> [SSCDay] {
        return [SSCDay(.day1), SSCDay(.day2), SSCDay(.day3), SSCDay(.day4)]
    }
    
    class func getNotificationTriggers() -> [UNCalendarNotificationTrigger] {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        var triggers = [UNCalendarNotificationTrigger]()
        
        for id in 0...3 {
            var dateComponents = DateComponents()
            dateComponents.timeZone = TimeZone(abbreviation: "CEST")
            dateComponents.year = 2019
            dateComponents.hour = 2
            dateComponents.minute = 0
            
            if (0...2).contains(id) {
                dateComponents.month = 5
            } else {
                dateComponents.month = 6
            }
            
            switch id {
            case 0:
                dateComponents.day = 30
            case 1:
                dateComponents.day = 31
            case 2:
                dateComponents.day = 1
            case 3:
                dateComponents.day = 2
            default:
                break
            }
            
            triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false))
        }
        
        return triggers
    }
    
    class func getDateForDay(_ id: Int) -> Date {
        var dateComponents = DateComponents()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.year = 2019
        
        if (1...3).contains(id) {
            dateComponents.month = 5
        } else {
            dateComponents.month = 6
        }
        
        switch id {
        case 1:
            dateComponents.day = 29
        case 2:
            dateComponents.day = 30
        case 3:
            dateComponents.day = 31
        case 4:
            dateComponents.day = 1
        default:
            break
        }
        
        guard let date = calendar.date(from: dateComponents) else {
            fatalError("Could not generate SSC Dates")
        }
        
        return date
    }
    
    class func getCurrentDayIndex() -> Int {
        let currentDate = Date()
        
        let day1 = getCutoffDateForDay(1)
        let day2 = getCutoffDateForDay(2)
        let day3 = getCutoffDateForDay(3)
        let day4 = getCutoffDateForDay(4)
        
        if currentDate >= day4 {
            return 0
        }
        if currentDate <= day4 && currentDate > day3 {
            return 3
        }
        if currentDate <= day3 && currentDate > day2 {
            return 2
        }
        if currentDate <= day2 && currentDate > day1 {
            return 1
        }
        
        return 0
    }
    
    private class func getCutoffDateForDay(_ id: Int) -> Date {
        var dateComponents = DateComponents()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CEST")!
        
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.year = 2019
        
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
            dateComponents.day = 4
        default:
            break
        }
        
        dateComponents.hour = 6
        dateComponents.minute = 0
        
        guard let date = calendar.date(from: dateComponents) else {
            fatalError("Could not generate Dates")
        }
        
        return date
    }
    
    class func getLabelTextFor(_ hour: Int) -> (String, String) {
        let normalizedHour = hour % 24
        let first = "\(normalizedHour):00"
        let second = "\(normalizedHour):30"
        
        return (first, second)
    }
    
    static let agbString = "<h1>Allgemeine Nutzungsbedingungen für die Verwendung der App</h1> Anbieter der App ist der Kulturleben in der Studentenstadt e.V. (im Folgenden „Verein Kulturleben“).<br/> <br/> Die Nutzung der App setzt voraus, dass Sie den nachfolgenden Nutzungsbedingungen zustimmen.<br/> <br/> Bitte lesen Sie sich diese deshalb sorgfältig durch. <h2>1. Allgemeines zur Nutzung</h2> In der App stehen Ihnen Informationen zum StuStaCulum, wie das Programm und die Musik der auftretenden Künstler zur Verfügung. Die in der App enthaltenen Inhalte sind auf den persönlichen Gebrauch beschränkt, soweit nicht gesetzliche Ausnahmeregelungen bestehen.<br/> <br/> Mit dem Download der App erwerben Sie keinerlei Urheber- oder gewerbliche Schutzrechte, es sei denn, diese wurden Ihnen explizit eingeräumt.<br/> <br/> Die App und deren Funktionen dürfen nicht in missbräuchlicher Art und Weise verwendet werden. Bei Verstoß gegen geltendes deutsches Recht oder unsere Nutzungsbedingungen behält sich der Verein Kulturleben das Recht vor, Sie von der Nutzung der App auszuschließen. <h2>2. Push-Benachrichtigung</h2> Die App erzeugt standardmäßig Push-Benachrichtigungen, um den Nutzer über verschiedene Dinge zu informieren. Diese Funktion kann nicht deaktiviert werden. <h2>3. Social-Media-Dienste</h2> Die App enthält Verknüpfungen zu Social-Media-Diensten (Facebook, Twitter) und die Möglichkeit zum Versenden von E-Mail-Empfehlungen. <br/> <br/> Diese Funktionalität ist standardmäßig aktiviert und kann nicht deaktiviert werden. <h2>4. Sonstiges</h2> Der Verein Kulturleben arbeitet stetig daran, die App zu optimieren.<br/> Deswegen behält sich der Verein Kulturleben das Recht vor, Funktionen und Features hinzuzufügen oder zu entfernen und eventuell neue Beschränkungen der Dienste einzuführen.<br/> <br/> Sie können jederzeit die Nutzung der App beenden. Der Verein Kulturleben übernimmt keine Garantien hinsichtlich Verfügbarkeit, Zuverlässigkeit, Funktionalität oder Eignung der App für Ihre Zwecke. Eine Haftung für Vorsatz und grobe Fahrlässigkeit richtet sich allein nach den gesetzlichen Vorschriften.<br/> <br/> Eine Haftung für Fahrlässigkeit wird nur übernommen, wenn der VereinKulturleben Kardinalspflichten verletzt hat. Der Verein Kulturleben behält sich das Recht vor, die Nutzungsbedingungen zu ändern und anzupassen.<br/> Hierüber werden Sie in geeigneter Weise informiert."
    
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
