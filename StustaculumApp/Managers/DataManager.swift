//
//  DataManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 15.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit

class DataManager: ObservableObject {
    
    @Published var currentSSC: Stustaculum?
    @Published var performances = [Performance]()
    @Published var news = [NewsEntry]()
    @Published var howTos = [HowTo]()
    @Published var locations = [Location]()
    @Published var days = [SSCDay]()
    @Published var logo = UIImage(named: "logo2022")
    
    static let shared = DataManager()

    private let notificationCenter = NotificationCenter.default
    private let networkingManager = NetworkingManager.shared
    private let storageManager = StorageManager.shared
    
    private init() {
        if !storageManager.localDataExists() {
            downloadInitialData()
            return
        }
        
        Task(priority: .userInitiated) {
            try? await loadLocalData()
        }
    }
    
    private func downloadInitialData() {
        Task(priority: .userInitiated) {
            do {
                try await withTimeout(seconds: 10) {
                    
                    print("start initial load")
                    
                    async let ssc = self.downloadCurrentSSC()
                    async let locations = self.downloadLocations()
                    async let howTos = self.downloadHowTos()
                    async let news = self.downloadNews()
                    
                    let performances = try await self.downloadPerformancesFor(ssc)
                    
                    try await self.setInitialData(ssc, performances: performances, locations: locations, howTos: howTos, news: news)
                    
                    try await self.storageManager.saveData(ssc, days: self.days, performances: performances, locations: locations, howTos: howTos, news: news)
                    
                    UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
                    self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
                    
                    print("initial load complete")
                }
            } catch {
                print(error.localizedDescription)
                self.handleTimeOut()
            }
            
        }
    }
    
    private func handleTimeOut() {
        print("initializing fallback data")
        
        try? storageManager.initializeFallbackData()
        
        Task {
            try? await loadLocalData()
        }
    }
    
    @MainActor
    private func loadLocalData() throws {
        let (ssc, days, performances, locations, howTos, news) = try storageManager.getLocalData()
        
        self.currentSSC = ssc
        self.performances = performances
        self.locations = locations
        self.howTos = howTos
        self.news = news
        
        if days.isEmpty {
            self.days = SSCDay.initFor(performances)
        } else {
            self.days = days
        }
        
        print("local data loaded")
        
        UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
        self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
    }
    
    @MainActor
    private func setInitialData(_ ssc: Stustaculum,
                        performances: [Performance], locations: [Location],
                        howTos: [HowTo], news: [NewsEntry]) {
        self.currentSSC = ssc
        self.performances = performances
        self.locations = locations
        self.howTos = howTos
        self.news = news
        
        self.days = SSCDay.initFor(performances)
        
        print("initial data set")
    }
    
    func getPerformancesFor(_ day: SSCDay) -> [Performance] {
        performances.filter {
            (day.startOfDay <= $0.date) && ($0.date <= day.endOfDay)
        }
    }
    
    enum DataManagerError: Error {
        case validationFailed
        case initialLoadFailed
    }
}

extension DataManager {
    private func downloadCurrentSSC() async throws -> Stustaculum {
        return try await networkingManager.getCurrentSSC()
    }
    
    private func downloadPerformancesFor(_ ssc: Stustaculum) async throws -> [Performance] {
        let performances = try await networkingManager.getPerformances(ssc)
        let filteredPerformances = performances.filter {
            ($0.stustaculumID == ssc.id) && $0.show && ($0.artist != "Electronic-Night" && $0.id != 3427 && $0.artist != "Kinderprogramm") && $0.duration > 0
        }
        
        guard TimeslotCalculator().validatePerformances(filteredPerformances) else {
            throw DataManagerError.validationFailed
        }
        
        return filteredPerformances
    }
    
    private func downloadLocations() async throws -> [Location] {
        return try await networkingManager.getLocations()
    }
    
    private func downloadHowTos() async throws -> [HowTo] {
        let howTos = try await networkingManager.getHowTos()
        
        return howTos.sorted {
            $0.title.compare($1.title, locale: Locale(identifier: "de_DE")) == .orderedAscending
        }
    }
    
    private func downloadNews() async throws -> [NewsEntry] {
        return try await networkingManager.getNews()
    }
}
