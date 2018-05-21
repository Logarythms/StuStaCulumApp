//
//  NetworkingManager.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation

class NetworkingManager {
    
    class func getCurrentSSC() {
        let url = getRequestUrlFor(.currentSSC)
        var request = URLRequest(url: url)
        
    }
    
    private class func getRequestUrlFor(_ endpoint: Endpoint) -> URL {
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
        case performances = "rest/performances/"
    }
    
}
