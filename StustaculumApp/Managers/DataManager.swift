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
    private let notificationCenter = NotificationCenter.default
    private let networkingManager = NetworkingManager.shared
    
    private var currentSSC: Stustaculum?
    private var performances = [Performance]() {
        didSet {
            Task {
                await updateSSCDays()
            }
        }
    }
    
    var locations = [Location]()
    
    let aboutURLs = [("Offizielle Website", URL(string: "https://www.stustaculum.de")!),
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
            await downloadNews()
        }
    }
    
    func updatePerformances() {
        Task {
            await downloadUpdatedPerformances()
        }
    }
    
    func getCurrentSSC() -> Stustaculum? {
        return currentSSC
    }
    
    func validatePerformances(_ performances: [Performance]) -> Bool {
        for day in days {
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
    
    func getTimeslotsFor(_ day: SSCDay, location: Stage) -> [Timeslot] {
        guard !performances.isEmpty else { return [] }
        let filteredPerformances = Util.filterPerformancesBy(day, performances: performances).filter { $0.location == location.rawValue }
        
        let timeslots =  Util.getTimeslotsFor(filteredPerformances, day: day)
        
        guard !timeslots.isEmpty else {
            return [Timeslot(duration: day.duration, isEvent: false)]
        }
        
        return timeslots
    }
    
    func getTimeslotsFor(_ day: SSCDay, favoritePerformances: [Performance]? = nil) -> ([Timeslot], [Timeslot], [Timeslot], [Timeslot]) {
        
        if let favorites = favoritePerformances {
            performances = favorites
        } else {
            guard !performances.isEmpty else {
                return ([Timeslot](), [Timeslot](), [Timeslot](), [Timeslot]())
            }
        }
        
        let filteredPerformances = Util.filterPerformancesBy(day, performances: performances)
        
        let dada = filteredPerformances.filter {
            $0.location == 1
        }
        let atrium = filteredPerformances.filter {
            $0.location == 2
        }
//        let halle = filteredPerformances.filter {
//            $0.location == 3
//        }
        let zelt = filteredPerformances.filter {
            $0.location == 4
        }
        let gelände = filteredPerformances.filter {
            $0.location == 5
        }
        
        return (Util.getTimeslotsFor(dada, day: day), Util.getTimeslotsFor(atrium, day: day), Util.getTimeslotsFor(zelt, day: day), Util.getTimeslotsFor(gelände, day: day))
    }
    
    func getPerformancesFor(_ day: SSCDay) -> [Performance] {
        guard !performances.isEmpty else {
            return [Performance]()
        }
        return Util.filterPerformancesBy(day, performances: performances)
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
    
    private var savePaths: [SavePath: URL] {
        var paths = [SavePath: URL]()
        for path in SavePath.allCases {
            paths[path] = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path.rawValue)
        }
        return paths
    }
    
    private func savePathURLFor(_ path: SavePath) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path.rawValue)
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
        
        Task {
            do {
                try await withTimeout(seconds: 10) {
                    
                    print("start initial load")
                    
                    async let ssc = self.downloadCurrentSSC()
                    async let locations = self.downloadLocations()
                    async let howTos = self.downloadHowTos()
                    async let news = self.downloadNews()
                    
                    let (sscLoaded, locationsLoaded, howTosLoaded, newsLoaded) = await (ssc, locations, howTos, news)
                    guard sscLoaded && locationsLoaded && howTosLoaded && newsLoaded else { throw DataManagerError.initialLoadFailed }
                    
                    UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
                    self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
                    
                    print("initial load complete")
                }
            } catch {
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
    
    func getLocationFor(_ stage: Stage) -> Location? {
        getLocationFor(stage.rawValue)
    }
    
    func getLocationFor(_ id: Int) -> Location? {
        locations.first { $0.id == id }
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
        self.logo = logo
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
        self.news = decodedNews.sorted {
            $0.id >= $1.id
        }
        return true
    }
    
    private func downloadCurrentSSC() async -> Bool {
        do {
            let ssc = try await networkingManager.getCurrentSSC()
            let path = savePathURLFor(.currentSSC)
            
            let encodedData = try self.encoder.encode(ssc)
            try encodedData.write(to: path)
            
            self.currentSSC = ssc
            
            async let performancesLoad = self.downloadPerformances()
            async let logoLoad = self.downloadLogo(ssc.logoURL)
            
            let (p,l) = await (performancesLoad, logoLoad)
            
            print("ssc loaded")
            
            return p && l
        } catch let error {
            print(error)
            return false
        }
    }
    
    @MainActor func updateLogo(_ image: UIImage) {
        self.logo = image
    }
    
    private func downloadLogo(_ url: URL) async -> Bool {
        do {
            let image = try await networkingManager.getCurrentLogo(url)
            let path = savePathURLFor(.logo)
            try image.pngData()?.write(to: path)
            print("logo loaded")
            
            await updateLogo(image)
            
            return true
        } catch let error {
            print(error)
            return false
        }
        
    }
    
    private func filterPerformances(_ performances: [Performance]) -> [Performance] {
        guard let ssc = self.currentSSC else {
            return performances
        }
        let filteredPerformances = performances.filter {
            ($0.stustaculumID == ssc.id) && $0.show && ($0.artist != "Electronic-Night" && $0.id != 3427 && $0.artist != "Kinderprogramm") && $0.duration > 0
        }
        let verifiedPerformances = filteredPerformances.filter {
            for performance in filteredPerformances where $0.date == performance.date && $0.location == performance.location && $0.id != performance.id {
                return $0.lastUpdate >= performance.lastUpdate
            }
            return true
        }
        return verifiedPerformances
    }
    
    private func downloadPerformances() async -> Bool {
        
        do {
            let performances = try await networkingManager.getPerformances()
            let filteredPerformances = self.filterPerformances(performances)
            
            guard validatePerformances(filteredPerformances) else { throw DataManagerError.validationFailed }
                        
            let encodedData = try self.encoder.encode(filteredPerformances)
            
            let path = savePathURLFor(.performances)
            try encodedData.write(to: path)
            
            self.performances = filteredPerformances
            print("performances loaded")
            return true
        } catch let error {
            print(error)
            return false
        }
        
    }
    
    private func downloadUpdatedPerformances() async -> Bool {
        do {
            let performances = try await networkingManager.getPerformances()
            let filteredPerformances = self.filterPerformances(performances)
            
            guard validatePerformances(filteredPerformances) else { throw DataManagerError.validationFailed }
            
            let compareDate = Util.getLastUpdatedFor(filteredPerformances)
            let lastUpdated = Util.getLastUpdatedFor(self.performances)
            
            guard compareDate > lastUpdated else { return false }
            
            let encodedData = try self.encoder.encode(filteredPerformances)
            
            let path = savePathURLFor(.performances)
            try encodedData.write(to: path)

            self.performances = filteredPerformances
            print("updated performances")
            
            self.notificationCenter.post(name: Notification.Name("performancesUpdated"), object: nil)
            print("updated performances loaded")
            return true
        } catch let error {
            print(error)
            return false
        }
        
    }
    
    private func downloadLocations() async -> Bool {
        do {
            let locations = try await networkingManager.getLocations()
            
            let encodedData = try self.encoder.encode(locations)
            
            let path = savePathURLFor(.locations)
            try encodedData.write(to: path)
            
            self.locations = locations
            print("locations loaded")

            return true
        } catch let error {
            print(error)
            return false
        }
        
    }
    
    @MainActor
    func publishHowTos(_ howTos: [HowTo]) {
        self.howTos = howTos
    }
    
    private func downloadHowTos() async -> Bool {
        do {
            let howTos = try await networkingManager.getHowTos()
            
            let encodedData = try self.encoder.encode(howTos)
            
            let path = savePathURLFor(.howTos)
            try encodedData.write(to: path)
            
            print("howTos loaded")
            
            await self.publishHowTos(howTos.sorted {
                $0.title.compare($1.title, locale: Locale(identifier: "de_DE")) == .orderedAscending
            })
            
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    @MainActor
    func publishNews(_ news: [NewsEntry]) {
        self.news = news
    }
    
    private func downloadNews() async -> Bool {
        do {
            let news = try await networkingManager.getNews()
            
            let encodedData = try self.encoder.encode(news)
            
            let path = savePathURLFor(.news)
            try encodedData.write(to: path)
            
            self.notificationCenter.post(name: Notification.Name("newsUpdated"), object: nil)
            print("news loaded")

            await self.publishNews(news)
            
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    enum DataManagerError: Error {
        case validationFailed
        case initialLoadFailed
    }
}
