//
//  Dayslot.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 09.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

struct Dayslot: Identifiable, Codable {
    let day: SSCDay
    let id: UUID
    var timeslots: [Stage: [Timeslot]] = [:]
    
    init(day: SSCDay) {
        self.day = day
        self.id = UUID()
    }
}
