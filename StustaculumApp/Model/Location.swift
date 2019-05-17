//
//  Location.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import CoreLocation

struct Location: Codable {
    var id: Int
    var name: String
    var shortName: String
    var navigationString: String?
    var colorString: String?
    var color: UIColor?
    var latitudeString: String
    var longitudeString: String
    var coordinates: CLLocationCoordinate2D?
    var typeInt: Int?
    var category: LocationCategory?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName = "short_name"
        case navigationString = "navigation_string"
        case colorString = "color"
        case latitudeString = "latitude"
        case longitudeString = "longitude"
        case typeInt = "type"
    }
    
}
