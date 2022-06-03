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
        VStack(alignment: .leading, spacing: 5) {
            Text(newsEntry.title)
                .font(.body)
                .fontWeight(.heavy)
            Text(newsEntry.description)
                .font(.footnote)
                .fontWeight(.semibold)
        }
    }
}

//struct NewsEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsEntryView()
//    }
//}
