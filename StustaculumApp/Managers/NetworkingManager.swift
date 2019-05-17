//
//  NetworkingManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation
import Alamofire

class NetworkingManager {
    
    class func getCurrentLogo(_ url: URL, completion: @escaping (UIImage) -> Void) {
        guard let httpsURL = Util.httpsURLfor(url) else { return }
        
        Alamofire.request(httpsURL).responseImage { (response) in
            if let image = response.result.value {
                completion(image)
            }
        }
    }
    
    class func getCurrentSSC(completion: @escaping (Stustaculum) -> Void) {
        let url = getRequestUrlFor(.currentSSC)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            guard let ssc = try? decoder.decode(Stustaculum.self, from: jsonData) else { return }
            
            completion(ssc)
        }
    }
    
    class func getHowTos(completion: @escaping ([HowTo]) -> Void) {
        let url = getRequestUrlFor(.howTo)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
            guard let howTos = try? JSONDecoder().decode([HowTo].self, from: jsonData) else { return }
            completion(howTos)
        }
    }
    
    class func getLocationCategories(completion: @escaping ([LocationCategory]) -> Void) {
        let url = getRequestUrlFor(.locationCategories)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
            guard let locationCategories = try? JSONDecoder().decode([LocationCategory].self, from: jsonData) else { return }
            completion(locationCategories)
        }
    }
    
    class func getLocations(completion: @escaping ([Location]) -> Void) {
        let url = getRequestUrlFor(.locations)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
//            guard let locations = try? JSONDecoder().decode([Location].self, from: jsonData) else { return }
            
            do {
                let locations = try JSONDecoder().decode([Location].self, from: jsonData)
                completion(locations)
            } catch let error {
                print(error)
            }
        }
    }
    
    class func getNews(completion: @escaping ([NewsEntry]) -> Void) {
        let url = getRequestUrlFor(.news)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
            guard let locations = try? JSONDecoder().decode([NewsEntry].self, from: jsonData) else { return }
            completion(locations)
        }
    }
    
    class func getPerformances(completion: @escaping ([Performance]) -> Void) {
        let url = getRequestUrlFor(.performances)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            guard let performances = try? decoder.decode([Performance].self, from: jsonData) else { return }
            
            completion(performances)
        }
    }
    
    class func getPerformancesFor(_ day: SSCDay, completion: @escaping ([Performance]) -> Void) {
        let url = getRequestUrlFor(.performances)
        
        Alamofire.request(url).response { (response) in
            guard let jsonData = response.data else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            guard let performances = try? decoder.decode([Performance].self, from: jsonData) else { return }
                        
            completion(Util.filterPerformancesBy(day, performances: performances).filter({$0.show}))
        }
    }
    
    class func addDeviceForPushNotifications(token: String) {
        let url = getRequestUrlFor(.devices)
        let parameters = [
            "registration_id" : token,
            "name" : UUID().uuidString,
            "active" : true
            ] as [String : Any]
        print(parameters)
        print("Adding Device")
        Alamofire.request(url, method: .post, parameters: parameters).response { response in
            if response.response?.statusCode == 201 {
                UserDefaults.standard.set(true, forKey: "pushRegistered")
                print("Device successfully added")
            }
        }
    }
    
    class private func getRequestUrlFor(_ endpoint: Endpoint) -> URL {
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
        case howTo = "/rest/howtos/"
        case locationCategories = "/rest/location/categories/"
        case locations = "/rest/locations/"
        case news = "/rest/news/"
        case performances = "/rest/performances/"
        case devices = "/rest/apnsdevices/"
    }
    
}
