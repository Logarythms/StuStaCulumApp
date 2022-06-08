//
//  SavePath.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 06.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

enum SavePath: String, CaseIterable {
    case currentSSC = "currentSSC"
    case days = "days"
    case dayslots = "dayslots"
    case performances = "performances"
    case locations = "locations"
    case howTos = "howTos"
    case news = "news"
    
    var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self.rawValue).json")
    }
    
    var localResource: URL {
        Bundle.main.url(forResource: self.rawValue, withExtension: "json")!
    }
}
