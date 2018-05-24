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
    
    var performancesDada = [Performance]()
    var performancesAtrium = [Performance]()
    var performancesHalle = [Performance]()
    var performancesZelt = [Performance]()

    var day: SSCDay?
    
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScheduleView()
        
        NetworkingManager.getCurrentSSC(completion: currentSscRecieved)
        NetworkingManager.getHowTos(completion: howTosLoaded)
        NetworkingManager.getLocationCategories(completion: locationCategoriesLoaded)
        NetworkingManager.getLocations(completion: locationsLoaded)
        NetworkingManager.getNews(completion: newsLoaded)
    }
    
    func setupScheduleView() {
        spreadsheetView.register(UINib(nibName: String(describing: PerformanceCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: PerformanceCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.column == 0 && indexPath.row == 0 {
            return nil
        }
        
        if indexPath.column == 0 && indexPath.row > 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: PerformanceCell.self), for: indexPath) as! PerformanceCell
            cell.title.text = String(indexPath.row)
            return cell
        }
        
        if indexPath.column > 0 && indexPath.row == 0 {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: PerformanceCell.self), for: indexPath) as? PerformanceCell {
                cell.title.text = stageFor(indexPath.column)
                return cell
            }
        }
        
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
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
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        guard let currentDay = day else { return 0 }
        return currentDay.maxHour - currentDay.minHour + 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 55
        }
        let scheduleWidth = UIScreen.main.bounds.width - 55
        return scheduleWidth / 4
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 44
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
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
    
    func splitPerformances() {
        let calender = Calendar.current
        guard let currentDay = self.day else { return }
        
        let filteredPerformances = performances.filter { (performance) -> Bool in
            guard let nextDate = calender.date(byAdding: .day, value: 1, to: currentDay.date) else { fatalError("this should not happen") }
            
            let isSameDay = (calender.compare(performance.date, to: currentDay.date, toGranularity: .day)) == .orderedSame
            let isNextDay = (calender.compare(performance.date, to: nextDate, toGranularity: .day)) == .orderedSame
            let isOverlapping = Util.performanceOverlaps(performance)
            
            if isSameDay && !isOverlapping {
                return true
            } else if isNextDay && isOverlapping {
                return true
            } else {
                return false
            }
            
        }
        
        self.performancesDada = filteredPerformances.filter({$0.location == 1})
        self.performancesAtrium = filteredPerformances.filter({$0.location == 2})
        self.performancesHalle = filteredPerformances.filter({$0.location == 3})
        self.performancesZelt = filteredPerformances.filter({$0.location == 4})
        
        for performance in performancesZelt {
            performance.printDescripton()
        }
        
        spreadsheetView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SSC")
    }

}

