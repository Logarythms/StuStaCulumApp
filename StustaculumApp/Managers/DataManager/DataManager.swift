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
    @Published var notifiedPerformances = [Performance]()
    @Published var news = [NewsEntry]()
    @Published var howTos = [HowTo]()
    @Published var locations = [Location]()
    @Published var days = [SSCDay]()
    @Published var logo = UIImage(named: "logo2023")
    @Published var dayslots = [Dayslot]()
    
    @Published var notificationEnabledToast = false
    @Published var notificationDisabledToast = false
    @Published var notificationErrorToast = false
    
    static let shared = DataManager()

    private let notificationCenter = NotificationCenter.default
    private let userNC = UNUserNotificationCenter.current()
    private let networkingManager = NetworkingManager.shared
    private let storageManager = StorageManager.shared
    
    private(set) var activeNotifications = [String]() {
        didSet {
            Task {
                await updateNotifiedPerformances()
            }
        }
    }
    
    @MainActor
    func updateNotifiedPerformances() {
        self.notifiedPerformances = performances.filter {
            activeNotifications.contains(String($0.id)) && Date() < $0.date
        }.sorted {
            $0.date < $1.date
        }
    }
    
    lazy var lastUpdated = performances.sorted{$0.lastUpdate > $1.lastUpdate}.first?.lastUpdate ?? Date()
    
    private init() {
        if !storageManager.localDataExists() {
            downloadInitialData()
            return
        }

        Task(priority: .userInitiated) {
            try? await loadLocalData()
            try? await updatePerformances()
            try? await updateNews()
            try? await updateHowTos()
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
                    
                    try await self.storageManager.saveData(ssc, days: self.days, dayslots: self.dayslots, activeNotifications: self.activeNotifications, performances: performances, locations: locations, howTos: howTos, news: news)
                    
                    UserDefaults.standard.set(true, forKey: "initialLoadCompleted")
                    UserDefaults.standard.set(true, forKey: "upgrade")
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
        let (ssc, days, dayslots, activeNotifications, performances, locations, howTos, news) = try storageManager.getLocalData()
        
        self.currentSSC = ssc
        self.performances = performances
        self.locations = locations
        self.howTos = howTos
        self.news = news
        self.activeNotifications = activeNotifications
        
        if days.isEmpty {
            self.days = SSCDay.initFor(performances)
        } else {
            self.days = days
        }
        
        if dayslots.isEmpty {
            self.dayslots = (try? TimeslotCalculator().getDayslots()) ?? []
        } else {
            self.dayslots = dayslots
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
        self.dayslots = (try? TimeslotCalculator().getDayslots()) ?? []
        
        print("initial data set")
    }
    
    func performancesFor(_ day: SSCDay) -> [Performance] {
        performances.filter {
            (day.startOfDay <= $0.date) && ($0.date <= day.endOfDay)
        }.sorted {
            $0.date <= $1.date
        }
    }
    
    func performancesFor(_ day: SSCDay, _ stage: Stage) -> [Performance] {
        performancesFor(day).filter {
            $0.location == stage.rawValue
        }
    }
    
    enum DataManagerError: Error {
        case validationFailed
        case initialLoadFailed
        case notificationTimeCalculationFailed
    }
}

//MARK: Downloading
extension DataManager {
    private func downloadCurrentSSC() async throws -> Stustaculum {
        return try await networkingManager.getCurrentSSC()
    }
    
    private func downloadPerformancesFor(_ ssc: Stustaculum) async throws -> [Performance] {
        let performances = try await networkingManager.getPerformances(ssc)
        return performances.filter {
            $0.show && $0.duration > 0
        }
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

//MARK: Updating
extension DataManager {
    func updatePerformances() async throws {
        guard let ssc = currentSSC else { return }
        let performances = try await downloadPerformancesFor(ssc)
        let newUpdatedDate = performances.sorted{ $0.lastUpdate > $1.lastUpdate }.first?.lastUpdate ?? Date()
        
        print("old: \(self.lastUpdated)")
        print("new: \(newUpdatedDate)")
        
        if newUpdatedDate > self.lastUpdated {            
            try? await setPerformances(performances)
            try? await updateNotifications()
        }
    }
    
    private func updateNotifications() async throws {
        for performance in notifiedPerformances {
            try await updateNotificationFor(performance)
        }
    }
    
    @MainActor
    private func setPerformances(_ performances: [Performance]) throws {
        self.performances = performances
        self.dayslots = try TimeslotCalculator().getDayslots()
        
        self.notificationCenter.post(name: Notification.Name("fetchComplete"), object: nil)
        
        try? storageManager.savePerformances(performances)
        try? storageManager.saveDayslots(dayslots)
    }
    
    func updateNews() async throws {
        let news = try await downloadNews()
        await setNews(news)
        try? storageManager.saveNews(news)
    }
    
    @MainActor
    private func setNews(_ news: [NewsEntry]) {
        self.news = news
    }
    
    func updateHowTos() async throws {
        let howTos = try await downloadHowTos()
        await setHowTos(howTos)
        try? storageManager.saveHowTos(howTos)
    }
    
    @MainActor
    private func setHowTos(_ howTos: [HowTo]) {
        self.howTos = howTos
    }
}

//MARK: Notifications
extension DataManager {
    
    func toggleNotificationFor(_ performance: Performance) async throws {
        try await requestAuthorization()
        if activeNotifications.contains(String(performance.id)) {
            removeNotificationFor(performance)
            print("removed notification for \(performance.id)")
        } else {
            try await addNotificationFor(performance)
            print("enabled notification for \(performance.id)")
        }
        try? storageManager.saveActiveNotifications(self.activeNotifications)
    }
    
    private func updateNotificationFor(_ performance: Performance) async throws {
        userNC.removePendingNotificationRequests(withIdentifiers: [String(performance.id)])
        let request = try getNotificationRequestFor(performance)
        try await userNC.add(request)
        print("updated notification for \(performance.id)")
    }
    
    private func removeNotificationFor(_ performance: Performance) {
        userNC.removePendingNotificationRequests(withIdentifiers: [String(performance.id)])
        activeNotifications.removeAll { $0 == String(performance.id) }
    }
    
    private func getNotificationRequestFor(_ performance: Performance) throws -> UNNotificationRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let content = UNMutableNotificationContent()
        content.title = performance.artist ?? ""
        content.body = "Die Veranstaltung beginnt um \(dateFormatter.string(from: performance.date)) Uhr im \(Util.nameForLocation(performance.location))"
        
        let components = try notificationComponentsFor(performance)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: String(performance.id), content: content, trigger: trigger)
        
        return request
    }
    
    private func addNotificationFor(_ performance: Performance) async throws {
        let request = try getNotificationRequestFor(performance)
        try await userNC.add(request)
        activeNotifications.append(String(performance.id))
    }
    
    private func notificationComponentsFor(_ performance: Performance) throws -> DateComponents {
        guard let notificationDate = calendar.date(byAdding: .minute, value: -15, to: performance.date) else {
            throw DataManagerError.notificationTimeCalculationFailed
        }
        return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
    }
    
    private func requestAuthorization() async throws {
        let authorization = await userNC.notificationSettings().authorizationStatus
        if authorization != .authorized {
            try await userNC.requestAuthorization(options: [.alert, .sound])
        }
    }
}
