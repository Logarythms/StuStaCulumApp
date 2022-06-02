//
//  UpcomingPerformanceView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct UpcomingPerformanceCell: View {
    
    let performance: Performance
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                let description = performance.getEventDescription()
                LocationLabel(locationName: description.locationName, locationColor: description.locationColor)
                if let artist = description.artist, let genre = description.genre, let attributedString = try? AttributedString(markdown: "**\(artist)** (_\(genre)_)") {
                    Text(attributedString)
                        .font(.subheadline)
//                        .foregroundColor(.white)
//                        .bold()
                }
                
                Text(description.formattedDate)
                    .font(.caption)
                    .bold()
            }
            Spacer()
        }
        .padding(5)

    }
}

//struct UpcomingPerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpcomingPerformanceView()
//    }
//}

struct LocationLabel: View {
    let locationName: String
    let locationColor: Color
    
    var body: some View {
        Text(locationName)
            .font(.body)
            .fontWeight(.heavy)
            .foregroundColor(.white)
            .padding([.leading, .trailing], 5)
            .padding([.top, .bottom], 2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(locationColor)
            )
            .offset(x: -3)
    }
}
