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
    case performances = "performances"
    case locations = "locations"
    case howTos = "howTos"
    case news = "news"
    case logo = "logo"
    
    var url: URL {
        switch self {
        case .logo:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self.rawValue).png")
        default:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self.rawValue).json")
        }
        
    }
    
    var localResource: URL {
        switch self {
        case .logo:
            return Bundle.main.url(forResource: self.rawValue, withExtension: "png")!
        default:
            return Bundle.main.url(forResource: self.rawValue, withExtension: "json")!
        }
    }
}
