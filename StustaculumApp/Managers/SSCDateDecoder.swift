//
//  CustomDateDecoder.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 27.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

class SSCDateFormatter {
    var fullDateFormatter = ISO8601DateFormatter()
    var shortDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        formatter.timeZone = TimeZone(abbreviation: "CEST")!
        return formatter
    }
    
    private init() {}
    
    static let shared = SSCDateFormatter()
    
    func customDateDecoder(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let fullDate = fullDateFormatter.date(from: dateString) {
            return fullDate
        } else if let shortDate = shortDateFormatter.date(from: dateString) {
            return shortDate
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "error")
        }
    }
}
