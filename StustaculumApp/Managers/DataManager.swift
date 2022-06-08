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
    @Published var days = [SSCDay]()
    @Published var logo = UIImage(named: "logo2022")

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    let notificationCenter = NotificationCenter.default
    let networkingManager = NetworkingManager.shared
    let storageManager = StorageManager.shared
        
    var locations = [Location]()
    
    static let shared = DataManager()
    
    func updateNews() {
        Task {
            try? await downloadNews()
        }
    }
    
    func updatePerformances() {
        Task {
//            await downloadUpdatedPerformances()
        }
    }
    
    func getPerformancesFor(_ day: SSCDay) -> [Performance] {
        performances.filter {
            (day.startOfDay <= $0.date) && ($0.date <= day.endOfDay)
        }
    }
    
    func getAllPerformances() -> [Performance] {
        guard !performances.isEmpty else {
            return [Performance]()
        }
        return performances
    }
    
    private init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
                
        if !storageManager.localDataExists() {
            downloadInitialData()
            return
        }
        
        Task(priority: .userInitiated) {
            try? await loadLocalData()
        }
        
    }
    
    @MainActor
    func loadLocalData() throws {
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
    
    private func handleTimeOut() {
        print("initializing fallback data")
        
        try? storageManager.initializeFallbackData()
        
        Task {
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
    
    @MainActor
    func setInitialData(_ ssc: Stustaculum,
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
    
    func getLocationFor(_ stage: Stage) -> Location? {
        getLocationFor(stage.rawValue)
    }
    
    func getLocationFor(_ id: Int) -> Location? {
        locations.first { $0.id == id }
    }
}

extension DataManager {
    private func downloadCurrentSSC() async throws -> Stustaculum {
        return try await networkingManager.getCurrentSSC()
    }
    
    @MainActor func updateLogo(_ image: UIImage) {
        self.logo = image
    }
    
    private func downloadLogo(_ url: URL) async throws -> UIImage {
        return try await networkingManager.getCurrentLogo(url)
    }
    
    private func filterPerformances(_ performances: [Performance], ssc: Stustaculum) -> [Performance] {
        let filteredPerformances = performances.filter {
            ($0.stustaculumID == ssc.id) && $0.show && ($0.artist != "Electronic-Night" && $0.id != 3427 && $0.artist != "Kinderprogramm") && $0.duration > 0
        }
        //        let verifiedPerformances = filteredPerformances.filter {
        //            for performance in filteredPerformances where $0.date == performance.date && $0.location == performance.location && $0.id != performance.id {
        //                return $0.lastUpdate >= performance.lastUpdate
        //            }
        //            return true
        //        }
        //        return verifiedPerformances
        return filteredPerformances
    }
    
    private func downloadPerformancesFor(_ ssc: Stustaculum) async throws -> [Performance] {
        
        let performances = try await networkingManager.getPerformances(ssc)
        let filteredPerformances = self.filterPerformances(performances, ssc: ssc)
        
        guard TimeslotCalculator().validatePerformances(filteredPerformances) else { throw DataManagerError.validationFailed }
        return filteredPerformances
    }
    
//    private func downloadUpdatedPerformances() async -> Bool {
//        do {
//            let performances = try await networkingManager.getPerformances()
//            let filteredPerformances = self.filterPerformances(performances)
//
//            guard TimeslotCalculator().validatePerformances(filteredPerformances) else { throw DataManagerError.validationFailed }
//
//            let compareDate = Util.getLastUpdatedFor(filteredPerformances)
//            let lastUpdated = Util.getLastUpdatedFor(self.performances)
//
//            guard compareDate > lastUpdated else { return false }
//
//            let encodedData = try self.encoder.encode(filteredPerformances)
//
//            try encodedData.write(to: SavePath.performances.url)
//
//            self.performances = filteredPerformances
//            print("updated performances")
//
//            self.notificationCenter.post(name: Notification.Name("performancesUpdated"), object: nil)
//            print("updated performances loaded")
//            return true
//        } catch let error {
//            print(error)
//            return false
//        }
//
//    }
    
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
    
    enum DataManagerError: Error {
        case validationFailed
        case initialLoadFailed
    }
}
