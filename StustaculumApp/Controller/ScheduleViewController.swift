//
//  ViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import SpreadsheetView

class ScheduleViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    var ssc: Stustaculum!
    var howTos = [HowTo]()
    var locationCategories = [LocationCategory]()
    var locations = [Location]()
    var news = [NewsEntry]()
    var performances = [Performance]()
    var performancesDay1 = [Performance]()
    var performancesDay2 = [Performance]()
    var performancesDay3 = [Performance]()
    var performancesDay4 = [Performance]()
    
    var performancesDada1 = [Performance]()
    var performancesDada2 = [Performance]()
    var performancesDada3 = [Performance]()
    var performancesDada4 = [Performance]()
    
    var performancesAtrium1 = [Performance]()
    var performancesAtrium2 = [Performance]()
    var performancesAtrium3 = [Performance]()
    var performancesAtrium4 = [Performance]()
    
    var performancesHalle1 = [Performance]()
    var performancesHalle2 = [Performance]()
    var performancesHalle3 = [Performance]()
    var performancesHalle4 = [Performance]()
    
    var performancesZelt1 = [Performance]()
    var performancesZelt2 = [Performance]()
    var performancesZelt3 = [Performance]()
    var performancesZelt4 = [Performance]()
    
    var day1: Date!
    var day2: Date!
    var day3: Date!
    var day4: Date!
    
    @IBOutlet var spreadsheetView: SpreadsheetView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScheduleView()
        setFestivalDates()
        
        NetworkingManager.getCurrentSSC(completion: currentSscRecieved)
        NetworkingManager.getHowTos(completion: howTosLoaded)
        NetworkingManager.getLocationCategories(completion: locationCategoriesLoaded)
        NetworkingManager.getLocations(completion: locationsLoaded)
        NetworkingManager.getNews(completion: newsLoaded)
        NetworkingManager.getPerformances(completion: performancesLoaded)
    }
    
    func setupScheduleView() {
        spreadsheetView.register(UINib(nibName: String(describing: PerformanceCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: PerformanceCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        spreadsheetView.isScrollEnabled = false
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
        return 17
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 30
        }
        return (spreadsheetView.bounds.width - 30) / 4
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if row == 0 {
            return 44
        }
        return 100
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
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
    
    func performancesLoaded(performances: [Performance]) {
        splitPerformances(performances: performances)
    }
    
    func splitPerformances(performances: [Performance]) {
        self.performancesDay1 = performances.filter({Calendar.current.compare($0.date, to: day1, toGranularity: .day) == .orderedSame})
        self.performancesDay2 = performances.filter({Calendar.current.compare($0.date, to: day2, toGranularity: .day) == .orderedSame})
        self.performancesDay3 = performances.filter({Calendar.current.compare($0.date, to: day3, toGranularity: .day) == .orderedSame})
        self.performancesDay4 = performances.filter({Calendar.current.compare($0.date, to: day4, toGranularity: .day) == .orderedSame})
        
        self.performancesDada1 = performancesDay1.filter({$0.location == 1})
        self.performancesDada2 = performancesDay2.filter({$0.location == 1})
        self.performancesDada3 = performancesDay3.filter({$0.location == 1})
        self.performancesDada4 = performancesDay4.filter({$0.location == 1})
        
        self.performancesAtrium1 = performancesDay1.filter({$0.location == 2})
        self.performancesAtrium2 = performancesDay2.filter({$0.location == 2})
        self.performancesAtrium3 = performancesDay3.filter({$0.location == 2})
        self.performancesAtrium4 = performancesDay4.filter({$0.location == 2})
        
        self.performancesHalle1 = performancesDay1.filter({$0.location == 3})
        self.performancesHalle2 = performancesDay2.filter({$0.location == 3})
        self.performancesHalle3 = performancesDay3.filter({$0.location == 3})
        self.performancesHalle4 = performancesDay4.filter({$0.location == 3})
        
        self.performancesZelt1 = performancesDay1.filter({$0.location == 4})
        self.performancesZelt2 = performancesDay2.filter({$0.location == 4})
        self.performancesZelt3 = performancesDay3.filter({$0.location == 4})
        self.performancesZelt4 = performancesDay4.filter({$0.location == 4})
    }
    
    func setFestivalDates() {
        var dateComponents = DateComponents()
        
        let calender = Calendar.current
        
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        
        dateComponents.year = 2018
        dateComponents.month = 5
        dateComponents.day = 30
        
        day1 = calender.date(from: dateComponents)
        
        dateComponents.day = 31
        day2 = calender.date(from: dateComponents)
        
        dateComponents.day = 1
        dateComponents.month = 6
        day3 = calender.date(from: dateComponents)
        
        dateComponents.day = 2
        day4 = calender.date(from: dateComponents)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

