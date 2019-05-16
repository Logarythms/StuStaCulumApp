//
//  DataManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 15.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import UIKit
import SVProgressHUD

class DataManager {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dispatchGroup = DispatchGroup()
    private let notificationCenter = NotificationCenter.default
    
    private var currentSSC: Stustaculum?
    private var performances: [Performance]?
    private var locations: [Location]?
    private var howTos: [HowTo]?
    private var news: [NewsEntry]?
    
    static let shared = DataManager()
    
    func getCurrentSSC() -> Stustaculum {
        guard let ssc = currentSSC else {
            fatalError("currentSSC is nil, this should not happen")
        }
        return ssc
    }
    
    func getLocations() -> [Location] {
        guard let locations = self.locations else {
            fatalError("locations is nil, this should not happen")
        }
        return locations
    }
    
    func getHowTos() -> [HowTo] {
        guard let howTos = self.howTos else {
            fatalError("hoTos is nil, this should not happen")
        }
        return howTos
    }
    
    func getNews() -> [NewsEntry] {
        guard let news = self.news else {
            fatalError("news is nil, this should not happen")
        }
        return news
    }
    
    func getPerformancesFor(_ day: SSCDay) -> [Performance] {
        guard let performances = self.performances else {
            return [Performance]()
        }
        return Util.filterPerformancesBy(day, performances: performances)
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
        downloadNews()
        
        self.dispatchGroup.leave()
        
        self.dispatchGroup.notify(queue: .main) {
            SVProgressHUD.dismiss()
            self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
        }
        
    }
    
    private func updateData() {
        
    }
    
    private func localDataExists() -> Bool {
        for (_, url) in self.savePaths {
            guard FileManager.default.fileExists(atPath: url.path) else {
                return false
            }
        }
        return true
    }
    
    private enum SavePath: String, CaseIterable {
        case currentSSC = "currentSSC.json"
        case performances = "performances.json"
        case locations = "locations.json"
        case howTos = "howTos.json"
        case news = "news.json"
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
    
    private func loadPerformances() -> Bool {
        guard   let performancesPath = savePaths[.performances],
                let performancesData = try? Data(contentsOf: performancesPath),
                let decodedPerformances = try? decoder.decode([Performance].self, from: performancesData) else {
                
                return false
        }
        self.performances = decodedPerformances
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
        return performances.filter {
            ($0.stustaculumID == ssc.id) && $0.show
        }
    }
    
    private func downloadPerformances() {
        self.dispatchGroup.enter()
        NetworkingManager.getPerformances { performances in
            let filteredPerformances = self.filterPerformances(performances)
            self.performances = filteredPerformances
            guard   let path = self.savePaths[.performances],
                    let encodedData = try? self.encoder.encode(filteredPerformances) else {
                    
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
    
    private func downloadNews() {
        self.dispatchGroup.enter()
        NetworkingManager.getNews { news in
            self.news = news
            guard   let path = self.savePaths[.news],
                    let encodedData = try? self.encoder.encode(news) else {
                    
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
}
