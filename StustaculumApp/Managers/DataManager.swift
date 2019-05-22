//
//  DataManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 15.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class DataManager {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dispatchGroup = DispatchGroup()
    private let notificationCenter = NotificationCenter.default
    
    private var currentSSC: Stustaculum?
    private var currentLogo: UIImage?
    private var performances: [Performance]?
    private var locations: [Location]?
    private var howTos: [HowTo]?
    private var news: [NewsEntry]?
    
    static let shared = DataManager()
    
    func updateNews() {
        downloadNews(update: true)
    }
    
    func updatePerformances() {
        downloadUpdatedPerformances()
    }
    
    func getCurrentSSC() -> Stustaculum? {
        return currentSSC
    }
    
    func getCurrentLogo() -> UIImage? {
        return currentLogo
    }
    
    func getLocations() -> [Location] {
        guard let locations = self.locations else {
            return [Location]()
        }
        return locations
    }
    
    func getHowTos() -> [HowTo] {
        guard let howTos = self.howTos else {
            return [HowTo]()
        }
        return howTos
    }
    
    func getNews() -> [NewsEntry] {
        guard let news = self.news else {
            return [NewsEntry]()
        }
        return news
    }
    
    func validatePerformances(_ performances: [Performance]) -> Bool {
        for day in Util.getSSCDays() {
            let filteredPerformances = Util.filterPerformancesBy(day, performances: performances)
            
            for index in (1...4) {
                guard !Util.getTimeslotsFor(filteredPerformances.filter {
                    $0.location == index
                }, day: day).isEmpty else {
                    return false
                }
            }
        }
        return true
    }
    
    func getTimeslotsFor(_ day: SSCDay, favoritePerformances: [Performance]? = nil) -> ([Timeslot], [Timeslot], [Timeslot], [Timeslot], [Timeslot]) {
        let performances: [Performance]
        
        if let favorites = favoritePerformances {
            performances = favorites
        } else {
            guard let allPerformances = self.performances else {
                return ([Timeslot](), [Timeslot](), [Timeslot](), [Timeslot](), [Timeslot]())
            }
            performances = allPerformances
        }
        
        let filteredPerformances = Util.filterPerformancesBy(day, performances: performances)
        
        let dada = filteredPerformances.filter {
            $0.location == 1
        }
        let atrium = filteredPerformances.filter {
            $0.location == 2
        }
        let halle = filteredPerformances.filter {
            $0.location == 3
        }
        let zelt = filteredPerformances.filter {
            $0.location == 4
        }
        let gelände = filteredPerformances.filter {
            $0.location == 5
        }
        
        return (Util.getTimeslotsFor(dada, day: day), Util.getTimeslotsFor(atrium, day: day), Util.getTimeslotsFor(halle, day: day), Util.getTimeslotsFor(zelt, day: day), Util.getTimeslotsFor(gelände, day: day))
    }
    
    func getPerformancesFor(_ day: SSCDay) -> [Performance] {
        guard let performances = self.performances else {
            return [Performance]()
        }
        return Util.filterPerformancesBy(day, performances: performances)
    }
    
    func getAllPerformances() -> [Performance] {
        guard let performances = self.performances else {
            return [Performance]()
        }
        return performances
    }
    
    private init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        
        guard   self.localDataExists(),
                self.loadLocalData() else {
            
                self.initializeData()
                return
        }
        
    }
    
    private var savePaths: [SavePath: URL] {
        var paths = [SavePath: URL]()
        for path in SavePath.allCases {
            paths[path] = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path.rawValue)
        }
        return paths
    }
    
    private func loadLocalData() -> Bool {
        guard loadCurrentSSC() else {
            return false
        }
        guard loadCurrentLogo() else {
            return false
        }
        guard loadPerformances() else {
            return false
        }
        guard loadLocations() else {
            return false
        }
        guard loadHowTos() else {
            return false
        }
        guard loadNews() else {
            return false
        }
        UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
        return true
    }
    
    private func handleTimeOut() {
        print("initializing from local data")
        guard   initializeLocalData(),
                loadLocalData() else {
                
                return
        }
        self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
    }
    
    private func deleteIncompleteData() {
        let fileManager = FileManager.default
        for savePath in SavePath.allCases {
            guard let path = savePaths[savePath] else {
                return
            }
            try? fileManager.removeItem(at: path)
        }
    }
    
    private func initializeLocalData() -> Bool {
        deleteIncompleteData()
        
        let fileManager = FileManager.default
        for savePath in SavePath.allCases {
            guard   let localSavePath = localSavePathFor(savePath),
                    let savePath = savePaths[savePath] else {
                    
                    return false
            }
            do {
                try fileManager.copyItem(at: localSavePath, to: savePath)
            } catch let error {
                print(error)
                return false
            }
        }
        
        return true
    }
    
    private func initializeData() {
        
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show(withStatus: "Daten werden geladen")
        }
        
        self.dispatchGroup.enter()
        
        downloadCurrentSSC()
        downloadLocations()
        downloadHowTos()
        downloadNews(update: false)
        
        self.dispatchGroup.leave()
        
        self.dispatchGroup.notifyWait(target: .main, timeout: .now() + 10) {
            if $0 == .success {
                SVProgressHUD.dismiss()
                UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
                self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)

            }
            if $0 == .timedOut {
                SVProgressHUD.dismiss()
                self.handleTimeOut()
            }
        }
    }
    
    private func localDataExists() -> Bool {
        for (_, url) in self.savePaths {
            guard FileManager.default.fileExists(atPath: url.path) else {
                return false
            }
        }
        return true
    }
    
    private func localSavePathFor(_ savePath: SavePath) -> URL? {
        switch savePath {
        case .currentSSC:
            return Bundle.main.url(forResource: "currentSSC", withExtension: "json")
        case .performances:
            return Bundle.main.url(forResource: "performances", withExtension: "json")
        case .locations:
            return Bundle.main.url(forResource: "locations", withExtension: "json")
        case .howTos:
            return Bundle.main.url(forResource: "howTos", withExtension: "json")
        case .news:
            return Bundle.main.url(forResource: "news", withExtension: "json")
        case .logo:
            return Bundle.main.url(forResource: "logo", withExtension: "png")
        }
    }
    
    private enum SavePath: String, CaseIterable {
        case currentSSC = "currentSSC.json"
        case performances = "performances.json"
        case locations = "locations.json"
        case howTos = "howTos.json"
        case news = "news.json"
        case logo = "logo.png"
    }
}

