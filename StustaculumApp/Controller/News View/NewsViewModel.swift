//
//  NewsViewModel.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

class NewsViewModel: ObservableObject {
    
    @Published var upcomingPerformances = [Performance]()
    
    let dataManager = DataManager.shared
    
    init() {        
        Task {
            for await _ in NotificationCenter.default.notifications(named: Notification.Name("fetchComplete")) {
                await updateUpcomingPerformances()
            }
        }
        
    }
    
    @MainActor
    func updateUpcomingPerformances() {
        print("upcoming")
        let performances = dataManager.getAllPerformances().filter {
            $0.date >= Date()
        }
        let sortedPerformances = performances.sorted {
            $0.date <= $1.date
        }
        let upcomingDadaPerformance = sortedPerformances.first {
            $0.location == 1
        }
        let upcomingAtriumPerformance = sortedPerformances.first {
            $0.location == 2
        }
//        let upcomingHallePerformance = sortedPerformances.first {
//            $0.location == 3
//        }
        let upcomingZeltPerformance = sortedPerformances.first {
            $0.location == 4
        }
        
        var upcoming = [Performance]()
        
        if let dada = upcomingDadaPerformance {
            upcoming.append(dada)
        }
        if let atrium = upcomingAtriumPerformance {
            upcoming.append(atrium)
        }
//        if let halle = upcomingHallePerformance {
//            upcoming.append(halle)
//        }
        if let zelt = upcomingZeltPerformance {
            upcoming.append(zelt)
        }
        upcomingPerformances.sort {
            $0.date <= $1.date
        }
        
        self.upcomingPerformances = upcoming
    }
    
}
