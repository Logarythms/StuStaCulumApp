//
//  ViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import SpreadsheetView
import XLPagerTabStrip

class ScheduleDayViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, IndicatorInfoProvider {
    
    var ssc: Stustaculum!
    var howTos = [HowTo]()
    var locationCategories = [LocationCategory]()
    var locations = [Location]()
    var news = [NewsEntry]()
    
    var performances = [Performance]()
    
    var timeslotsDada = [Timeslot]()
    var timeslotsAtrium = [Timeslot]()
    var timeslotsHalle = [Timeslot]()
    var timeslotsZelt = [Timeslot]()
    
    var slotInfo = [IndexPath: Performance]()

    var day: SSCDay!
    
    var pvc: ButtonBarPagerTabStripViewController?
    
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScheduleView()
        
        NetworkingManager.getPerformancesFor(day, completion: splitPerformances)
        NetworkingManager.getCurrentSSC(completion: currentSscRecieved)
        NetworkingManager.getHowTos(completion: howTosLoaded)
        NetworkingManager.getLocationCategories(completion: locationCategoriesLoaded)
        NetworkingManager.getLocations(completion: locationsLoaded)
        NetworkingManager.getNews(completion: newsLoaded)
    }
    
    func setupScheduleView() {
        spreadsheetView.register(UINib(nibName: String(describing: PerformanceCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: PerformanceCell.self))
//        spreadsheetView.register(PerformanceCell.self, forCellWithReuseIdentifier: String(describing: PerformanceCell.self))
        spreadsheetView.register(EmptyCell.self, forCellWithReuseIdentifier: String(describing: EmptyCell.self))
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.isDirectionalLockEnabled = true
        spreadsheetView.bounces = false
        spreadsheetView.scrollView.isScrollEnabled = false
        
        
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.column == 0 && indexPath.row == 0 {
            return nil
        }
        
        if indexPath.column == 0 && indexPath.row > 0 {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: PerformanceCell.self), for: indexPath) as? PerformanceCell {
                cell.title.text = String(indexPath.row)
                return cell
            }
        }
        
        if indexPath.column > 0 && indexPath.row == 0 {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: PerformanceCell.self), for: indexPath) as? PerformanceCell {
                cell.title.text = stageFor(indexPath.column)
                return cell
            }
        }
        
        if let performance = slotInfo[indexPath] {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: PerformanceCell.self), for: indexPath) as? PerformanceCell {
                cell.title.text = performance.artist!
                cell.color = Util.colorForStage(performance.location)
                return cell
            }
        }
        
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: EmptyCell.self), for: indexPath)
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var mergedCells = [CellRange]()
        let hours = day.maxHour - day.minHour
        
        guard !self.performances.isEmpty else {
            return mergedCells
        }
        
        for row in 0..<hours {
            mergedCells.append(CellRange(from: (60 * row + 1, 0), to: (60 * (row + 1), 0)))
        }
        
        var minutes = 0
        
        for timeslot in timeslotsDada {
            let cellRange = CellRange(from: (minutes + 1, 1), to: (minutes + timeslot.duration, 1))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }
        
        minutes = 0
        
        for timeslot in timeslotsAtrium {
            let cellRange = CellRange(from: (minutes + 1, 2), to: (minutes + timeslot.duration, 2))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }
        
        minutes = 0
        
        for timeslot in timeslotsHalle {
            let cellRange = CellRange(from: (minutes + 1, 3), to: (minutes + timeslot.duration, 3))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }
        
        minutes = 0
        
        for timeslot in timeslotsZelt {
            let cellRange = CellRange(from: (minutes + 1, 4), to: (minutes + timeslot.duration, 4))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }
        
        return mergedCells
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        guard let currentDay = day else { return 0 }
        if performances.isEmpty {
            return 0
        } else {
            return (currentDay.duration) * 60 + 1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 55
        }
        let scheduleWidth = UIScreen.main.bounds.width - 55
        return scheduleWidth / 4
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if row == 0 {
            return 40
        } else {
            return 1
        }
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        guard !self.performances.isEmpty else {
            return 0
        }
        
        return 1
    }
    
    func stageFor(_ id: Int) -> String {
        switch id {
        case 1:
            return "Café Dada"
        case 2:
            return "Atrium"
        case 3:
            return "Halle"
        case 4:
            return "Zelt"
        default:
            return ""
        }
    }
    
    func currentSscRecieved(ssc: Stustaculum) {
        self.ssc = ssc
    }
    
    func howTosLoaded(howTos: [HowTo]) {
        self.howTos = howTos
    }
    
    func locationCategoriesLoaded(categories: [LocationCategory]) {
        self.locationCategories = categories
    }
    
    func locationsLoaded(locations: [Location]) {
        self.locations = locations
    }
    
    func newsLoaded(news: [NewsEntry]) {
        self.news = news
    }
    
    func splitPerformances(performances: [Performance]) {
        
        self.performances = performances
        
        let performancesDada = performances.filter({$0.location == 1}).sorted(by: {$0.date < $1.date})
        let performancesAtrium = performances.filter({$0.location == 2}).sorted(by: {$0.date < $1.date})
        let performancesHalle = performances.filter({$0.location == 3}).sorted(by: {$0.date < $1.date})
        let performancesZelt = performances.filter({$0.location == 4}).sorted(by: {$0.date < $1.date})
        
        self.timeslotsDada = Util.getTimeslotsFor(performancesDada, day: self.day)
        self.timeslotsAtrium = Util.getTimeslotsFor(performancesAtrium, day: self.day)
        self.timeslotsHalle = Util.getTimeslotsFor(performancesHalle, day: self.day)
        self.timeslotsZelt = Util.getTimeslotsFor(performancesZelt, day: self.day)
        
        spreadsheetView.reloadData()
        spreadsheetView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        switch day.day {
        case .day1:
            return "MI."
        case .day2:
            return "DO."
        case .day3:
            return "FR."
        case .day4:
            return "SA."
        }
    }

}