extension DataManager {
    private func loadCurrentSSC() -> Bool {
        guard   let sscPath = savePaths[.currentSSC],
                let sscData = try? Data(contentsOf: sscPath),
                let decodedSSC = try? decoder.decode(Stustaculum.self, from: sscData) else {
                
                return false
        }
        self.currentSSC = decodedSSC
        return true
    }
    
    private func loadCurrentLogo() -> Bool {
        guard   let logoPath = savePaths[.logo],
                let logoData = try? Data(contentsOf: logoPath),
                let logo = UIImage(data: logoData) else {
                
                return false
        }
        self.currentLogo = logo
        return true
    }
    
    private func loadPerformances() -> Bool {
        guard   let performancesPath = savePaths[.performances],
                let performancesData = try? Data(contentsOf: performancesPath),
                let decodedPerformances = try? decoder.decode([Performance].self, from: performancesData) else {
                
                return false
        }
        self.performances = filterPerformances(decodedPerformances)
        return true
    }
    
    private func loadLocations() -> Bool {
        guard   let locationsPath = savePaths[.locations],
                let locationsData = try? Data(contentsOf: locationsPath),
                let decodedLocations = try? decoder.decode([Location].self, from: locationsData) else {
                
                return false
        }
        self.locations = decodedLocations
        return true
    }
    
    private func loadHowTos() -> Bool {
        guard   let howTosPath = savePaths[.howTos],
                let howTosData = try? Data(contentsOf: howTosPath),
                let decodedHowTos = try? decoder.decode([HowTo].self, from: howTosData) else {
                
                return false
        }
        self.howTos = decodedHowTos
        return true
    }
    
    private func loadNews() -> Bool {
        guard   let newsPath = savePaths[.news],
                let newsData = try? Data(contentsOf: newsPath),
                let decodedNews = try? decoder.decode([NewsEntry].self, from: newsData) else {
                
                return false
        }
        self.news = decodedNews
        return true
    }
    
