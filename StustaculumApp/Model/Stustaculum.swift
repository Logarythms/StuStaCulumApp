//
//  SSC.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

struct Stustaculum: Codable {
    
    var id: Int
    var lastUpdated: Date
    var startDate: Date
    var endDate: Date
    var year: Int
    var updateURL: URL
    var logoURL: URL
    var logo: UIImage?
    var published: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastUpdated = "last_updated"
        case startDate = "start_date"
        case endDate = "endDate"
        case year
        case updateURL = "update_url"
        case logoURL = "logo"
        case published
    }
    
    
    
}
