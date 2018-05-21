//
//  ViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    
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
    
    var day1: Date!
    var day2: Date!
    var day3: Date!
    var day4: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFestivalDates()
        
        NetworkingManager.getCurrentSSC(completion: currentSscRecieved)
        NetworkingManager.getHowTos(completion: howTosLoaded)
        NetworkingManager.getLocationCategories(completion: locationCategoriesLoaded)
        NetworkingManager.getLocations(completion: locationsLoaded)
        NetworkingManager.getNews(completion: newsLoaded)
        NetworkingManager.getPerformances(completion: performancesLoaded)
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