    private func downloadCurrentSSC() {
        self.dispatchGroup.enter()
        NetworkingManager.getCurrentSSC { ssc in
            self.currentSSC = ssc
            guard   let path = self.savePaths[.currentSSC],
                    let encodedData = try? self.encoder.encode(ssc) else {
                    
                    self.dispatchGroup.leave()
                    return
            }
            do {
                try encodedData.write(to: path)
                self.downloadPerformances()
                self.downloadLogo(ssc.logoURL)
            } catch let error {
                print(error)
            }
            self.dispatchGroup.leave()
        }
    }
    
    private func downloadLogo(_ url: URL) {
        self.dispatchGroup.enter()
        NetworkingManager.getCurrentLogo(url) { image in
            self.currentLogo = image
            guard   let path = self.savePaths[.logo],
                    let pngData = image.pngData() else {
                    
                    self.dispatchGroup.leave()
                    return
            }
            do {
                try pngData.write(to: path)
            } catch let error {
                print(error)
            }
            self.dispatchGroup.leave()
        }
    }
    
    private func filterPerformances(_ performances: [Performance]) -> [Performance] {
        guard let ssc = self.currentSSC else {
            return performances
        }
        let filteredPerformances = performances.filter {
            ($0.stustaculumID == ssc.id) && $0.show && ($0.artist != "Electronic-Night") && $0.duration > 0
        }
        let verifiedPerformances = filteredPerformances.filter {
            for performance in filteredPerformances where $0.date == performance.date && $0.location == performance.location && $0.id != performance.id {
                return $0.lastUpdate >= performance.lastUpdate
            }
            return true
        }
        return verifiedPerformances
    }
    
    private func downloadPerformances() {
        self.dispatchGroup.enter()
        NetworkingManager.getPerformances { performances in
            let filteredPerformances = self.filterPerformances(performances)
            guard   let path = self.savePaths[.performances],
                    let encodedData = try? self.encoder.encode(filteredPerformances),
                    self.validatePerformances(filteredPerformances) else {
                    
                    return
            }
            do {
                try encodedData.write(to: path)
                self.performances = filteredPerformances
            } catch let error {
                print(error)
            }
            self.dispatchGroup.leave()
        }
    }
    
    private func downloadUpdatedPerformances() {
        guard let lastUpdate = Util.getLastUpdatedFor(performances) else {
            return
        }
        NetworkingManager.getPerformances { performances in
            let filteredPerformances = self.filterPerformances(performances)
            guard   let compareDate = Util.getLastUpdatedFor(filteredPerformances),
                    compareDate > lastUpdate,
                    self.validatePerformances(filteredPerformances) else {
                    
                    return
            }
            
            
            guard   let path = self.savePaths[.performances],
                    let encodedData = try? self.encoder.encode(filteredPerformances) else {
                    
                    return
            }
            do {
                try encodedData.write(to: path)
                self.performances = filteredPerformances
                print("updated performances")
                self.notificationCenter.post(name: Notification.Name("performancesUpdated"), object: nil)
            } catch let error {
                print(error)
            }
        }
    }
    
    private func downloadLocations() {
        self.dispatchGroup.enter()
        NetworkingManager.getLocations { locations in
            self.locations = locations
            guard   let path = self.savePaths[.locations],
                    let encodedData = try? self.encoder.encode(locations) else {
                    
                    self.dispatchGroup.leave()
                    return
            }
            do {
                try encodedData.write(to: path)
            } catch let error {
                print(error)
            }
            self.dispatchGroup.leave()
        }
    }
    
    private func downloadHowTos() {
        self.dispatchGroup.enter()
        NetworkingManager.getHowTos { howTos in
            self.howTos = howTos
            guard   let path = self.savePaths[.howTos],
                    let encodedData = try? self.encoder.encode(howTos) else {
                    
                    self.dispatchGroup.leave()
                    return
            }
            do {
                try encodedData.write(to: path)
            } catch let error {
                print(error)
            }
            self.dispatchGroup.leave()
        }
    }
    
    private func downloadNews(update: Bool) {
        if !update {
            self.dispatchGroup.enter()
        }
        NetworkingManager.getNews { news in
            self.news = news
            guard   let path = self.savePaths[.news],
                    let encodedData = try? self.encoder.encode(news) else {
                    
                        if !update {
                            self.dispatchGroup.leave()
                        }
                    return
            }
            do {
                try encodedData.write(to: path)
                self.notificationCenter.post(name: Notification.Name("newsUpdated"), object: nil)
            } catch let error {
                print(error)
            }
            if !update {
                self.dispatchGroup.leave()
            }
        }
    }
}
