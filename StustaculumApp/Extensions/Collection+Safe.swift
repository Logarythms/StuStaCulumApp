//
//  Collection+Safe.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 05.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
