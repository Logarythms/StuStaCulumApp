//
//  PersistenceManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 04.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import UIKit

class StorageManager {
    static let shared = StorageManager()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    let fileManager = FileManager.default
    
    private init() {
        decoder.dateDecodingStrategy = .custom(SSCDateFormatter.shared.customDateDecoder(_:))
        encoder.dateEncodingStrategy = .iso8601
    }
    
    
    func getLocalData() throws -> (Stustaculum, [SSCDay], [Performance], [Location], [HowTo], [NewsEntry]) {
        let ssc = try loadCurrentSSC()
        let days = (try? loadDays()) ?? []
        let performances = try loadPerformances()
        let locations = try loadLocations()
        let howTos = try loadHowTos()
        let news = try loadNews()
        
        return (ssc, days, performances, locations, howTos, news)
    }
    
    func initializeFallbackData() throws {
        deleteIncompleteData()
        
        for savePath in SavePath.allCases {
            if (savePath != .days) {
                try fileManager.copyItem(at: savePath.localResource, to: savePath.url)
            }
        }
    }
    
    private func deleteIncompleteData() {
        for savePath in SavePath.allCases {
            try? fileManager.removeItem(at: savePath.url)
        }
    }
    
    func localDataExists() -> Bool {
        for savePath in SavePath.allCases {
            guard fileManager.fileExists(atPath: savePath.url.path) else { return false }
        }
        return true
    }
    
    //MARK: Load local data
    private func loadCurrentSSC() throws -> Stustaculum {
        let sscData = try Data(contentsOf: SavePath.currentSSC.url)
        let decodedSSC = try decoder.decode(Stustaculum.self, from: sscData)

        return decodedSSC
    }
    
    private func loadDays() throws -> [SSCDay] {
        let dayData = try Data(contentsOf: SavePath.days.url)
        let decodedDays = try decoder.decode([SSCDay].self, from: dayData)
        
        return decodedDays
    }
    
    private func loadPerformances() throws -> [Performance] {
        let performancesData = try Data(contentsOf: SavePath.performances.url)
        let decodedPerformances = try decoder.decode([Performance].self, from: performancesData)
        
        return decodedPerformances
    }
    
    private func loadLocations() throws -> [Location] {
        let locationsData = try Data(contentsOf: SavePath.locations.url)
        let decodedLocations = try decoder.decode([Location].self, from: locationsData)
        
        return decodedLocations
    }
    
    private func loadHowTos() throws -> [HowTo] {
        let howTosData = try Data(contentsOf: SavePath.howTos.url)
        let decodedHowTos = try decoder.decode([HowTo].self, from: howTosData)
        
        return decodedHowTos
    }
    
    private func loadNews() throws -> [NewsEntry] {
        let newsData = try Data(contentsOf: SavePath.news.url)
        let decodedNews = try decoder.decode([NewsEntry].self, from: newsData)
        
        return decodedNews.sorted { $0.id >= $1.id }
    }
    
    //MARK: save local data
    
    func saveData(_ ssc: Stustaculum, days: [SSCDay],
                  performances: [Performance], locations: [Location],
                  howTos: [HowTo], news: [NewsEntry]) throws {
        try saveCurrentSSC(ssc)
        try saveDays(days)
        try savePerformances(performances)
        try saveLocations(locations)
        try saveHowTos(howTos)
        try saveNews(news)
        
        print("all data written to storage")
    }
    
    func saveCurrentSSC(_ ssc: Stustaculum) throws {
        let data = try self.encoder.encode(ssc)
        try data.write(to: SavePath.currentSSC.url)
    }
    
    func saveDays(_ days: [SSCDay]) throws {
        let data = try self.encoder.encode(days)
        try data.write(to: SavePath.days.url)
    }
    
    func savePerformances(_ performances: [Performance]) throws {
        let data = try self.encoder.encode(performances)
        try data.write(to: SavePath.performances.url)
    }
    
    func saveLocations(_ locations: [Location]) throws {
        let data = try self.encoder.encode(locations)
        try data.write(to: SavePath.locations.url)
    }
    
    func saveHowTos(_ howTos: [HowTo]) throws {
        let data = try self.encoder.encode(howTos)
        try data.write(to: SavePath.howTos.url)
    }
    
    func saveNews(_ news: [NewsEntry]) throws {
        let data = try self.encoder.encode(news)
        try data.write(to: SavePath.news.url)
    }
}
