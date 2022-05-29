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
        
        let (data, _) = try await session.data(from: httpsURL)
        guard let image = UIImage(data: data) else { throw NetworkingError.imageMissing }
        
        return image
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
    
    func getPerformances() async throws -> [Performance] {
        let performances: [Performance] = try await getDecodedData(requestUrlFor(.performances))
        return performances
    }
    
    func getPerformancesFor(_ day: SSCDay) async throws -> [Performance] {
        let performances: [Performance] = try await getDecodedData(requestUrlFor(.performances))
        return Util.filterPerformancesBy(day, performances: performances).filter { $0.show }
    }
    
//    func addDeviceForPushNotifications(token: String) {
//        let url = requestUrlFor(.devices)
//        let parameters = [
//            "registration_id" : token,
//            "name" : UUID().uuidString,
//            "active" : true
//        ] as [String : Any]
//        print(parameters)
//        print("Adding Device")
//        Alamofire.request(url, method: .post, parameters: parameters).response { response in
//            if response.response?.statusCode == 201 {
//                UserDefaults.standard.set(true, forKey: "pushRegistered")
//                print("Device successfully added")
//            }
//        }
//    }
    
    func requestUrlFor(_ endpoint: Endpoint) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "app.stustaculum.de"
        urlComponents.path = endpoint.rawValue
        
        guard let url = urlComponents.url else {
            fatalError("Could not create URL")
        }
        
        return url
    }
    
    enum Endpoint: String {
        case currentSSC = "/rest/stustaculum/current/"
//        case currentSSC = "/rest/stustaculum/4/"
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
    
}
