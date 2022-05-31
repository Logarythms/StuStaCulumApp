//
//  FaqDetailView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI

struct FaqDetailView: View {
    let howTo: HowTo
    
    var body: some View {
        ScrollView {
            Text(html: howTo.description, size: 15)
                .padding()
                .navigationTitle(howTo.title)
        }
    }
}

//struct FaqDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        FaqDetailView()
//    }
//}
