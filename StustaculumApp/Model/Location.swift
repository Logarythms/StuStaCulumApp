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
    
    func color() -> UIColor? {
        if let colorString = colorString {
            return UIColor(hex: colorString)
        } else {
            return nil
        }
    }
    
    static func locationFor(_ stage: Stage) -> Location? {
        locationFor(stage.rawValue)
    }
    
    static func locationFor(_ id: Int) -> Location? {
        DataManager.shared.locations.first { $0.id == id }
    }
}

enum Stage: Int, CaseIterable, Codable {
    case dada = 1
    case atrium = 2
//    case halle = 3
    case zelt = 4
    case kade = 22
    case gelände = 5
}
