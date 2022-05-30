//
//  NewsEntry.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation

struct NewsEntry: Codable, Identifiable {
    var id: Int
    var title: String
    var description: String
    var isNotification: Bool
    var alreadyNotified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isNotification = "is_notification"
        case alreadyNotified = "already_notified"
    }
}
