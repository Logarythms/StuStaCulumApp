//
//  DataManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 15.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit

class DataManager: ObservableObject {
    
    @Published var news = [NewsEntry]()
    @Published var howTos = [HowTo]()
    @Published var days = [SSCDay]()
    @Published var logo: UIImage?

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    let notificationCenter = NotificationCenter.default
    let networkingManager = NetworkingManager.shared
    let storageManager = StorageManager.shared
    
    private var currentSSC: Stustaculum?
    private var performances = [Performance]() {
        didSet {
            Task {
                await updateSSCDays()
            }
        }
    }
    
    var locations = [Location]()
    
    let infoURLs = [("Offizielle Website", URL(string: "https://www.stustaculum.de")!),
                     ("Instagram", URL(string: "https://instagram.com/stustaculum/")!),
                     ("Twitter", URL(string: "https://twitter.com/stustaculum")!),
                     ("Facebook", URL(string: "https://www.facebook.com/StuStaCulum/")!)]
    
    static let shared = DataManager()
    
    @MainActor
    func updateSSCDays() {
        guard !self.performances.isEmpty else { return }
        do {
            let day1 = try SSCDay(.day1, performances: performances)
            let day2 = try SSCDay(.day2, performances: performances)
            let day3 = try SSCDay(.day3, performances: performances)
            let day4 = try SSCDay(.day4, performances: performances)
            
            self.days = [day1, day2, day3, day4]
        } catch {
            print(error)
        }
    }
    
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
    
    func getCurrentSSC() -> Stustaculum? {
        return currentSSC
    }
    
    func getPerformancesFor(_ day: SSCDay) -> [Performance] {
        guard !performances.isEmpty else {
            return [Performance]()
        }
        return TimeslotCalculator().filterPerformancesBy(day, performances: performances)
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
        
        self.initializeData()
        
//        guard   self.localDataExists(),
//                self.loadLocalData() else {
//
//                self.initializeData()
//                return
//        }
        
    }
    
    func loadLocalData() throws {
        let localData = try storageManager.getLocalData()
        
        self.currentSSC = localData.0
        self.logo = localData.1
        self.performances = localData.2
        self.locations = localData.3
        self.howTos = localData.4
        self.news = localData.5
        
        UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
    }
    
    private func handleTimeOut() {
//        print("initializing from local data")
//        guard   initializeLocalData(),
//                loadLocalData() else {
//
//                return
//        }
        self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
    }
    
    private func initializeData() {
        
        Task {
            do {
                try await withTimeout(seconds: 10) {
                    
                    print("start initial load")
                    
                    async let ssc = self.downloadCurrentSSC()
                    async let locations = self.downloadLocations()
                    async let howTos = self.downloadHowTos()
                    async let news = self.downloadNews()
                    
                    let performances = try await self.downloadPerformancesFor(ssc)
                    let logo = try await self.downloadLogo(ssc.logoURL)
                    
                    try await self.setInitialData(ssc, logo: logo, performances: performances, locations: locations, howTos: howTos, news: news)
                    
                    try await self.storageManager.saveData(ssc, logo: logo, performances: performances, locations: locations, howTos: howTos, news: news)
                    
                    UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
                    self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
                    
                    print("initial load complete")
                }
            } catch {
                print("timeout")
//                self.handleTimeOut()
            }
            
        }
    }
    
    @MainActor
    func setInitialData(_ ssc: Stustaculum,
                        logo: UIImage, performances: [Performance],
                        locations: [Location],
                        howTos: [HowTo], news: [NewsEntry]) {
        self.currentSSC = ssc
        self.logo = logo
        self.performances = performances
        self.locations = locations
        self.howTos = howTos
        self.news = news
        
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
    
    private func filterPerformances(_ performances: [Performance]) -> [Performance] {
        guard let ssc = self.currentSSC else {
            return performances
        }
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
        let filteredPerformances = self.filterPerformances(performances)
        
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
    
    @MainActor
    func publishHowTos(_ howTos: [HowTo]) {
        self.howTos = howTos
    }
    
    private func downloadHowTos() async throws -> [HowTo] {
        let howTos = try await networkingManager.getHowTos()
        
        return howTos.sorted {
            $0.title.compare($1.title, locale: Locale(identifier: "de_DE")) == .orderedAscending
        }
    }
    
    @MainActor
    func publishNews(_ news: [NewsEntry]) {
        self.news = news
    }
    
    private func downloadNews() async throws -> [NewsEntry] {
        return try await networkingManager.getNews()
    }
    
    enum DataManagerError: Error {
        case validationFailed
        case initialLoadFailed
    }
}
