//
//  EmptyCell.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 03.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI

struct EmptyCell: View {
    let duration: Int
    
    var body: some View {
        VStack {
           Text("")
        }
        .centered()
        .frame(height: CGFloat(duration * 2 - 4))
        .cornerRadius(10)
    }
}
