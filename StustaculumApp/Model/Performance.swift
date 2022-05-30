//
//  Performance.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit

struct Performance: Codable, Identifiable {
    var id: Int
    var artist: String?
    var description: String?
    var genre: String?
    var date: Date
    var duration: Int
    var imageURL: URL?
    var lastUpdate: Date
    var show: Bool
    var location: Int
    var stustaculumID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case artist
        case description
        case genre
        case date
        case duration
        case imageURL = "image_url"
        case lastUpdate = "last_update"
        case show
        case location
        case stustaculumID = "stustaculum"
    }
    
    func printDescripton() {
        guard let a = artist else { return }
        print("\(a) at \(self.date) for \(self.duration) min")
    }
    
    func getOldEventDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        
        var string = ""
        
        string += Util.nameForLocation(self.location)
        string += "\n"
        string += dateFormatter.string(from: self.date)
        string += " Uhr"
        
        guard let artist = self.artist else {
            return string
        }
        
        string += "\n"
        string += artist
        
        return string
    }
    
    func getEventDescription() -> EventDescripton {
        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        dateFormatter.dateFormat = "EEEE HH:mm"
        dateFormatter.locale = Locale.init(identifier: "de_DE")
                        
        let locationName = Util.nameForLocation(self.location)
        let formattedDate = dateFormatter.string(from: self.date) + " Uhr"
        
        return EventDescripton(locationName: locationName, formattedDate: formattedDate, artist: artist, genre: genre)
    }
    
    struct EventDescripton {
        let locationName: String
        let formattedDate: String
        let artist: String?
        let genre: String?
    }
}

extension Performance: Equatable {
    static func ==(lhs: Performance, rhs: Performance) -> Bool {
        return lhs.id == rhs.id
    }
}
