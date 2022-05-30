//
//  NewsEntryView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct NewsEntryView: View {
    
    let newsEntry: NewsEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(newsEntry.title)
                .font(.title3)
            Text(newsEntry.description)
                .font(.body)
        }
        .padding([.leading, .trailing])
    }
}

//struct NewsEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsEntryView()
//    }
//}
