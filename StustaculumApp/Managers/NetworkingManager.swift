//
//  NetworkingManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation
import UIKit

class NetworkingManager {
    
    let decoder = JSONDecoder()
    let session = URLSession(configuration: .default)
    
    static let shared = NetworkingManager()
    
    private init() {
        decoder.dateDecodingStrategy = .custom(SSCDateFormatter.shared.customDateDecoder(_:))
    }
    
    enum NetworkingError: Error {
        case httpsURLmissing
        case requestFailed
        case imageMissing
        case decodingFailed
    }
    
    func getCurrentLogo(_ url: URL) async throws -> UIImage {
        guard let httpsURL = Util.httpsURLfor(url) else { throw NetworkingError.httpsURLmissing }
        return try await getImageFrom(httpsURL)
    }
    
    func getCurrentSSC() async throws -> Stustaculum {
        let ssc: Stustaculum = try await getDecodedData(requestUrlFor(.currentSSC))
        return ssc
    }
    
    func getHowTos() async throws -> [HowTo] {
        let howTos: [HowTo] = try await getDecodedData(requestUrlFor(.howTo))
        return howTos
    }
    
    func getLocationCategories() async throws -> [LocationCategory] {
        let categories: [LocationCategory] = try await getDecodedData(requestUrlFor(.locationCategories))
        return categories
    }

    func getLocations() async throws -> [Location] {
        let locations: [Location] = try await getDecodedData(requestUrlFor(.locations))
        return locations
    }
    
    func getNews() async throws -> [NewsEntry] {
        let newsEntries: [NewsEntry] = try await getDecodedData(requestUrlFor(.news))
        return newsEntries
    }
    
    func getPerformances(_ ssc: Stustaculum? = nil) async throws -> [Performance] {
        let performances: [Performance] = try await getDecodedData(requestUrlFor(.performances, ssc: ssc))
        return performances
    }
    
    func requestUrlFor(_ endpoint: Endpoint, ssc: Stustaculum? = nil) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "app.stustaculum.de"
        urlComponents.path = endpoint.rawValue
        
        if let ssc = ssc {
            urlComponents.queryItems = [URLQueryItem(name: "stustaculum", value: "\(ssc.id)")]
        }
        
        return urlComponents.url!
    }
    
    enum Endpoint: String {
        case currentSSC = "/rest/stustaculum/current/"
        case howTo = "/rest/howtos/"
        case locationCategories = "/rest/location/categories/"
        case locations = "/rest/locations/"
        case news = "/rest/news/"
        case performances = "/rest/performances/"
        case devices = "/rest/apnsdevices/"
    }
    
    func getDecodedData<T: Codable>(_ url: URL) async throws -> T {
        let (data, _) = try await session.data(from: url)
        return try decoder.decode(T.self, from: data)
    }
    
    func getImageFrom(_ url: URL) async throws -> UIImage {
        let (data, _) = try await session.data(from: url)
        guard let image = UIImage(data: data) else { throw NetworkingError.imageMissing }
        
        return image
    }
    
}
